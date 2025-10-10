import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scope_manager/src/base/dependency_scope.dart';
import 'package:scope_manager/src/base/scope_resolver.dart';
import 'package:scope_manager/src/widgets/scopes.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(_MockFeatureScope());
  });

  group('Scopes', () {
    late _MockScopeResolver mockResolver;

    setUp(() {
      mockResolver = _MockScopeResolver();
    });

    Widget buildTestWidget({required Widget child}) {
      return MaterialApp(
        home: Scopes(
          resolver: mockResolver,
          child: child,
        ),
      );
    }

    testWidgets('method of returns the correct resolver', (tester) async {
      late ScopeResolver foundResolver;

      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) {
              foundResolver = Scopes.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(foundResolver, isA<Scopes>());
    });

    testWidgets('getScope delegates to the resolver', (tester) async {
      final testScope = _MockFeatureScope();
      when(() => mockResolver.getScope<_MockFeatureScope>())
          .thenReturn(testScope);

      late _MockFeatureScope foundScope;

      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) {
              foundScope = Scopes.of(context).getScope<_MockFeatureScope>();
              return const SizedBox();
            },
          ),
        ),
      );

      expect(foundScope, equals(testScope));
      verify(() => mockResolver.getScope<_MockFeatureScope>()).called(1);
    });

    testWidgets('subscribeToScope delegates to the resolver', (tester) async {
      final subscriber = Object();
      when(
        () => mockResolver.subscribeToScope<_MockFeatureScope>(
          subscriber,
        ),
      ).thenReturn(null);

      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) {
              Scopes.of(context)
                  .subscribeToScope<_MockFeatureScope>(subscriber);
              return const SizedBox();
            },
          ),
        ),
      );

      verify(
        () => mockResolver.subscribeToScope<_MockFeatureScope>(
          subscriber,
        ),
      ).called(1);
    });

    testWidgets('unsubscribeFromScope delegates to the resolver',
        (tester) async {
      final subscriber = Object();
      when(
        () => mockResolver.unsubscribeFromScope<_MockFeatureScope>(
          subscriber,
        ),
      ).thenReturn(null);

      await tester.pumpWidget(
        buildTestWidget(
          child: Builder(
            builder: (context) {
              Scopes.of(context)
                  .unsubscribeFromScope<_MockFeatureScope>(subscriber);
              return const SizedBox();
            },
          ),
        ),
      );

      verify(
        () => mockResolver.unsubscribeFromScope<_MockFeatureScope>(
          subscriber,
        ),
      ).called(1);
    });
  });
}

class _MockScopeResolver extends Mock implements ScopeResolver {}

class _MockFeatureScope extends Mock implements FeatureScope {}
