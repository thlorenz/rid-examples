# Twitch Cubit Todo

## Intro

- show app
- we'll most likely build parts of it focusing on multi threading and leveraging the higher
  level API with cubits
- remaining parts at github

### Miro

- walk through [miro](https://miro.com/app/board/o9J_l9TpJQI=/)
- explain how multi threaded apps work while providing memory safety

#### 1

- app starting up
- get Todos
- `TodosCubit` has list of `Todo` which is a Dart list of Dart class instances
- converted for us behind the scenes to guarantee memory safety
- **Rust provides that safety**, but once we leave it and re-enter from Dart we lost the guarantees
- rid locks the store for reading for us when retrieving Todos to ensure no other thread can
  write to it while we perform this step

#### 2

- render the Todos

#### 3 

- toggle Todo
- **we never directly mutate** the store from Dart
- send messages to it instead
- rid receives the message and locks store for writing
- no other thread can read from nor write to it
- store update receives `mut Store` and while it runs, the Store remains locked
- **Flutter is `await` ing** the completion of the action triggered by sending the message
- when Todo toggled Rust posts a _toggled_ reply with the `req_id` included in the message
- Flutter `TodoCubit` now knows that that message has been handled and retrieves the updated
  Todo state
- while that is going on the Store is read locked and we get a Dart Todo instance back

#### 4

- Todo is now re-rendered with completed checked

#### 5

- user configures to auto expire completed Todos
- SettingsCubit sends message to Store which updates the settings
- activates ticker thread
- and posts reply causing Todo to re-render with expire progress bar -> (6)
- expiry ticker thread is now active and starts ticking down the life of completed todos
- everytime it updates a Todo it aquires a write lock on the Store to make sure no other thread
  is reading todos while they're modified

#### 7

- TodoCubit listening on reply channel stream for tick updates for its todo
- receives todo tick
- gets updated todo state from store (with locked store)

#### 8

- another tick update .. Todo about to expire

#### 9

- another Todo tick and Todo expired
- TodoCubit tries to retrieve state of Todo
- ticker thread wants to remove expired Todo and aquired write lock, causing resolution of Todo
  state to wait until that step is complete and it can aquire a read lock
- now the Todo isn't found anymore and we return `null`, could show an empty container also

#### 10

- TodosCubit receives TodoExpired reply
- gets latest state of filtered todos which no longer includes our Todo
- renders todos without it

If we would not read-lock the store and allow to use a pointer of a Todo that might have been
removed in the meantime making the pointer invalid we'd run into all kinds of trouble most
likely causing the app to crash.

## Counter Start

- show app and point out logs
- point out debug feature since we won't use that most likely in the todo
