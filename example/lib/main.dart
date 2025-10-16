import 'package:flutter/material.dart';
import 'package:scope_example/di/app_scope.dart';
import 'package:scope_example/di/feature_scopes.dart';
import 'package:scope_manager/scope_manager.dart';

Future<void> main() async {
  final scopeManager = ScopeManager.instance;
  await registerDependencies(scopeManager);
  scopeManager.setObservability(isObservable: true);

  runApp(
    MainApp(
      scopeManager: scopeManager,
    ),
  );
}

Future<void> registerDependencies(ScopeRegistry registry) async {
  final appScope = AppScope();

  await registry.init(RootBinding<IAppScope>(appScope));

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
    return Scaffold(
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Feature Scopes Playground',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
          ),
          const _ScopeCounter(
            title: 'Scope 1',
            holder: Some1ScopeWidget(),
          ),
          const _ScopeCounter(
            title: 'Scope 2',
            holder: Some2ScopeWidget(),
          ),
          const _ScopeCounter(
            title: 'Scope 3',
            holder: Some3ScopeWidget(),
          ),
          _TaggedScopeCounter(
            title: 'Tagged Scope 1',
            builder: (tag) => _Tagged1ScopeWidget(key: ValueKey(tag)),
          ),
          _TaggedScopeCounter(
            title: 'Tagged Scope 2',
            builder: (tag) => _Tagged2ScopeWidget(key: ValueKey(tag)),
          ),
          _TaggedScopeCounter(
            title: 'Tagged Scope 3',
            builder: (tag) => _Tagged3ScopeWidget(key: ValueKey(tag)),
          ),
        ],
      ),
    );
  }
}

class _TaggedScopeCounter extends StatefulWidget {
  final String _title;
  final Widget Function(String) _builder;

  const _TaggedScopeCounter({
    required String title,
    required Widget Function(String) builder,
  }) : _builder = builder,
       _title = title;

  @override
  State<_TaggedScopeCounter> createState() => __TaggedScopeCounterState();
}

class __TaggedScopeCounterState extends State<_TaggedScopeCounter> {
  final _tags = <String>{};

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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Enter tag',
            ),
            onSubmitted: (value) {
              setState(() {
                if (value.isNotEmpty) {
                  _tags.add(value);
                }
              });
            },
          ),
        ),
        for (final tag in _tags)
          Row(
            key: ValueKey(tag),
            children: [
              Text(tag),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
                child: const Text('-'),
              ),
              widget._builder(tag),
            ],
          ),
      ],
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

class _Tagged1ScopeWidget extends StatefulWidget {
  const _Tagged1ScopeWidget({super.key});

  @override
  State<_Tagged1ScopeWidget> createState() => _Tagged1ScopeWidgetState();
}

class _Tagged1ScopeWidgetState extends State<_Tagged1ScopeWidget>
    with TaggedScopeSubscriberMixin<ISome1Scope, _Tagged1ScopeWidget> {
  @override
  Object? get scopeTag => widget.key;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _Tagged2ScopeWidget extends StatefulWidget {
  const _Tagged2ScopeWidget({super.key});

  @override
  State<_Tagged2ScopeWidget> createState() => _Tagged2ScopeWidgetState();
}

class _Tagged2ScopeWidgetState extends State<_Tagged2ScopeWidget>
    with TaggedScopeSubscriberMixin<ISome2Scope, _Tagged2ScopeWidget> {
  @override
  Object? get scopeTag => widget.key;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _Tagged3ScopeWidget extends StatefulWidget {
  const _Tagged3ScopeWidget({super.key});

  @override
  State<_Tagged3ScopeWidget> createState() => _Tagged3ScopeWidgetState();
}

class _Tagged3ScopeWidgetState extends State<_Tagged3ScopeWidget>
    with TaggedScopeSubscriberMixin<ISome3Scope, _Tagged3ScopeWidget> {
  @override
  Object? get scopeTag => widget.key;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
