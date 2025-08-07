import 'package:scope_manager/scope_manager.dart';

/// Describes some scope of dependencies
abstract interface class ISome1Scope implements FeatureScope {
  /// Some dependency.
  Object get dummy;
}

/// Describes some scope of dependencies
abstract interface class ISome2Scope implements FeatureScope {
  /// Some dependency.
  Object get dummy;
}

/// Describes some scope of dependencies
abstract interface class ISome3Scope implements FeatureScope {
  /// Some dependency.
  Object get dummy;
}

class Some1Scope extends BaseFeatureScope implements ISome1Scope {
  late final Object _dummy;

  @override
  Object get dummy => _dummy;

  Some1Scope({required super.resolver}) {
    _dummy = {};
  }

  @override
  void dispose() {}
}

class Some2Scope extends BaseFeatureScope implements ISome2Scope {
  late final Object _dummy;

  @override
  Object get dummy => _dummy;

  Some2Scope({required super.resolver}) {
    _dummy = {};
  }

  @override
  void dispose() {}
}

class Some3Scope extends BaseFeatureScope implements ISome3Scope {
  late final Object _dummy;

  @override
  Object get dummy => _dummy;

  Some3Scope({required super.resolver}) {
    _dummy = {};
  }

  @override
  void dispose() {}
}
