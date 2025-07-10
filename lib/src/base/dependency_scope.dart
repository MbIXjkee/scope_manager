import 'package:flutter/foundation.dart';
import 'package:scopes/src/base/scope_resolver.dart';

abstract interface class DependencyScope {}

abstract interface class RootScope extends DependencyScope {
  Future<void> init();
}

abstract interface class FeatureScope extends DependencyScope {
  @protected
  S bindWith<S extends FeatureScope>();

  @protected
  void unbindFrom<C extends FeatureScope>();

  void dispose();
}

abstract class BaseFeatureScope implements FeatureScope {
  @protected
  final ScopeResolver resolver;

  BaseFeatureScope({required this.resolver});

  @override
  S bindWith<S extends FeatureScope>() {
    resolver.subscribeToScope<S>(this);
    return resolver.getScope<S>();
  }

  @override
  void unbindFrom<C extends FeatureScope>() {
    resolver.unsubscribeFromScope<C>(this);
  }
}
