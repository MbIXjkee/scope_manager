import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scope_manager/scope_manager.dart';

void main() {
  group('ObservingInfo', () {
    late ScopeManager sm;

    setUpAll(() async {
      sm = ScopeManager.test();
      final root = _TestRootScope();

      await sm.init(
        root,
        bindings: [
          ScopeBinding<_TestFeatureScope>(
            (resolver) => _TestFeatureScope(resolver: resolver),
          ),
        ],
      );

      sm.setObservability(isObservable: true);
    });

    testWidgets(
      'shoudld show information about scopes and subscribers',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ObservingInfo(
                observer: sm,
              ),
              floatingActionButton: const CircularProgressIndicator(),
            ),
          ),
        );

        await tester.pump();

        expect(
          find.text('_TestFeatureScope'),
          findsNothing,
        );

        const subscriber = 'ScopeSub';
        sm.subscribeToScope<_TestFeatureScope>(subscriber);

        await tester.pump();
        await tester.pump();

        expect(
          find.text('_TestFeatureScope'),
          findsExactly(2),
        );
        expect(
          find.text(subscriber),
          findsOneWidget,
        );

        sm.unsubscribeFromScope<_TestFeatureScope>(subscriber);

        await tester.pump();
        await tester.pump();

        expect(
          find.text('_TestFeatureScope'),
          findsNothing,
        );

        const subscriber2 = 'ScopeSub2';
        const tag = 'scopeTag';
        sm.subscribeToScope<_TestFeatureScope>(subscriber2, tag: tag);

        await tester.pump();
        await tester.pump();

        expect(
          find.text('_TestFeatureScope'),
          findsExactly(2),
        );
        expect(
          find.text(subscriber2),
          findsOneWidget,
        );
        expect(
          find.byWidgetPredicate((widget) {
            return widget is Text && (widget.data?.contains(tag) ?? false);
          }),
          findsOneWidget,
        );
      },
    );
  });
}

class _TestRootScope implements RootScope {
  @override
  Future<void> init() async {}
}

class _TestFeatureScope extends BaseFeatureScope {
  _TestFeatureScope({required super.resolver});

  @override
  void dispose() {}
}
