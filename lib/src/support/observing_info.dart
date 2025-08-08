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
              children: data.entries
                  .map(
                    (entry) => _ScopeGroupSubscribers(
                      name: entry.key.toString(),
                      taggedSubscribers: entry.value,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ScopeGroupSubscribers extends StatelessWidget {
  final String name;
  final Map<Object?, Set<Object>> taggedSubscribers;

  const _ScopeGroupSubscribers({
    required this.name,
    required this.taggedSubscribers,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(name),
      children: taggedSubscribers.entries.map((subEntry) {
        final key = subEntry.key;
        final tag = key == null ? 'untagged' : key.toString();
        final subscriberSet = subEntry.value;

        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$tag: ${subscriberSet.length} subscribers'),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        width: 2,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Wrap(
                      children: subscriberSet
                          .map(
                            (e) => Text(
                              e.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }).toList(),
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
