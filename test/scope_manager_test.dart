// For test convenience purposes
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:scope_manager/scope_manager.dart';

/// Tests of the [ScopeManager].
void main() {
  late _TestRoot root;
  late ScopeManager sm;

  group('Scope manager initialization', () {
    setUp(() {
      root = _TestRoot();
      sm = ScopeManager.test();
    });

    test('should throw if init was not called', () {
      expect(
        () => sm.getScope<_TestFeatureAScope>(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('ScopeManager is not initialized'),
          ),
        ),
      );
    });

    test('should call initialization of passed root scope', () async {
      expect(root.isInit, isFalse);

      await sm.init(root);

      expect(root.isInit, isTrue);
    });

    test('should throw if initialized more than once', () async {
      await sm.init(root);

      await expectLater(
        () => sm.init(root),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('ScopeManager is already initialized'),
        )),
      );
    });

    test('should register passed scope bindings', () async {
      await sm.init(
        root,
        bindings: [
          ScopeBinding<_TestFeatureAScope>(
            (resolver) => _TestFeatureAScope(resolver: resolver),
          ),
          ScopeBinding<_TestFeatureBScope>(
            (resolver) => _TestFeatureBScope(resolver: resolver),
          ),
        ],
      );
      final subscriber = Object();

      sm
        ..subscribeToScope<_TestFeatureAScope>(subscriber)
        ..subscribeToScope<_TestFeatureBScope>(subscriber);

      final scopeA = sm.getScope<_TestFeatureAScope>();
      final scopeB = sm.getScope<_TestFeatureBScope>();

      expect(scopeA, isNotNull);
      expect(scopeB, isNotNull);
    });
  });

  group(
    'Scope registration',
    () {
      setUp(() async {
        root = _TestRoot();
        sm = ScopeManager.test();
        await sm.init(root);
      });

      test('should register scope factory', () {
        sm.registerScopeFactory<_TestFeatureAScope>(
          (resolver) => _TestFeatureAScope(resolver: resolver),
        );
        final subscriber = Object();

        sm.subscribeToScope<_TestFeatureAScope>(subscriber);

        final scope = sm.getScope<_TestFeatureAScope>();

        expect(scope, isNotNull);
      });

      test('should register scope binding', () {
        sm.registerScopeBinding<_TestFeatureBScope>(
          ScopeBinding<_TestFeatureBScope>(
            (resolver) => _TestFeatureBScope(resolver: resolver),
          ),
        );
        final subscriber = Object();

        sm.subscribeToScope<_TestFeatureBScope>(subscriber);

        final scope = sm.getScope<_TestFeatureBScope>();

        expect(scope, isNotNull);
      });
    },
  );

  group(
    'Scope sub/unsub and get',
    () {
      setUp(() async {
        root = _TestRoot();
        sm = ScopeManager.test();
        await sm.init(
          root,
          bindings: [
            ScopeBinding<_TestFeatureAScope>(
              (resolver) => _TestFeatureAScope(resolver: resolver),
            ),
            ScopeBinding<_TestFeatureBScope>(
              (resolver) => _TestFeatureBScope(resolver: resolver),
            ),
          ],
        );
        sm.setObservability(isObservable: true);
      });

      test('should throw if generic interfaces were used', () {
        expect(
          () => sm.subscribeToScope<FeatureScope>({}),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains(
                'Do not use interfaces like DependencyScope, RootScope or FeatureScope directly.',
              ),
            ),
          ),
        );
        expect(
          () => sm.unsubscribeFromScope<FeatureScope>({}),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains(
                'Do not use interfaces like DependencyScope, RootScope or FeatureScope directly.',
              ),
            ),
          ),
        );
        expect(
          () => sm.getScope<RootScope>(),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains(
                'Do not use interfaces like DependencyScope, RootScope or FeatureScope directly.',
              ),
            ),
          ),
        );
      });

      test('should throw if subscribe with ScopeManager itself', () {
        expect(
          () => sm.subscribeToScope<_TestFeatureAScope>(sm),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains(
                'All subscriptions on behalf of ScopeManager itself are managed internally.',
              ),
            ),
          ),
        );
      });

      test('subsciber should be hold after subscription (without tag)', () {
        final subscriber = Object();

        sm.subscribeToScope<_TestFeatureAScope>(subscriber);

        final subscribers = sm.subscribersPublisher.value;
        expect(subscribers.length, 1);
        final featureAsubs = subscribers[_TestFeatureAScope];
        expect(featureAsubs, isNotNull);
        expect(featureAsubs!.length, 1);
        final tagSubscribers = featureAsubs[null];
        expect(tagSubscribers, isNotNull);
        expect(tagSubscribers!.contains(subscriber), isTrue);
      });

      test('subsciber should be hold after subscription (with tag)', () {
        final subscriber = Object();
        const tag = 'tag';

        sm.subscribeToScope<_TestFeatureAScope>(subscriber, tag: tag);

        final subscribers = sm.subscribersPublisher.value;
        expect(subscribers.length, 1);
        final featureAsubs = subscribers[_TestFeatureAScope];
        expect(featureAsubs, isNotNull);
        expect(featureAsubs!.length, 1);
        final tagSubscribers = featureAsubs[tag];
        expect(tagSubscribers, isNotNull);
        expect(tagSubscribers!.contains(subscriber), isTrue);
      });

      test('should provide scope after subscription', () {
        final subscriber = Object();

        sm.subscribeToScope<_TestFeatureAScope>(subscriber);

        final scope = sm.getScope<_TestFeatureAScope>();

        expect(scope, isNotNull);
      });

      test('should not provide scope without subscription', () {
        expect(
          () => sm.getScope<_TestFeatureAScope>(),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('Reauested scope is not created'),
            ),
          ),
        );
      });

      test('should remove subscriber after unsubscription', () {
        final subscriber = Object();

        sm.subscribeToScope<_TestFeatureAScope>(subscriber);

        expect(sm.subscribersPublisher.value.length, 1);

        sm.unsubscribeFromScope<_TestFeatureAScope>(subscriber);

        expect(sm.subscribersPublisher.value.length, 0);
      });
    },
  );

  group('Observability', () {
    setUp(() async {
      root = _TestRoot();
      sm = ScopeManager.test();
      await sm.init(
        root,
        bindings: [
          ScopeBinding<_TestFeatureAScope>(
            (resolver) => _TestFeatureAScope(resolver: resolver),
          ),
          ScopeBinding<_TestFeatureBScope>(
            (resolver) => _TestFeatureBScope(resolver: resolver),
          ),
        ],
      );
    });

    test('should publish updates when observable', () {
      sm.setObservability(isObservable: false);

      final subscriber = Object();
      sm.subscribeToScope<_TestFeatureAScope>(subscriber);

      expect(sm.subscribersPublisher.value.length, 0);
      expect(sm.scopesPublisher.value.length, 0);

      sm.setObservability(isObservable: true);

      expect(sm.subscribersPublisher.value.length, 1);
      expect(sm.scopesPublisher.value.length, 1);
    });
  });
}

class _TestRoot implements RootScope {
  var _isInit = false;

  bool get isInit => _isInit;

  @override
  Future<void> init() async {
    _isInit = true;
  }
}

class _TestFeatureAScope extends BaseFeatureScope {
  _TestFeatureAScope({required super.resolver});

  @override
  void dispose() {}
}

class _TestFeatureBScope extends BaseFeatureScope {
  _TestFeatureBScope({required super.resolver});

  @override
  void dispose() {}
}
