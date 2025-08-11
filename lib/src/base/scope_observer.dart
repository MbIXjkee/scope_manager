import 'package:flutter/foundation.dart';
import 'package:scope_manager/scope_manager.dart';

abstract interface class ScopeObserver {
  ValueListenable<Map<Type, Map<Object?, Set<Object>>>>
      get subscribersPublisher;

  ValueListenable<Map<Type, Map<Object?, FeatureScope>>> get scopesPublisher;
}
