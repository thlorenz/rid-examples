# Todo App

Rust integrated Dart Flutter Project

## Tutorial

A tutorial on how to build this app will be provided shortly on the [rid
homepage](https://thlorenz.com/rid-site/docs/examples/flutter-todo-app/).

## Getting Started

_Please see [Caveats](#Caveats) first_.

Use the below scripts to get the app ready to run with Flutter.

### 1. Generate Glue Code

```sh
./sh/bindgen
```

### 2. Build For Desired Target/Device

Run any of the below three to build the binary for the specific device and have it placed into
the devices specific plugin folder.

```sh
./sh/macos
```

### 3. Run with Flutter

Run on the device.

```sh
flutter run -d macos
```

### 4. Develop

Run step `1` whenever a function exposed to Flutter changes.

Run step `2` whenever any of your Rust code changes.

**Note** that to apply changes from Rust you need to restart the app to reload the compiled binary.
A hot restart/reload does not achieve this.

## Folder Structure

```
├── android
├── ios
├── macos
├── lib
├── plugin
│   ├── android
│   ├── ios
│   ├── macos
│   └── lib
└── src
```

### `./plugin`

Provides connection from Flutter to Rust.

Rust binaries are placed into the respective plugin folders `./ios, ./macos, ./android` when
they are built.

Generated Dart glue code is placed inside `./plugin/lib/generated` while
`./plugin/lib/plugin.dart` just exposes the API to the app.

### `./src`

Contains the starter Rust code inside `./src/lib.rs`. Keep developing the Rust part of your app
here.

### `./lib`

Contains the starter Flutter app inside `./lib/main.dart`.

### `./sh`

Provides scripts to run build and code generation tasks. In the future a tool will provide the
functionality currently provided by these scripts.

- `bindgen` generates the `binding.h` header file for the extern Rust functions found inside
  `./src`. These are then placed inside the `./plugin` device folders were needed as well as
  `./plugin/lib/generated/binding.h` where they are used to generate Dart glue code
- `ffigen` generates Dart glue code inside `./plugin/lib/generated/ffigen_binding.dart` using
  `./plugin/lib/generated/binding.h` as input
- `./android` builds the Rust binary to run on Android devices/emulators and places it inside
  `./plugin/lib/android`
- `./ios` builds the Rust binary to run on IOS devices/emulators and places it inside
  `./plugin/lib/ios`
- `./macos` builds the Rust binary to run on MacOs directly and places it inside
  `./plugin/lib/macos`, this is the same format as running `cargo build` on your Mac

## Caveats

At this point _Rid_ hasn't been published, therefore the build step cannot be performed and
this example only serves to demonstrate what is possible once it _is_ published and open
sourced.

For more information please see [_Is Rid Open Sourced?_](../../README.md#is-rid-open-sourced)
