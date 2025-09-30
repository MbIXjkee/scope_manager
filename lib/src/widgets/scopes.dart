import 'package:flutter/material.dart';
import 'package:scope_manager/src/base/dependency_scope.dart';
import 'package:scope_manager/src/base/scope_resolver.dart';
import 'package:scope_manager/src/scope_manager.dart';

/// Provides access to the scope resolving functionality via the [BuildContext].
class Scopes extends InheritedWidget implements ScopeResolver {
  final ScopeResolver _resolver;

  Scopes({
    super.key,
    required super.child,
    ScopeResolver? resolver,
  }) : _resolver = resolver ?? ScopeManager.instance;

  /// Retrieves the nearest [ScopeResolver] instance from the given [context].
  static ScopeResolver of(BuildContext context) {
    final scopes = context.getInheritedWidgetOfExactType<Scopes>();
    assert(
      scopes != null,
      'Scopes widget not found in context.'
      '\nMake sure to wrap your widget tree with Scopes.',
    );

    return scopes!;
  }

  @override
  bool updateShouldNotify(Scopes oldWidget) {
    return _resolver != oldWidget._resolver;
  }

  @override
  S getScope<S extends DependencyScope>({Object? tag}) {
    return _resolver.getScope<S>(tag: tag);
  }

  @override
  void subscribeToScope<S extends FeatureScope>(
    Object subscriber, {
    Object? tag,
  }) {
    _resolver.subscribeToScope<S>(subscriber, tag: tag);
  }

  @override
  void unsubscribeFromScope<S extends FeatureScope>(
    Object subscriber, {
    Object? tag,
  }) {
    _resolver.unsubscribeFromScope<S>(subscriber, tag: tag);
  }
}
