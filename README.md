# rid-examples

Examples showing how to use [**Rid**](https://thlorenz.com/rid-site/) in order to build Dart/Flutter apps integrated with Rust.

## What is Rid?

_Rid_ stands for _Rust integrates Dart_ and is a tool I am working on that allows to call Rust
functions from Dart and Flutter applications by simply annotating them.
Its main goal is to **make it super easy to implement your UI in Flutter and the logic in
Rust**.

This in turn allows you to benefit from the respective strength of each platform.

Learn more by following the [Getting
Started](https://thlorenz.com/rid-site/docs/getting-started/introduction/) guide.

## How does Rid work?

_Rid_ consumes the annotations added to your Rust code to generate all the
[FFI](https://doc.rust-lang.org/nomicon/ffi.html) boilerplate to interact with them from Dart
/Flutter.

Additionally it generates extension methods on entities, such as _models_ in order to expose an
API on the Dart/Flutter end that is super fun to work with.

Learn more _rids_ [application
architecture](https://thlorenz.com/rid-site/docs/getting-started/architecture/).

## Examples

### Flutter

- [Todo App](./flutter/todo)

### Dart Only

- [Command Line Todo App](./dart/todo)

## Is Rid open sourced?

_Rid_ is _[Sponsorware](https://github.com/sponsorware/docs)_ and thus not open sourced yet. 

Please [learn more here](https://thlorenz.com/rid-site/docs/contributing/sponsor/) about how
you can [sponsor rid via a monthly contribution](https://github.com/sponsors/thlorenz) and when
_rid_ will be fully open sourced.

## LICENSE

MIT
