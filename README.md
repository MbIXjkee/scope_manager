<p align="center">
    <a href="https://github.com/MbIXjkee"><img src="https://img.shields.io/badge/Owner-mbixjkee-blueviolet.svg" alt="Owner"></a>
    <a href="https://pub.dev/packages/scope_manager"><img src="https://img.shields.io/pub/v/scope_manager?logo=dart&logoColor=white" alt="Pub Version"></a>
    <a href="https://pub.dev/packages/scope_manager"><img src="https://badgen.net/pub/points/scope_manager" alt="Pub points"></a>
    <a href="https://pub.dev/packages/scope_manager"><img src="https://badgen.net/pub/likes/scope_manager" alt="Pub Likes"></a>
    <a href="https://pub.dev/packages/scope_manager"><img src="https://img.shields.io/pub/dm/scope_manager" alt="Downloads"></a>
    <!-- TODO: codecov -->
    <a href="https://github.com/MbIXjkee/scope_manager/graphs/contributors"><img src="https://badgen.net/github/contributors/MbIXjkee/scope_manager" alt="Contributors"></a>
    <a href="https://github.com/MbIXjkee/scope_manager/blob/main/LICENSE"><img src="https://badgen.net/github/license/MbIXjkee/scope_manager" alt="License"></a>
</p>

---

# Overview

Scope Manager is a lightweight lifecycle manager for dependency scopes in Flutter apps. It helps you group and control dependencies by lifetime (app-wide vs. feature-specific), automatically creating groups of dependencies when needed and disposing them when they’re no longer used.

# Core concepts

### DependencyScope

DependencyScope is a group of dependencies that share the same lifecycle. There are
two types of scopes in this package:

  - **RootScope**: lives throughout the entire app lifecycle. Usually
    contains dependencies that should always be alive. This is a single-instance scope for the whole application, it has asynchronous initialization support,
    and is never been destroyed.

  - **FeatureScope**: created on demand and destroyed when no longer needed.
    A group of dependencies that share similar temporal reasoning for existence:
    an authenticated application zone, or part of the specific feature. Application
    can have multiple types of this scope, related to various features; many instances of the same scope, or don't have any.

There is no requirements how exactly to implement a scope. You can create a simple class with manual implementation or use any 3rd party libraries.

### ScopeManager

ScopeManager is a central management class responsible for handling scopes existence. It holds and analizes subscriptions to specific scopes, and based on stakeholder existance creates and destroys scopes.

The rules are simple:

  - When the first subscription to a specific scope type is added, the manager creates a new instance of this scope.

  - When the last subscription to a specific scope type is removed, the manager destroys this scope instance.
  
# How to use

In this block you'll find a step-by-step guide to integrate Scope Manager into your Flutter application.

### Create RootScope

Create a class that implements `RootScope` interface. This class will hold all your app-wide dependencies.
You can implement this class in any way you prefer, even use a 3rd party library, but in this examaple it is the most straightforward one - a simple Dart class that uses just language capabilities.

```dart
/// App level dependencies.
abstract interface class IAppScope implements RootScope {
  /// Environment configuration.
  Environment get env;

  /// Navigation manager.
  Coordinator get coordinator;

  /// Authentication service for managing user sessions.
  IAuthService get authService;

  /// Returns a new instance of [Foo] all the time.
  Foo fooFactory();
}

/// Scope of dependencies which need through all app's lifecycle.
class AppScope implements IAppScope {
  late final _env = Environment.instance;
  late final _baseClient = _initHttpClient();

  // repositories
  late final _authRepository = AuthRepository(
    httpClient: _baseClient,
  );

  // services
  late final _authSevice = AuthService(
    authRepository: _authRepository,
  );

  late final Coordinator _coordinator;

  @override
  Environment get env => _env;

  @override
  Coordinator get coordinator => _coordinator;

  @override
  IAuthService get authService => _authSevice;

  /// Create an instance of [AppScope].
  AppScope();

  @override
  Future<void> init() async {
    await _authSevice.init();

    _coordinator = Coordinator(
      guards: [],
    )..init();
  }

  @override
  Foo fooFactory() {
    return Foo();
  }

  BaseHttpClient _initHttpClient() {
    return BaseHttpClient(
      client: HttpClientFactory.instance.getClient(
        allowSelfSigned: _env.isDev,
      ),
    );
  }
}

```

