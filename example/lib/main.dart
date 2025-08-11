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

class _Playground extends StatelessWidget {
  const _Playground();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Feature Scopes Playground',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          _ScopeCounter(
            title: 'Scope 1',
            holder: Some1ScopeWidget(),
          ),
          _ScopeCounter(
            title: 'Scope 2',
            holder: Some2ScopeWidget(),
          ),
          _ScopeCounter(
            title: 'Scope 3',
            holder: Some3ScopeWidget(),
          ),
        ],
      ),
    );
  }
}

class _ScopeCounter extends StatefulWidget {
  final String _title;
  final Widget _holder;

  const _ScopeCounter({
    required String title,
    required Widget holder,
  }) : _title = title,
       _holder = holder;

  @override
  State<_ScopeCounter> createState() => _ScopeCounterState();
}

class _ScopeCounterState extends State<_ScopeCounter> {
  var _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget._title,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_count > 0) {
                    _count--;
                  }
                });
              },
              child: const Text('-'),
            ),
            Text('$_count'),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _count++;
                });
              },
              child: const Text('+'),
            ),
          ],
        ),
        Row(
          children: [
            for (var i = 0; i < _count; i++) widget._holder,
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
