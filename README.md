# rid-examples

Examples showing how to use **Rid** in order to build Dart/Flutter apps integrated with Rust.

## What is Rid?

_Rid_ stands for _Rust integrates Dart_ and is a tool I am working on that allows to call Rust
functions from Dart and Flutter applications by simply annotating them.
Its main goal is to **make it super easy to implement your UI in Flutter and the logic in
Rust**.

This in turn allows you to benefit from the respective strength of each platform.

## How does Rid work?

_Rid_ consumes the annotations added to your Rust code to generate all the
[FFI](https://doc.rust-lang.org/nomicon/ffi.html) boilerplate to interact with them from Dart
/Flutter.

Additionally it generates extension methods on entities, such as _models_ in order to expose an
API on the Dart/Flutter end that is super fun to work with.

## Examples

### Dart

- [Command Line Todo App](./dart/todo)

### Flutter

## Is Rid open sourced?

_Rid_ is _[Sponsorware](https://calebporzio.com/sponsorware)_ and thus not open sourced yet. 

You [can sponsor me](https://github.com/sponsors/thlorenz) via a monthly contribution and **gain
immediate access** to the currently private [_rid_](https://github.com/thlorenz/rid) repository once you pledge sponsorship.

**I will fully open source _rid_ to everyone once I reach 50 sponsors**.

By [sponsoring me](https://github.com/sponsors/thlorenz) you not only show your appreciation
for all the work that went into _rid_ already, but also **help me evolve, stabilize and
maintain** it.

I greatly appreciate it. 🙏 ❤️

## LICENSE

MIT
