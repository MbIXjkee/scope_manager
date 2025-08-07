import 'package:flutter/material.dart';
import 'package:scope_example/di/app_scope.dart';
import 'package:scope_example/di/feature_scopes.dart';
import 'package:scope_manager/scope_manager.dart';

Future<void> main() async {
  final scopeManager = ScopeManager.instance;
  await registerDependencies(scopeManager);

  runApp(
    MainApp(
      scopeManager: scopeManager,
    ),
  );
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
  final ScopeManager scopeManager;

  const MainApp({super.key, required this.scopeManager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Row(
        children: [
          Expanded(
            child: Scaffold(
              body: ObservingInfo(observer: scopeManager),
            ),
          ),
          Expanded(
            child: _Content(
              scopeResolver: scopeManager,
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final ScopeResolver scopeResolver;

  const _Content({
    required this.scopeResolver,
  });

  @override
  Widget build(BuildContext context) {
    return Scopes(
      resolver: scopeResolver,
      child: const MaterialApp(
        home: _Playground(),
      ),
    );
  }
}

class _Playground extends StatefulWidget {
  const _Playground();

  @override
  State<_Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<_Playground> {
  var _firstScopeIsActive = false;
  var _secondScopeIsActive = false;
  var _thirdScopeIsActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Feature Scopes Playground',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _firstScopeIsActive = !_firstScopeIsActive;
              });
            },
            child: Text(
              _firstScopeIsActive ? 'Deactivate Scope 1' : 'Activate Scope 1',
            ),
          ),
          if (_firstScopeIsActive) const Some1ScopeWidget(),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _secondScopeIsActive = !_secondScopeIsActive;
              });
            },
            child: Text(
              _secondScopeIsActive ? 'Deactivate Scope 2' : 'Activate Scope 2',
            ),
          ),
          if (_secondScopeIsActive) const Some2ScopeWidget(),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _thirdScopeIsActive = !_thirdScopeIsActive;
              });
            },
            child: Text(
              _thirdScopeIsActive ? 'Deactivate Scope 3' : 'Activate Scope 3',
            ),
          ),
          if (_thirdScopeIsActive) const Some3ScopeWidget(),
        ],
      ),
    );
  }
}

class Some1ScopeWidget extends StatefulWidget {
  const Some1ScopeWidget({super.key});

  @override
  State<Some1ScopeWidget> createState() => _Some1ScopeWidgetState();
}

class _Some1ScopeWidgetState extends State<Some1ScopeWidget>
    with ScopeSubscriberMixin<ISome1Scope, Some1ScopeWidget> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class Some2ScopeWidget extends StatefulWidget {
  const Some2ScopeWidget({super.key});

  @override
  State<Some2ScopeWidget> createState() => _Some2ScopeWidgetState();
}

class _Some2ScopeWidgetState extends State<Some2ScopeWidget>
    with ScopeSubscriberMixin<ISome2Scope, Some2ScopeWidget> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class Some3ScopeWidget extends StatefulWidget {
  const Some3ScopeWidget({super.key});

  @override
  State<Some3ScopeWidget> createState() => _Some3ScopeWidgetState();
}

class _Some3ScopeWidgetState extends State<Some3ScopeWidget>
    with ScopeSubscriberMixin<ISome3Scope, Some3ScopeWidget> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
