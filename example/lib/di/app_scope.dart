import 'package:scope_manager/scope_manager.dart';

/// App level dependencies.
abstract interface class IAppScope implements RootScope {
  /// Creates something;
  Object someFactoryOfSomething();
}

/// Scope of dependencies which need through all app's lifecycle.
class AppScope implements IAppScope {
  /// Create an instance of [AppScope].
  AppScope();

  @override
  Future<void> init() async {}

  @override
  Object someFactoryOfSomething() {
    return {};
  }
}
