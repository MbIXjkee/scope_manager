import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scope_manager/src/base/dependency_scope.dart';
import 'package:scope_manager/src/base/scope_resolver.dart';

void main() {
  group('BaseFeatureScope', () {
    late _MockScopeResolver resolver;
    late _TestFeatureScope testScope;

    setUp(() {
      resolver = _MockScopeResolver();
      testScope = _TestFeatureScope(resolver: resolver);
    });

    test('bindWith should subscribe and return scope from resolver', () {
      final dependency = _MockFeatureScope();
      when(() => resolver.getScope<_MockFeatureScope>()).thenReturn(dependency);

      final result = testScope.bindWith<_MockFeatureScope>();

      // Subscribed to the dependency scope with "this" as subscriber
      verify(() => resolver.subscribeToScope<_MockFeatureScope>(testScope))
          .called(1);
      // Requested the scope instance from resolver
      verify(() => resolver.getScope<_MockFeatureScope>()).called(1);
      expect(result, same(dependency));
    });

    test('unbindFrom should unsubscribe from resolver', () {
      testScope.unbindFrom<_MockFeatureScope>();

      verify(() => resolver.unsubscribeFromScope<_MockFeatureScope>(testScope))
          .called(1);
    });
  });
}

class _MockScopeResolver extends Mock implements ScopeResolver {}

class _MockFeatureScope extends Mock implements FeatureScope {}

class _TestFeatureScope extends BaseFeatureScope {
  _TestFeatureScope({required super.resolver});

  @override
  void dispose() {}
}
