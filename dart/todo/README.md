# Rid Todo Example

An example todo app with user interaction implemented in Dart and app logic in Rust.

## Getting Started

_Please see [Caveats](#Caveats) first_.

```sh
./sh/build
./sh/run
```

Repeat the first step every time you modify Rust code.

## Rid Model 

What the Model annotations communicate to _rid_:

```rust
#[rid::model]                 // this is a model and all its fields should be accessible from Dart
#[rid::structs(Todo)]         // the referenced Todo type is a struct
#[rid::enums(Filter)]         // the referenced Filter type is an enum
#[derive(Debug)]              // expose a `model.debug(pretty?)` function to Dart 
pub struct Model {
    last_added_id: u32,
    todos: Vec<Todo>,
    filter: Filter,
}
```

Possible Model use in Dart code:

```dart
final filter = model.filter;
for (final todo in model.todos.iter()) {
  // do something
}
```

## Rid Message

How to setup sending messages to the _Model_ via _rid_:

```rust
#[rid::message(Model)]    // this is a message that will update the model
#[rid::enums(Filter)]     // the referenced Filter type is an enum
pub enum Msg {
    AddTodo(String),      // sent via Dart: model.msgAddTodo("Learn Rid");

    ToggleTodo(u32),      // sent via Dart: model.msgToggleTodo(todoId);
    CompleteAll,          // sent via Dart: model.msgCompleteAll();

    SetFilter(Filter),    // sent via Dart: model.msgSetFilter(RidFilter.index);
}

impl Model {
    fn update(&mut self, msg: Msg) {
      // handle the message here
    }
}
```

## Exporting Methods

```rust
#[rid::export]                      // rid will scan this impl block for exports
impl Model {
    #[rid::export(initModel)]       // exports this method to be called via Dart: rid_ffi.initModel(); 
    fn new() -> Self {
        Self {
            last_added_id: 0,
            todos: vec![],
            filter: Filter::All,
        }
    }
}
```

## Caveats

At this point _Rid_ hasn't been published, therefore the build step cannot be performed and
this example only serves to demonstrate what is possible once it _is_ published and open
sourced.

For more information please see [_Is Rid Open Sourced?_](../../README.md#is-rid-open-sourced)
