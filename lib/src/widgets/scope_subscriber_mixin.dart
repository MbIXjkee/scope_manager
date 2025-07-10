import 'package:flutter/material.dart';
import 'package:scope_manager/src/base/dependency_scope.dart';
import 'package:scope_manager/src/base/scope_resolver.dart';
import 'package:scope_manager/src/widgets/scopes.dart';

mixin ScopeSubscriberMixin<S extends FeatureScope, W extends StatefulWidget>
    on State<W> {
  late ScopeResolver _resolver;

  S get scope => _resolver.getScope<S>();

  @override
  void initState() {
    super.initState();

    _resolver = Scopes.of(context);
    _resolver.subscribeToScope<S>(this);
  }

  @override
  void dispose() {
    _resolver.unsubscribeFromScope(this);

    super.dispose();
  }
}

mixin TaggedScopeSubscriberMixin<S extends FeatureScope,
    W extends StatefulWidget> on State<W> {
  late ScopeResolver _resolver;

  Object? get scopeTag;

  S get scope => _resolver.getScope<S>(tag: scopeTag);

  @override
  void initState() {
    super.initState();

    _resolver = Scopes.of(context);
    _resolver.subscribeToScope<S>(this, tag: scopeTag);
  }

  @override
  void dispose() {
    _resolver.unsubscribeFromScope<S>(this, tag: scopeTag);

    super.dispose();
  }
}