### Create FeatureScopes

In the same manner, if necessary, create classes that implement `FeatureScope` interface. These classes will hold dependencies related to specific features or parts of your application.

The only difference is those classes have a dispose method, which will be called when the scope is no longer needed. In this method you should release all resources, close connections, etc.

```dart
  @override
  void dispose() {
    _bar.dispose();
  }
```

### Initialize ScopeManager

Before you run your app, you need to initialize the `ScopeManager` with your `RootScope` implementation and define how `FeatureScope`s should be created.

```dart
void main() async {
  // ....

  // Dependency injection setup.
  final scopeManager = ScopeManager.instance;
  await registerDependencies(scopeManager);

  runApp(
    App(scopeResolver: scopeManager),
  );
}

Future<void> registerDependencies(ScopeRegistry registry) async {
  final appScope = AppScope();

  await registry.init(appScope);

  registry.registerScopeBinding(
    ScopeBinding<IAuthenticatedScope>(
      (resolver) => AuthenticatedScope(resolver: resolver),
    ),
  );

  // ... etc
}

```

### Make ScopeManager available in the widget tree

Wrap your app with `Scopes` widget, which will make `ScopeManager` available to all its descendants.

```dart
/// Application widget.
class App extends StatelessWidget {
  final ScopeResolver scopeResolver;

  /// Creates an instance of [App].
  const App({
    super.key,
    required this.scopeResolver,
  });

  @override
  Widget build(BuildContext context) {
    return Scopes(
      resolver: scopeResolver,
      child: const _App(),
    );
  }
}
```

Now you can access methods to subscribe, unsubscribe and resolve dependencies from a widget in your app, using:

```dart
Scopes.of(context)
```

### Typical usage

Usually, there is some visuallity goes together with requirement for creating a scope. For example a screen, tab, etc. Because of this, the preferable way to interact with scopes is from a widget.

For making it convenient, there is `ScopeSubscriberMixin` for `State`. When you this mixin, it makes a mentioned `FeatureScope` required while the widget is in the widget tree, and releases it when the widget is removed. To access held scope, you can use `scope` property.

For example:

```dart
/// Widget that represents authenticated zone of the app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with ScopeSubscriberMixin<IAuthenticatedScope, HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Expanded(
            child: Placeholder(),
          ),
          Expanded(
            flex: 6,
            child: NavigationStack(
              coordinator: scope.coordinator,
            ),
          )
        ],
      ),
    );
  }
}
```

Despite the major usecase of subscribing from a widget, you can subscribe and unsubscribe manually from anywhere in your code. Just make sure to unsubscribe when the scope is no longer needed.

# Maintainer
<a href="https://github.com/MbIXjkee">
    <div style="display: inline-block;">
        <img src="https://i.ibb.co/6Hhpg5L/circle-ava-jedi.png" height="64" width="64" alt="Maintainer avatar">
        <p style="float:right; margin-left: 8px;">Mikhail Zotyev</p>
    </div>
</a>

# Support

We appreciate any form of support, whether it's a financial donation, a public sharing, or a star on GitHub and a like on Pub. If you want to provide financial support, there are several ways you can do it:

  - [GH Sponsors](https://github.com/sponsors/MbIXjkee)
  - [Buy me a coffee](https://buymeacoffee.com/mbixjkee)
  - [Patreon](https://www.patreon.com/MbIXJkee)
  - [Boosty](https://boosty.to/mbixjkee)

Thank you for all your support!

# License

This project is licensed under the MIT License. See [LICENSE](https://github.com/MbIXjkee/sliver_catalog/blob/main/LICENSE) for details.