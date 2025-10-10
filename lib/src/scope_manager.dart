import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:scope_manager/src/base/dependency_scope.dart';
import 'package:scope_manager/src/base/scope_observer.dart';
import 'package:scope_manager/src/base/scope_registry.dart';
import 'package:scope_manager/src/base/scope_resolver.dart';
import 'package:scope_manager/src/widgets/scopes.dart';

/// A central management class for dependency scopes. It is responsible for
/// registering, resolving, and managing the lifecycle of dependency scopes.
///
/// This class is designed as a singleton. However, try to avoid direct
/// interactions via [ScopeManager.instance]. Use [Scopes] or
/// provided [ScopeResolver] instances instead.
///
/// See also:
/// [ScopeRegistry], [ScopeResolver], and [ScopeObserver] for more details
/// on specific areas of functionality.
class ScopeManager implements ScopeRegistry, ScopeResolver, ScopeObserver {
  static final _instance = ScopeManager._internal();

  final _scopeFactories = <Type, ScopeFactory>{};

  final _subscribers = <Type, Map<Object?, Set<Object>>>{};

  final _scopes = <Type, Map<Object?, FeatureScope>>{};

  late final _subscribersPublisher =
      ValueNotifier<Map<Type, Map<Object?, Set<Object>>>>({});

  late final _scopesPublisher =
      ValueNotifier<Map<Type, Map<Object?, FeatureScope>>>({});

  late final Type _rootType;
  late final RootScope _rootScope;
  var _isInit = false;
  var _isObservable = kDebugMode;

  static ScopeManager get instance => _instance;

  @override
  ValueNotifier<Map<Type, Map<Object?, FeatureScope>>> get scopesPublisher =>
      _scopesPublisher;

  @override
  ValueListenable<Map<Type, Map<Object?, Set<Object>>>>
      get subscribersPublisher => _subscribersPublisher;

  ScopeManager._internal();

  /// A factory constructor for creating a [ScopeManager] instance
  /// suitable for testing purposes (creates a new instance every time).
  ///
  /// Should be used only in tests.
  @visibleForTesting
  factory ScopeManager.test() => ScopeManager._internal();

  @override
  Future<void> init(
    RootScope rootScope, {
    List<ScopeBinding>? bindings,
  }) async {
    if (_isInit) {
      throw StateError(
        'ScopeManager is already initialized. Please ensure that you do not '
        'call init() multiple times.',
      );
    } else {
      await rootScope.init();

      final type = rootScope.runtimeType;
      _rootType = type;
      _rootScope = rootScope;
      _isInit = true;

      if (bindings != null) {
        for (final binding in bindings) {
          _registerScopeFactoryTyped(binding.scopeType, binding.factory);
        }
      }
    }
  }

  @override
  void registerScopeBinding<S extends FeatureScope>(
    ScopeBinding<S> binding,
  ) {
    registerScopeFactory<S>(binding.factory);
  }

  @override
  void registerScopeFactory<S extends FeatureScope>(
    ScopeFactory<S> factory,
  ) {
    _registerScopeFactoryTyped(S, factory);
  }

  @override
  void subscribeToScope<S extends FeatureScope>(
    Object subscriber, {
    Object? tag,
  }) {
    _validateIsInit();
    _validateParameter<S>();
    if (subscriber == this) {
      throw ArgumentError(
        'All subscriptions on behalf of ScopeManager itself are '
        'managed internally. Please use another object to subscribe.',
      );
    }

    if (_subscribers[S] == null) {
      _subscribers[S] = {};
    }
    var tagSubscribers = _subscribers[S]![tag];
    if (tagSubscribers == null) {
      tagSubscribers = {};
      _subscribers[S]![tag] = tagSubscribers;
    }

    final newSubAdded = tagSubscribers.add(subscriber);

    if (newSubAdded && _scopes[S]?[tag] == null) {
      final factory = _scopeFactories[S];
      if (factory == null) {
        throw StateError(
          'No scope factory registered for type $S. Please ensure that you '
          'have registered a scope factory using registerScopeFactory<$S>() '
          'before attempting to subscribe to this scope.',
        );
      } else {
        final currentScopes = _scopes[S] ?? {};
        currentScopes[tag] = factory(this);
        _scopes[S] = currentScopes;
      }
    }

    _updateOvservability();
  }

