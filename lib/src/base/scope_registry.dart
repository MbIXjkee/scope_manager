import 'package:scope_manager/src/base/dependency_scope.dart';
import 'package:scope_manager/src/base/scope_resolver.dart';

typedef ScopeFactory<S extends FeatureScope> = S Function(
  ScopeResolver resolver,
);

abstract interface class ScopeRegistry {
  Future<void> init(
    RootScope rootScope, {
    List<ScopeBinding>? bindings,
  });

  void registerScopeBinding<S extends FeatureScope>(
    ScopeBinding<S> binding,
  );

  void registerScopeFactory<S extends FeatureScope>(ScopeFactory<S> factory);
}

class ScopeBinding<S extends FeatureScope> {
  final ScopeFactory<S> factory;

  Type get scopeType => S;

  ScopeBinding(this.factory);
}
