import 'package:flutter/material.dart';
import 'package:scope_example/di/app_scope.dart';
import 'package:scope_example/di/feature_scopes.dart';
import 'package:scope_manager/scope_manager.dart';

Future<void> main() async {
  final scopeManager = ScopeManager.instance;
  await registerDependencies(scopeManager);

  runApp(const MainApp());
}

Future<void> registerDependencies(ScopeRegistry registry) async {
  final appScope = AppScope();

  await registry.init(appScope);

  registry
    ..registerScopeBinding(
      ScopeBinding<ISome1Scope>(
        (resolver) => Some1Scope(resolver: resolver),
      ),
    )
    ..registerScopeBinding(
      ScopeBinding<ISome2Scope>(
        (resolver) => Some2Scope(resolver: resolver),
      ),
    )
    ..registerScopeBinding(
      ScopeBinding<ISome3Scope>(
        (resolver) => Some3Scope(resolver: resolver),
      ),
    );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
