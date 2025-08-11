import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:scope_manager/scope_manager.dart';
import 'package:scope_manager/src/base/scope_observer.dart';

class ObservingInfo extends StatefulWidget {
  final ScopeObserver observer;

  const ObservingInfo({
    super.key,
    required this.observer,
  });

  @override
  State<ObservingInfo> createState() => _ObservingInfoState();
}

class _ObservingInfoState extends State<ObservingInfo> {
  final _subs = ValueNotifier<Map<Type, Map<Object?, Set<Object>>>>({});
  final _scopes = ValueNotifier<Map<Type, Map<Object?, FeatureScope>>>({});

  @override
  void initState() {
    super.initState();

    // updates of these publishers often happen during build phase,
    // so need to be postponed to not break build pipeline.
    widget.observer.subscribersPublisher.addListener(
      _scheduleUpdateSubscribers,
    );
    widget.observer.scopesPublisher.addListener(
      _scheduleUpdateScopes,
    );
  }

  @override
  void dispose() {
    widget.observer.subscribersPublisher.removeListener(
      _scheduleUpdateSubscribers,
    );
    widget.observer.scopesPublisher.removeListener(
      _scheduleUpdateScopes,
    );

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ObservingInfo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.observer != widget.observer) {
      oldWidget.observer.subscribersPublisher.removeListener(
        _scheduleUpdateSubscribers,
      );
      oldWidget.observer.scopesPublisher.removeListener(
        _scheduleUpdateScopes,
      );

      widget.observer.subscribersPublisher.addListener(
        _scheduleUpdateSubscribers,
      );
      widget.observer.scopesPublisher.addListener(
        _scheduleUpdateScopes,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _Subscibers(publisher: _subs),
        _Scopes(publisher: _scopes),
      ],
    );
  }

  void _scheduleUpdateSubscribers() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _subs.value = widget.observer.subscribersPublisher.value;
      }
    });
  }

  void _scheduleUpdateScopes() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scopes.value = widget.observer.scopesPublisher.value;
      }
    });
  }
}

class _Subscibers extends StatelessWidget {
  final ValueListenable<Map<Type, Map<Object?, Set<Object>>>> publisher;

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
        ValueListenableBuilder(
          valueListenable: publisher,
          builder: (context, value, _) {
            if (value.isEmpty) {
              return const Center(child: Text('No subscribers'));
            }

            return Column(
              spacing: 4,
              children: value.entries
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
      initiallyExpanded: true,
      title: Text(name),
      children: taggedSubscribers.entries.map((subEntry) {
        final key = subEntry.key;
        final tag = key == null ? 'untagged' : key.toString();
        final subscriberSet = subEntry.value;

        return ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '<$tag>',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${subscriberSet.length} subs',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
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
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
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
  final ValueListenable<Map<Type, Map<Object?, FeatureScope>>> publisher;

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
        ValueListenableBuilder(
          valueListenable: publisher,
          builder: (context, value, _) {
            if (value.isEmpty) {
              return const Center(child: Text('No active scopes'));
            }

            return Column(
              spacing: 4,
              children: value.entries.map(
                (entry) {
                  final type = entry.key;
                  final scopes = entry.value;

                  return _Scope(type: type, scopes: scopes);
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _Scope extends StatelessWidget {
  final Type type;
  final Map<Object?, FeatureScope> scopes;

  const _Scope({
    required this.type,
    required this.scopes,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(type.toString()),
      children: scopes.entries.map((scopeEntry) {
        final key = scopeEntry.key;
        final tag = key == null ? 'untagged' : key.toString();
        final scope = scopeEntry.value;

        return ListTile(
          title: Row(
            children: [
              Text(
                '<$tag>:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${scope.runtimeType}',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
