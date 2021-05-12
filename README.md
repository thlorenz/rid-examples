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

## Is Rid open sourced?

_Rid_ is currently not open sourced as I'm looking into finding a way to sponsor it in order to be able
to maintain it once it is released.

My plan is to allow people to sponsor me monthly at which point they gain instant access to the
currently private [_rid_](https://github.com/thlorenz/rid) repository.

I will open source _rid_ once I reach a (yet to be determined) threshold of sponsors and feel confident that this will
allow me to keep evolving and maintaining the library.

You can [start sponsoring me](https://github.com/sponsors/thlorenz) in order to help me with
all the work going into it and get to the point were I can open source it ASAP. I greatly
appreciate it. 🙏 ❤️

## LICENSE

MIT
