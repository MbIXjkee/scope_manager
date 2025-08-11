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
  var _firstScopeCount = 0;
  var _secondScopeCount = 0;
  var _thirdScopeCount = 0;

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
          _ScopeCounter(
            onPlus: () {
              setState(() {
                _firstScopeCount++;
              });
            },
            onMinus: () {
              setState(() {
                if (_firstScopeCount > 0) {
                  _firstScopeCount--;
                }
              });
            },
            count: _firstScopeCount,
            title: 'Scope 1',
          ),
          Row(
            children: [
              for (var i = 0; i < _firstScopeCount; i++)
                const Some1ScopeWidget(),
            ],
          ),
          _ScopeCounter(
            onPlus: () {
              setState(() {
                _secondScopeCount++;
              });
            },
            onMinus: () {
              setState(() {
                if (_secondScopeCount > 0) {
                  _secondScopeCount--;
                }
              });
            },
            count: _secondScopeCount,
            title: 'Scope 2',
          ),
          Row(
            children: [
              for (var i = 0; i < _secondScopeCount; i++)
                const Some2ScopeWidget(),
            ],
          ),
          _ScopeCounter(
            onPlus: () {
              setState(() {
                _thirdScopeCount++;
              });
            },
            onMinus: () {
              setState(() {
                if (_thirdScopeCount > 0) {
                  _thirdScopeCount--;
                }
              });
            },
            count: _thirdScopeCount,
            title: 'Scope 3',
          ),
          Row(
            children: [
              for (var i = 0; i < _thirdScopeCount; i++)
                const Some3ScopeWidget(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScopeCounter extends StatelessWidget {
  final VoidCallback _onPlus;
  final VoidCallback _onMinus;
  final int _count;
  final String _title;

  const _ScopeCounter({
    required VoidCallback onPlus,
    required VoidCallback onMinus,
    required int count,
    required String title,
  }) : _onPlus = onPlus,
       _onMinus = onMinus,
       _count = count,
       _title = title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _title,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _onMinus,
              child: const Text('-'),
            ),
            Text('$_count'),
            ElevatedButton(
              onPressed: _onPlus,
              child: const Text('+'),
            ),
          ],
        ),
      ],
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
