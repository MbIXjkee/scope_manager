import 'package:flutter/foundation.dart';
import 'package:scope_manager/scope_manager.dart';

/// An interface that provides information about currently active
/// [FeatureScope] instances and their subscribers.
///
/// Information provided only in observable mode — usually in debug builds,
/// unless otherwise specified via [setObservability] method.
abstract interface class ScopeObserver {
  /// Enables or disables the observability mode.
  void setObservability({required bool isObservable});

  /// Publishes a mapping of subscribers grouped by scope type and optional tag.
  ///
  /// Structure:
  ///  - key `Type`: the [FeatureScope] type;
  ///  - key `Object?` (tag): an optional tag distinguishing scope instances;
  ///  - value `Set<Object>`: the set of subscribers for that tagged scope.
  ValueListenable<Map<Type, Map<Object?, Set<Object>>>>
      get subscribersPublisher;

  /// Publishes active scopes grouped by scope type and optional tag.
  ///
  /// Structure:
  ///  - key `Type`: the [FeatureScope] type;
  ///  - key `Object?` (tag): an optional tag distinguishing scope instances;
  ///  - value `FeatureScope`: the active scope instance for that tag.
  ValueListenable<Map<Type, Map<Object?, FeatureScope>>> get scopesPublisher;
}
