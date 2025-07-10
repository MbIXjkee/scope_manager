import 'package:scopes/src/base/dependency_scope.dart';
import 'package:scopes/src/base/scope_registry.dart';
import 'package:scopes/src/base/scope_resolver.dart';

class ScopeManager implements ScopeRegistry, ScopeResolver {
  static final _instance = ScopeManager._internal();

  final _scopeFactories = <Type, ScopeFactory>{};

  final _subscribers = <Type, Map<Object?, Set<Object>>>{};

  final _scopes = <Type, Map<Object?, FeatureScope>>{};

  late final Type _rootType;
  late final RootScope _rootScope;
  var _isInit = false;

  static ScopeManager get instance => _instance;

  ScopeManager._internal();

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

      // hold the root scope by the manager itself.
      final type = rootScope.runtimeType;
      _rootType = type;
      _rootScope = rootScope;
      _isInit = true;

      if (bindings != null) {
        for (final binding in bindings) {
          registerScopeFactory(binding.factory);
        }
      }
    }
  }

  @override
  void registerScopeBinding<S extends FeatureScope>(
    ScopeBinding<S> binding,
  ) {
    registerScopeFactory(binding.factory);
  }

  @override
  void registerScopeFactory<S extends FeatureScope>(
    ScopeFactory<S> factory,
  ) {
    _validateIsInit();
    _validateParameter<S>();
    if (_scopeFactories[S] != null) {
      throw StateError(
        'A scope factory for type $S is already registered. Please ensure '
        'that you do not register the same scope factory multiple times.',
      );
    }

    _scopeFactories[S] = factory;
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
      tagSubscribers = {subscriber};
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
        _scopes[S] = {tag: factory()};
      }
    }
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

    final scopeSubs = _subscribers[S]?[tag];
    if (scopeSubs == null) {
      // There are no subscribers for this scope type.
      return;
    }

    final isRemoved = scopeSubs.remove(subscriber);
    if (!isRemoved) {
      // Nothing has changed;
      return;
    }

    if (scopeSubs.isEmpty) {
      // No subscribers left for this scope type.
      final scope = _scopes[S.runtimeType]?.remove(tag);

      assert(
        scope != null,
        'Scope for type $S<tag: $tag> was expected to be present '
        'but was not found.',
      );

      scope?.dispose();
    }
  }

  @override
  S getScope<S extends DependencyScope>({
    Object? tag,
  }) {
    _validateIsInit();
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

  void _validateParameter<S extends DependencyScope>() {
    if (S == RootScope || S == FeatureScope || S == DependencyScope) {
      throw ArgumentError(
        'Invalid generic parameter: $S.'
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
