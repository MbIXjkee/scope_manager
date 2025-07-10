import 'package:scopes/src/base/dependency_scope.dart';

abstract interface class ScopeResolver {
  void subscribeToScope<S extends FeatureScope>(
    Object subscriber, {
    Object? tag,
  });

  void unsubscribeFromScope<S extends FeatureScope>(
    Object subscriber, {
    Object? tag,
  });

  S getScope<S extends DependencyScope>({
    Object? tag,
  });
}
