import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scope_manager/src/base/dependency_scope.dart';
import 'package:scope_manager/src/base/scope_resolver.dart';
import 'package:scope_manager/src/widgets/scope_subscriber_mixin.dart';
import 'package:scope_manager/src/widgets/scopes.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(_MockFeatureScope());
  });

  group('ScopeSubscriberMixin', () {
    late _MockScopeResolver resolver;
    late _MockFeatureScope scope;

    setUp(() {
      resolver = _MockScopeResolver();
      scope = _MockFeatureScope();
      when(() => resolver.getScope<_MockFeatureScope>()).thenReturn(scope);
    });

    testWidgets(
      'shoudld subscribe when included in tree and ansubscribe after removing',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scopes(
              resolver: resolver,
              child: const _TestWidget(),
            ),
          ),
        );

        verify(() => resolver.subscribeToScope<_MockFeatureScope>(any()))
            .called(1);

        await tester.pumpWidget(
          Scopes(
            resolver: resolver,
            child: const SizedBox(),
          ),
        );
        verify(() => resolver.unsubscribeFromScope<_MockFeatureScope>(any()))
            .called(1);
      },
    );

    testWidgets('should get scope from resolver', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scopes(
            resolver: resolver,
            child: const _TestWidget(),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.pumpAndSettle();

      verify(() => resolver.getScope<_MockFeatureScope>()).called(1);
    });
  });

  group('TaggedScopeSubscriberMixin', () {
    late _MockScopeResolver resolver;
    late _MockFeatureScope scope;
    const tag = 'test-tag';

    setUp(() {
      resolver = _MockScopeResolver();
      scope = _MockFeatureScope();
      when(() => resolver.getScope<_MockFeatureScope>(tag: tag))
          .thenReturn(scope);
    });

    testWidgets(
      'shoudld subscribe when included in tree and ansubscribe after removing',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scopes(
              resolver: resolver,
              child: const _TaggedTestWidget(tag: tag),
            ),
          ),
        );

        verify(
          () => resolver.subscribeToScope<_MockFeatureScope>(
            any(),
            tag: tag,
          ),
        ).called(1);

        await tester.pumpWidget(
          Scopes(
            resolver: resolver,
            child: const SizedBox(),
          ),
        );
        verify(
          () => resolver.unsubscribeFromScope<_MockFeatureScope>(
            any(),
            tag: tag,
          ),
        ).called(1);
      },
    );

    testWidgets('should get scope from resolver', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scopes(
            resolver: resolver,
            child: const _TaggedTestWidget(tag: tag),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.pumpAndSettle();

      verify(() => resolver.getScope<_MockFeatureScope>(tag: tag)).called(1);
    });
  });
}

class _MockScopeResolver extends Mock implements ScopeResolver {}

class _MockFeatureScope extends Mock implements FeatureScope {}

class _TestWidget extends StatefulWidget {
  const _TestWidget();

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget>
    with ScopeSubscriberMixin<_MockFeatureScope, _TestWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          scope;
        },
        child: const Text('get'),
      ),
    );
  }
}

class _TaggedTestWidget extends StatefulWidget {
  final Object tag;

  const _TaggedTestWidget({required this.tag});

  @override
  State<_TaggedTestWidget> createState() => _TaggedTestWidgetState();
}

class _TaggedTestWidgetState extends State<_TaggedTestWidget>
    with TaggedScopeSubscriberMixin<_MockFeatureScope, _TaggedTestWidget> {
  @override
  Object? get scopeTag => widget.tag;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          scope;
        },
        child: const Text('get'),
      ),
    );
  }
}
