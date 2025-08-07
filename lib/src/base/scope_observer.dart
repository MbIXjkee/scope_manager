import 'package:scope_manager/scope_manager.dart';

abstract interface class ScopeObserver {
  Stream<Map<Type, Map<Object?, Set<Object>>>>
      get subscribersPublisher;

  Stream<Map<Type, Map<Object?, FeatureScope>>>
      get scopesPublisher;
}
