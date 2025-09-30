import 'package:flutter/foundation.dart';
import 'package:scope_manager/scope_manager.dart';

/// A base interface for all dependency scopes.
abstract interface class DependencyScope {}

/// An interface for the scope of dependencies that is alive for the
/// entire application lifetime.
///
/// It has an asynchronous initialization process and is never destroyed.
/// It is a single, mandatory dependency scope that always exists.
abstract interface class RootScope extends DependencyScope {
  /// Runs a process of the scope initialization.
  ///
  /// This method is automatically called by [ScopeManager] during
  /// its initialization and should not be called manually.
  Future<void> init();
}

/// An interface for the scope of dependencies that can be created or destroyed
/// on demand.
///
/// Scopes of this type usually contain dependencies grouped for a specific reason:
///  - used only in the authenticated area;
///  - used for a specific feature;
///  - etc.
/// Because these scopes are created on demand, they cannot have asynchronous
/// initialization. These scopes are created as soon as the first subscriber
/// appears and remain alive while at least one subscriber still exists.
///
/// When one [FeatureScope] depends on another [FeatureScope], the dependent
/// scope should subscribe to the dependee. Use [bindWith] for this purpose.
/// When the dependency is no longer needed, use [unbindFrom] to release the
/// subscription to that scope.
abstract interface class FeatureScope extends DependencyScope {
  /// Subscribes this [FeatureScope] to another to safely use
  /// that scope's dependencies.
  @protected
  S bindWith<S extends FeatureScope>();

  /// Unsubscribes this [FeatureScope] from a previously subscribed scope.
  @protected
  void unbindFrom<C extends FeatureScope>();

  /// Releases resources of this [FeatureScope].
  void dispose();
}

/// A base implementation of [FeatureScope].
///
/// Extend this class to implement feature-specific dependency scopes.
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
