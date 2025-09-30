import 'package:scope_manager/src/base/dependency_scope.dart';

/// An interface for interacting with registered scopes.
abstract interface class ScopeResolver {
  /// Subscribes an object to a [FeatureScope] to safely access
  /// it via [getScope].
  ///
  /// The generic type [S] specifies the [FeatureScope] type to subscribe to.
  /// Use [tag] to target a specific tagged instance when multiple instances
  /// of the same scope type exist.
  void subscribeToScope<S extends FeatureScope>(
    Object subscriber, {
    Object? tag,
  });

  /// Unsubscribes an object from a previously subscribed [FeatureScope].
  ///
  /// Use the same [tag] that was used during subscription, if any.
  void unsubscribeFromScope<S extends FeatureScope>(
    Object subscriber, {
    Object? tag,
  });

  /// Retrieves an instance of a registered and subscribed [DependencyScope].
  ///
  /// Throws if the requested scope is not registered or there is
  /// no subscription to it.
  ///
  /// The [tag] parameter can be used to distinguish between multiple
  /// instances of the same scope type.
  ///
  /// The [RootScope] is always available without the need for a subscription.
  /// The [RootScope] cannot be tagged; it is always a single instance.
  S getScope<S extends DependencyScope>({
    Object? tag,
  });
}
