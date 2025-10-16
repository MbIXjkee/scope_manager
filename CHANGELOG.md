## Unreleased
### Added
* RootBinding that allows to specify the type associated with the RootScope instance.

## 0.1.1
### Added
* Package meta information.

## 0.1.0
### Added
* Documentation for classes and detailed Readme.
### Changed
* Observability controll moved to a separate method setObservability.

## 0.0.4
### Added
* Scope Manager can be observed, for debug purpose.
* Widget showing current state of scopes and subscribers, for debug purpose.
* Removing emptied groups when unsubscribe.
### Fixed
* Problem with state mixin, that didn't provide a subscribing type correctly.
* Subscribing to the same scope with different tags do not override list of holded scopes anymore.
* Incorrect type definition during factories registration while init.

## 0.0.3
### Fixed
* Feature scope registration and subscibing type-related issues.

## 0.0.2
### Added
* ScopeResolver provided in ScopeFactory signature.

## 0.0.1
### Info
* Initial release, code is experimental and might be unstable.

### Added
* Basic features of defining and managing scopes.