  @override
  void unsubscribeFromScope<S extends FeatureScope>(
    Object subscriber, {
    Object? tag,
  }) {
    _validateIsInit();
    _validateParameter<S>();
    if (subscriber == this) {
      throw ArgumentError(
        'All subscriptions on behalf of ScopeManager itself are '
        'managed internally. Please use another object to subscribe.',
      );
    }

    final scopeSubGroup = _subscribers[S];
    final scopeTagSubs = scopeSubGroup?[tag];
    if (scopeTagSubs == null) {
      // There are no subscribers for this scope.
      return;
    }

    final isRemoved = scopeTagSubs.remove(subscriber);
    if (!isRemoved) {
      // Nothing has changed;
      return;
    }

    if (scopeTagSubs.isEmpty) {
      scopeSubGroup!.remove(tag);
      // chekck if subscribers group is empty too.
      if (scopeSubGroup.isEmpty) {
        _subscribers.remove(S);
      }

      // No subscribers left for this scope.
      final scopeGroup = _scopes[S];
      final scope = scopeGroup?.remove(tag);

      assert(
        scope != null,
        'Scope for type $S<tag: $tag> was expected to be present '
        'but was not found.',
      );

      if (scopeGroup!.isEmpty) {
        _scopes.remove(S);
      }
      scope?.dispose();
    }

    _updateOvservability();
  }

  @override
  S getScope<S extends DependencyScope>({
    Object? tag,
  }) {
    _validateIsInit();
    _validateParameter<S>();
    if (S == _rootType) {
      assert(
        tag == null,
        'RootScope does not support tags. It supposed to be always the only. '
        'Please do not pass a tag when requesting RootScope.',
      );

      return _rootScope as S;
    }

    final scope = _scopes[S]?[tag];
    if (scope == null) {
      throw StateError(
        'Reauested scope is not created. Please ensure that you have '
        'subscribed to the scope using subscribeToScope<$S>() before '
        'attempting to access it. Scope is available only it has at least '
        'one active subscriber.',
      );
    }
    return scope as S;
  }

  @override
  void setObservability({required bool isObservable}) {
    if (isObservable == _isObservable) {
      return;
    }

    _isObservable = isObservable;

    if (!_isObservable) {
      _subscribersPublisher.value = {};
      _scopesPublisher.value = {};
    } else {
      _updateOvservability();
    }
  }

  Future<void> dispose() async {
    _subscribersPublisher.dispose();
    _scopesPublisher.dispose();
  }

  void _updateOvservability() {
    if (_isObservable) {
      final scopes = _scopes;
      final obsScopes = <Type, Map<Object?, FeatureScope>>{};
      for (final entry in scopes.entries) {
        final scopeType = entry.key;
        final scopeMap = entry.value;
        obsScopes[scopeType] = UnmodifiableMapView(scopeMap);
      }
      _scopesPublisher.value = UnmodifiableMapView(obsScopes);

      final subscribers = _subscribers;
      final obsSubscribers = <Type, Map<Object?, Set<Object>>>{};
      for (final entry in subscribers.entries) {
        final scopeType = entry.key;
        final subMap = entry.value;
        obsSubscribers[scopeType] = UnmodifiableMapView(subMap);
      }
      _subscribersPublisher.value = UnmodifiableMapView(obsSubscribers);
    }
  }

  void _registerScopeFactoryTyped(Type scopeType, ScopeFactory factory) {
    _validateIsInit();
    _validateParameterType(scopeType);
    if (_scopeFactories[scopeType] != null) {
      throw StateError(
        'A scope factory for type $scopeType is already registered. '
        'Please ensure that you do not register the same scope factory '
        'multiple times.',
      );
    }

    _scopeFactories[scopeType] = factory;
  }

  void _validateParameter<S extends DependencyScope>() {
    _validateParameterType(S);
  }

  void _validateParameterType(Type type) {
    if (type == RootScope || type == FeatureScope || type == DependencyScope) {
      throw ArgumentError(
        'Invalid generic parameter: $type.'
        '\nDo not use interfaces like DependencyScope, RootScope or '
        'FeatureScope directly.'
        '\nPass the actual implementing class '
        '(e.g., AppScope or FooScope) instead.',
      );
    }
  }

  void _validateIsInit() {
    if (!_isInit) {
      throw StateError(
        'ScopeManager is not initialized. Please call init() before '
        'attempting to use ScopeManager.',
      );
    }
  }
}
