import 'package:scope_manager/src/base/dependency_scope.dart';
import 'package:scope_manager/src/base/scope_resolver.dart';

/// A type definition for a factory function that creates
/// instances of [FeatureScope].
typedef ScopeFactory<S extends FeatureScope> = S Function(
  ScopeResolver resolver,
);

/// An interface for registering available dependency scopes.
abstract interface class ScopeRegistry {
  /// Initializes the registry.
  ///
  /// Sets up the [RootScope] and optionally registers additional
  /// [FeatureScope] bindings to create them on demand.
  Future<void> init(
    RootScope rootScope, {
    List<ScopeBinding>? bindings,
  });

  /// Registers a binding for a [FeatureScope] type to its factory.
  void registerScopeBinding<S extends FeatureScope>(
    ScopeBinding<S> binding,
  );

  /// Registers a factory function for creating instances of a specific
  /// [FeatureScope] type.
  void registerScopeFactory<S extends FeatureScope>(ScopeFactory<S> factory);
}

/// A supporting class that binds a [FeatureScope] type to its factory.
class ScopeBinding<S extends FeatureScope> {
  final ScopeFactory<S> factory;

  Type get scopeType => S;

  ScopeBinding(this.factory);
}
