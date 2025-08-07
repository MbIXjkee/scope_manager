import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scope_manager/scope_manager.dart';
import 'package:scope_manager/src/base/scope_observer.dart';

class ObservingInfo extends StatelessWidget {
  final ScopeObserver observer;

  const ObservingInfo({
    super.key,
    required this.observer,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _Subscibers(publisher: observer.subscribersPublisher),
        _Scopes(publisher: observer.scopesPublisher),
      ],
    );
  }
}

class _Subscibers extends StatelessWidget {
  final Stream<Map<Type, Map<Object?, Set<Object>>>> publisher;

  const _Subscibers({required this.publisher});

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Subscribers:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        StreamBuilder(
          stream: publisher,
          builder: (context, value) {
            if (!value.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = value.data;

            if (data == null || data.isEmpty) {
              return const Center(child: Text('No subscribers'));
            }

            return Column(
              children: data.entries.map(
                (entry) {
                  final type = entry.key;
                  final subscribers = entry.value;
                  return ExpansionTile(
                    title: Text(type.toString()),
                    children: subscribers.entries.map((subEntry) {
                      final key = subEntry.key;
                      final subscriberSet = subEntry.value;
                      return ListTile(
                        title:
                            Text('$key: ${subscriberSet.length} subscribers'),
                      );
                    }).toList(),
                  );
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _Scopes extends StatelessWidget {
  final Stream<Map<Type, Map<Object?, FeatureScope>>> publisher;

  const _Scopes({required this.publisher});

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Scopes:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        StreamBuilder(
          stream: publisher,
          builder: (context, value) {
            if (!value.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = value.data;

            if (data == null || data.isEmpty) {
              return const Center(child: Text('No active scopes'));
            }

            return Column(
              children: data.entries.map(
                (entry) {
                  final type = entry.key;
                  final scopes = entry.value;
                  return ExpansionTile(
                    title: Text(type.toString()),
                    children: scopes.entries.map((scopeEntry) {
                      final key = scopeEntry.key;
                      final scope = scopeEntry.value;
                      return ListTile(
                        title: Text('$key: ${scope.runtimeType}'),
                      );
                    }).toList(),
                  );
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }
}
