import 'package:flutter/foundation.dart';
import 'package:scope_manager/scope_manager.dart';

/// A base interface for all dependency scopes.
abstract interface class DependencyScope {}

/// An interface for the scope of dependencies that is alive for the
/// whole application lifetime.
///
/// It has an asynchronous initialization process and is never destroyed.
/// It is a single mandatory dependency scope, and it always exists.
abstract interface class RootScope extends DependencyScope {
  /// Runs a process of the scope initialization.
  /// 
  /// This method is automatically called by [ScopeManager] during
  /// its initialization, and should not be called manually.
  Future<void> init();
}

/// An interface for the scope of dependencies that can be created or destroyed
/// on demand.
///
/// Scopes of this type usually contain dependencies grouped by some reason:
///  - used only in authenticated zone;
///  - used for specific feature;
///  - etc.
/// Due to creating these scopes on demand, they cannot have 
/// asynchronious intialization.
/// These scopes are created as soon as the first subscriber on them appears,
/// and they are keeping alive while at least one subscriber stil exists.
/// 
/// When one [FeatureScope] uses a dependency from another [FeatureScope],
/// it should become a subscriber of it, use [bindWith] for this purpose.
/// When the dependency is not needed anymore, use [unbindFrom] to release
/// a subscribed scope.
abstract interface class FeatureScope extends DependencyScope {
  /// Subscribes this [FeatureScope] to another to safely use
  /// dependencies from it.
  @protected
  S bindWith<S extends FeatureScope>();

  /// Unsubscribes this [FeatureScope] from another previously subscribed.
  @protected
  void unbindFrom<C extends FeatureScope>();

  /// Releases resources of this [FeatureScope].
  void dispose();
}

/// A base implementation of [FeatureScope]. Should be extended by real
/// dependency scopes in the application.
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
