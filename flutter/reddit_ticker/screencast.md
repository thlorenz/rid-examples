<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Sections](#sections)
  - [1. Introduce App](#1-introduce-app)
  - [2. Start App](#2-start-app)
  - [3. Reddit API Exploration](#3-reddit-api-exploration)
    - [JSON extension + Model Derival](#json-extension--model-derival)
    - [Smaller Response to extract ID](#smaller-response-to-extract-id)
  - [4. Implement Reddit Queries](#4-implement-reddit-queries)
  - [5. ureq to perform client requests](#5-ureq-to-perform-client-requests)
    - [`src/reddit/reddit.rs`](#srcredditredditrs)
  - [6. Quick Iteration via Dart Script](#6-quick-iteration-via-dart-script)
    - [`rid_build.rs`](#rid_buildrs)
    - [`sh/bindgen-dart`](#shbindgen-dart)
    - [`test/`](#test)
    - [`test/wip.dart`](#testwipdart)
  - [7. Complete Page Request and return Page struct](#7-complete-page-request-and-return-page-struct)
    - [`src/reddit/reddit.rs` added](#srcredditredditrs-added)
    - [`src/reddit/reddit.rs` added](#srcredditredditrs-added-1)
    - [`src/reddit/mod.rs`](#srcredditmodrs)
    - [`src/lib.rs`](#srclibrs)
  - [8. Post Score Request](#8-post-score-request)
    - [`src/reddit/reddit.rs`](#srcredditredditrs-1)
    - [`src/lib.rs`](#srclibrs-1)
    - [`test/wip.dart`](#testwipdart-1)
  - [9. Setting up the Store](#9-setting-up-the-store)
    - [`src/reddit/mod.rs`](#srcredditmodrs-1)
    - [`src/lib.rs`](#srclibrs-2)
      - [Initiating Store with Fake Post](#initiating-store-with-fake-post)
    - [`src/reddit/reddit.rs`](#srcredditredditrs-2)
    - [`test/wip.dart`](#testwipdart-2)
  - [10. Setting up Flutter App](#10-setting-up-flutter-app)
    - [Introduce Rid Messaging](#introduce-rid-messaging)
    - [Install Deps](#install-deps)
    - [Include Assets](#include-assets)
      - [`pubspec.yaml`](#pubspecyaml)
    - [App Skeleton](#app-skeleton)
      - [`lib/main.dart`](#libmaindart)
  - [11. Showing Posts in Flutter](#11-showing-posts-in-flutter)
    - [Post Cubit](#post-cubit)
      - [`lib/cubit/post_state.dart`](#libcubitpost_statedart)
      - [`lib/cubit/post_cubit.dart`](#libcubitpost_cubitdart)
    - [Posts Cubit](#posts-cubit)
      - [`lib/cubit/posts_state.dart`](#libcubitposts_statedart)
      - [`lib/cubit/posts_cubit.dart`](#libcubitposts_cubitdart)
    - [Post + Posts Views](#post--posts-views)
      - [`lib/views/post.dart`](#libviewspostdart)
      - [`lib/views/post.dart`](#libviewspostdart-1)
      - [`lib/main.dart`](#libmaindart-1)
  - [12. Showing Post Scores](#12-showing-post-scores)
    - [Adding Google Charts Dependency](#adding-google-charts-dependency)
      - [`pubspec.yaml`](#pubspecyaml-1)
    - [Mocking Sample Scores](#mocking-sample-scores)
      - [`./src/lib.rs`](#srclibrs)
      - [`./lib/views/post.dart`](#libviewspostdart)
  - [13. Start Watching Post from Reddit](#13-start-watching-post-from-reddit)
    - [`src/lib.rs`](#srclibrs-3)
    - [`lib/cubit/add_post_state.dart`](#libcubitadd_post_statedart)
    - [`lib/cubit/add_post_cubit.dart`](#libcubitadd_post_cubitdart)
    - [`lib/views/add_post.dart`](#libviewsadd_postdart)
    - [`lib/main.dart`](#libmaindart-2)
    - [First Run](#first-run)
    - [`lib/cubit/posts_cubit.dart`](#libcubitposts_cubitdart-1)
  - [14. Stop Watching Post](#14-stop-watching-post)
    - [`lib/cubit/post_state.dart`](#libcubitpost_statedart-1)
    - [`lib/cubit/post_cubit.dart`](#libcubitpost_cubitdart-1)
    - [`lib/views/post.dart`](#libviewspostdart-2)
    - [`lib/views/posts.dart`](#libviewspostsdart)
  - [15. Poll Post Scores](#15-poll-post-scores)
    - [`src/reddit/mod.rs`](#srcredditmodrs-2)
    - [`lib/cubit/post_cubit.dart`](#libcubitpost_cubitdart-2)
    - [`lib/main.dart`](#libmaindart-3)
  - [16. Supporting Android + iOS](#16-supporting-android--ios)
    - [Android](#android)
    - [iOS](#ios)
  - [17. Add Database Support](#17-add-database-support)
    - [`src/db.rs`](#srcdbrs)
    - [`src/lib.rs`](#srclibrs-4)
    - [`lib/main.dart`](#libmaindart-4)
    - [`sql/all-posts.sql`](#sqlall-postssql)
    - [`sql/all-scores.sql`](#sqlall-scoressql)
  - [18. Store and Posts and Scores](#18-store-and-posts-and-scores)
    - [`src/db.rs`](#srcdbrs-1)
    - [`src/lib.rs`](#srclibrs-5)
    - [`src/db.rs`](#srcdbrs-2)
    - [`src/lib.rs`](#srclibrs-6)
  - [19. Retrieving Posts and Scores on Startup](#19-retrieving-posts-and-scores-on-startup)
    - [`src/db.rs`](#srcdbrs-3)
    - [`src/lib.rs`](#srclibrs-7)
  - [20. Removing posts from Database](#20-removing-posts-from-database)
    - [`src/db.rs`](#srcdbrs-4)
    - [`src/lib.rs`](#srclibrs-8)
  - [21. Improve Perf and Wrapping Up](#21-improve-perf-and-wrapping-up)
- [Devices](#devices)
- [Sample Reddit Posts](#sample-reddit-posts)
- [Prep Example Post](#prep-example-post)
    - [Extract all Diffs](#extract-all-diffs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Sections

## 1. Introduce App

- show android, ios Emulator, macos app running with real reddit post data
- for that need to add some current posts from reddit in macos and copy `db` to ios folder
- point out that all logic is implemented in Rust, i.e. bloc/cubits do very little

## 2. Start App

- open a ready made rid template
- show existing counter super quickly
- delete all code
- build "hello world" with export only (`rt: hello world`)
- show `rid::log_info` (`rt: hello world + logging`)

```rust
#[rid::export]
pub fn hello_world(id: u8) -> String {
    rid::log_info!("Providing hello world for {}", id);
    "hello world".to_string()
}
```

```dart
import 'package:flutter/material.dart';
import 'package:plugin/generated/rid_api.dart';

void main() {
  rid.messageChannel.stream.listen((msg) => debugPrint("rid-msg: $msg"));
  debugPrint(rid_ffi.rid_export_hello_world(1).toDartString());
}
```

## 3. Reddit API Exploration

> We do this exploration and implementation first to ensure that what we're trying to do is
possible.

### JSON extension + Model Derival

- show that changing
  https://www.reddit.com/r/rust/comments/ncc9vc/rid_integrate_rust_into_your_dart_or_flutter_app/
  with added extension downloads data
  - https://www.reddit.com/r/rust/comments/ncc9vc/rid_integrate_rust_into_your_dart_or_flutter_app/.xml
  - https://www.reddit.com/r/rust/comments/ncc9vc/rid_integrate_rust_into_your_dart_or_flutter_app/.json
- use https://transform.tools/json-to-rust-serde with `jq` content to get entire rust/serde
  model

```sh
curl -H 'User-Agent: reddit-score' https://www.reddit.com/r/rust/comments/ncc9vc/rid_integrate_rust_into_your_dart_or_flutter_app/.json | jq | pbcopy
```

_need user agent_ to avoid _too many requests_

### Smaller Response to extract ID

- `name` is post id

```sh
curl -H 'User-Agent: reddit-score' https://api.reddit.com/api/info?id=t3_ncc9vc > curl-api.json
cat curl-api.json | jq '.data.children[0].data.score'
```

## 4. Implement Reddit Queries

- copy/paste reddit models
  - `src/reddit/reddit_api_response.rs`,
  - `src/reddit/reddit_page_response.rs`
- add `serde` + `serde_json` and turn on serde _derive_ feature
  - `serde = { version = "1.0.123", features = [ "derive" ] }`
- (`rt: reddit models and deps`)

## 5. ureq to perform client requests 

- introduce [ureq crate](https://crates.io/crates/ureq)
  - `cargo add ureq`
  - `ureq = { version = "2.0.2", features = [ "json" ] }` to support JSON responses
- introduce [anyhow crate](https://crates.io/crates/anyhow)
  - `cargo add anyhow`
  - we'll use it to noramlize different `Result` types in order to make use of the _try operator_ `?`
- implement first part of `query_page` inside  `src/reddit/reddit.rs` and `flutter run -d macos`
  to point access network issue
- add the below to the following files:
  - `macos/Runner/Release.entitlements`
  - `macos/Runner/DebugProfile.entitlements`
   
```xml
<key>com.apple.security.network.client</key>
<true/>
```
- `flutter run -d macos` again to show that this works now

### `src/reddit/reddit.rs`
 
```rust
use super::PageRoot;

use anyhow::Result;

pub fn query_page(url: &str) -> Result<()> {
    // Cut off query string
    let url = match url.find('?') {
        Some(idx) => &url[..idx],
        None => url,
    };
    // Append `.json` to URL in order to get a data response
    let url = format!("{}.json", url.trim_end_matches("/"));

    let page_response: PageRoot = ureq::get(&url)
        .set("User-Agent", "reddit-ticker")
        .call()?
        .into_json()?;

    rid::log_debug!("Got page {:#?}", page_response);
    Ok(())
}
```

- (`rt: querying page with ureq`)

## 6. Quick Iteration via Dart Script

> While iterating on rust code to extract post id and get score it'd be tedious to have to
relaunch the flutter app each time.

> We could add a `main` rust function somewhere and exercise the code like that, but we also
want to see that things work together via rid

- cannot run a project built for flutter directly since rid includes flutter specific utilities

### `rid_build.rs`

```rust
let project = match &env::var("TEST_DART") {
    Ok(_) => Project::Dart,
    Err(_) => Project::Flutter(FlutterConfig {
        plugin_name: "plugin".to_string(),
        platforms: vec![
            FlutterPlatform::ios(),
            FlutterPlatform::macos(),
            FlutterPlatform::android(),
        ],
    }),
};
```

### `sh/bindgen-dart`

```sh
#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DIR/.. && TEST_DART=1 cargo run rid_build
```

- run it to show that we now have a `./lib/generated` folder with bindings to be used for
  non-Flutter apps

### `test/`

- add `test/logging.dart` and walk through it

> Similar will exist for Flutter with more features and eventually will be part of rid.

### `test/wip.dart`

```dart
import 'package:reddit_ticker/generated/rid_api.dart';

import 'logging.dart';

void main() async {
  RidMessaging.init();
  rid_ffi.rid_export_page_request();
}
```

- `dart test/wip.dart`

> Not actual tests ATM but could be converted later for that purpose and at this point just
having a Dart script is super useful

- (`rt: dart script for faster iteration`)

## 7. Complete Page Request and return Page struct 

- complete `query_page` step by step and run `./sh/macos && dart ./test/wip.dart | cdl` repeatedly

> Since the rust interface isn't changing we don't need to run `bindgen`

### `src/reddit/reddit.rs` added

```rust
let data = &page_response
    .first()
    .ok_or_else(|| anyhow!("Page response did not contain any pages"))?
    .data
    .children
    .first()
    .ok_or_else(|| anyhow!("Page response did not contain any children"))?
    .data;

rid::log_debug!("{:#?}", data);
```

- (`rt: extracting data from page response`)

### `src/reddit/reddit.rs` added

```rust
let id = data.name.clone();
let title = data
    .title
    .as_ref()
    .ok_or_else(|| anyhow!("Page was missing a valid title"))?
    .clone();

let url = data
    .url
    .as_ref()
    .ok_or_else(|| anyhow!("Page was missing a valid url"))?
    .clone();

rid::log_debug!("id: {}, title: {}, url: {}", id, title, url);
```

- (`rt: extracting id, title and url from page reponse data`)

### `src/reddit/mod.rs`

```rust
// -----------------
// Reddit Page
// -----------------
#[derive(Debug, Clone)]
pub struct Page {
    pub id: String,
    pub title: String,
    pub url: String,
}
```

> struct does not need to be a `rid::model` since it's not exposed to Dart directly

### `src/lib.rs`

```rust
#[rid::export]
pub fn page_request() {
    let page = query_page("https://www.reddit.com/r/rust/comments/ncc9vc/rid_integrate_rust_into_your_dart_or_flutter_app/")
        .expect("Should have succeeded");
    rid::log_info!("{:#?}", page);
}
```

- (`rt: completed extracting page from page response`)

## 8. Post Score Request

- explain https://www.reddit.com/dev/api/
- we'll be using https://www.reddit.com/dev/api/#GET_api_info

### `src/reddit/reddit.rs`

```rust
const API_INFO_URL: &str = "https://api.reddit.com/api/info";

pub fn query_score(id: &str) -> Result<i32> {
    let url = format!("{}?id={}", API_INFO_URL, id);
    let api_response: ApiRoot = ureq::get(&url)
        .set("User-Agent", "reddit-ticker")
        .call()?
        .into_json()?;
    Ok(api_response.data.children[0].data.score)
}
```

### `src/lib.rs`

```rust
#[rid::export]
pub fn post_score_request(id: String) -> i32 {
    let score = query_score(&id).expect("Should have gotten score");
    score
}
```

### `test/wip.dart`

```dart
void main() async {
  RidMessaging.init();
  final id = rid_ffi.rid_export_page_request();
  final score = rid_ffi.rid_export_post_score_request(id);
  print('Score: $score');
}
```

## 9. Setting up the Store

### `src/reddit/mod.rs`

```rust
// -----------------
// Reddit Score
// -----------------
#[rid::model]
#[derive(Debug)]
pub struct Score {
    /// The amount of seconds passed since the post this score belongs to was added,
    /// i.e. the age of the score based on the age of the post.
    pub secs_since_post_added: u64,

    /// The score itself
    pub score: i32,
}
```

- storing time stamps in seconds to render it on a line chart with second resolution on x-axis

```rust
// -----------------
// Reddit Post
// -----------------
#[rid::model]
#[rid::structs(Score)]
#[derive(Debug, rid::Config)]
pub struct Post {
    #[rid(skip)]
    pub added: SystemTime,

    pub id: String,
    pub title: String,
    pub url: String,
    pub scores: Vec<Score>,
}
```

- specifying that `Score` is a struct
- _deriving_ `rid::Config` in order to introduce extra config attrs like `rid(skip)` which we
  use to indicate that `added` should not be exposed to Dart

### `src/lib.rs`

```rust
// -----------------
// Store
// -----------------
#[rid::store]
#[rid::structs(Post)]
pub struct Store {
    posts: HashMap<String, Post>,
}

impl RidStore<Msg> for Store {
    fn create() -> Self {
        todo!()
    }

    fn update(&mut self, _req_id: u64, _msg: Msg) {
        todo!()
    }
}

enum Msg {}
```

> store holds all app state which is queried from Flutter

- implement `RidStore<Msg>` which is used to _create_ and _update_ the store when ever a `Msg`
  is sent from Flutter

#### Initiating Store with Fake Post

```rust
fn create() -> Self {
    let post_id = String::from("fake post 1");
    let post = Post {
        added: SystemTime::now(),
        id: post_id.clone(),
        title: String::from("My first fake reddit post"),
        url: String::from("https://fake.reddit.com/post1"),
        scores: vec![],
    };
    let posts = {
        let mut map = HashMap::new();
        map.insert(post_id, post);
        map
          Self { posts }
    };
}
```

> Just doing enough here to work out the first installment of our Flutter UI

- run `./sh/bindgen-dart` and point out warnings
 
### `src/reddit/reddit.rs`

```rust
#![allow(unused_variables, dead_code)]
```

> for now won't use the reddit module so we silence unused warnings

### `test/wip.dart`

```dart
void main() async {
  RidMessaging.init();
  final store = Store.instance;
  print('${store.posts}');
}
```

> Ok, so we got us some posts and are ready to build out the UI without interaction for now as
we'll do that later via requests to Rust.

- `rt: setup score with a fake post`

## 10. Setting up Flutter App

- remove `lib/generated` as we won't need this for now

### Introduce Rid Messaging

- add `lib/rid/messaging.dart` and explain using this rust sample
 
```rust
rid::log_warn!("Some {} message", "warn");
rid::log_info!("Some {} message", "info");
rid::log_debug!("Some {} message", "debug");

rid::error!("Some error", err.to_string());
rid::severe!("Some severe error", err.to_string());
```

> log macros are similar to `format, println`

> error macros work differently in that they include separate details meant to be logged vs. the
message which is meant to be presented to the user as well

> main difference to the Dart-only implementation we used up til now is that `error` shows a
_snackBar_ and `severe` shows a _materialBanner_. We'll look at these in more detail while
building the app and handling errors.

- `rt: add rid messaging implementation`

### Install Deps

```sh
flutter pub add bloc
flutter pub add flutter_bloc
```

> we are using bloc/cubit to communicate with Rust 

### Include Assets

```sh
ln -s ../todo/assets/
```

#### `pubspec.yaml`

```yaml
flutter:

  uses-material-design: true

  assets:
    - assets/dash.png
    - assets/ferris.png
```

### App Skeleton

#### `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:plugin/generated/rid_api.dart';
import 'package:reddit_ticker/rid/messaging.dart';

void main() {
  // Register handlers for log messages as well as errors coming from Rust
  RidMessaging.init();

  // Don't clutter console with Store lock messages
  rid.debugLock = null;

  runApp(RedditTickerApp());
}

class RedditTickerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reddit Ticker',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: RedditTickerPage(title: 'Reddit Ticker'),
    );
  }
}

class RedditTickerPage extends StatefulWidget {
  final String title;
  RedditTickerPage({Key? key, required this.title}) : super(key: key);

  @override
  _RedditTickerPageState createState() => _RedditTickerPageState();
}

class _RedditTickerPageState extends State<RedditTickerPage> {
  @override
  void initState() {
    super.initState();

    // Provide our BuildContext to the Rust error handler so it can a snackbar and material banner
    ErrorHandler.instance.context = context;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title),
              Row(
                children: [
                  Image.asset(
                    "assets/dash.png",
                    height: 40.0,
                    width: 40.0,
                  ),
                  Icon(Icons.favorite, color: Colors.red),
                  Image.asset(
                    "assets/ferris.png",
                    height: 50.0,
                    width: 50.0,
                  ),
                ],
              )
            ],
          ),
        ),
        body: Text('TODO: PostsView'),
      ),
    );
  }
}
```

- (`rt: bloc deps and app skeleton`)

## 11. Showing Posts in Flutter

### Post Cubit

#### `lib/cubit/post_state.dart`

```dart
@immutable
abstract class PostState {
  final String url;
  final String postId;

  PostState(this.postId, this.url);
}

@immutable
class PostActive extends PostState {
  final Post post;
  PostActive(this.post) : super(post.id, post.url);
}
```

- only worry about _active_ posts for now, i.e. not handling removal via user action
- all states will have an _id_ in order to provide info later for posts that were removed
- all states have a _url_ in order launch it in the browser later

#### `lib/cubit/post_cubit.dart`

```dart
class PostCubit extends Cubit<PostState> {
  PostCubit(Post post) : super(PostActive(post));
}
```

> no functionality for now

### Posts Cubit

#### `lib/cubit/posts_state.dart`

```dart
@immutable
class PostsState {
  final List<Post> posts;
  const PostsState(this.posts);
}
```

> only one possible kind of state, a list of posts (even if they are empty)

#### `lib/cubit/posts_cubit.dart`

```dart
class PostsCubit extends Cubit<PostsState> {
  final _store = Store.instance;

  PostsCubit() : super(PostsState([])) {
    _refresh();
  }

  void _refresh() {
    final posts = _store.posts.values.toList();
    // Show most recently added posts first 
    posts.sort((a, b) => a.scores.length.compareTo(b.scores.length));
    emit(PostsState(posts));
  }
}
```

> starts without any posts and immediately refreshes from Rust store to retrieve them

> _refresh_ method will be used later to update list of posts when needed

- (`rt: post/posts cubits`)

### Post + Posts Views

#### `lib/views/post.dart`

```dart
class PostView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(builder: (context, state) {
      if (state is PostActive) {
        final post = state.post;
        return Dismissible(
          key: Key("Post Dismissible ${state.post.id}"),
          child: Card(
            child: InkWell(
              child: ListTile(
                title: Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      post.title,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            decoration: TextDecoration.underline,
                            overflow: TextOverflow.ellipsis,
                            color: Colors.blue,
                          ),
                    ),
                  ),
                ),
                subtitle: SizedBox(
                  height: 140,
                  child: Text('TODO Scores Chart'),
                ),
                onTap: () => {/* TODO: launch post url */},
              ),
            ),
          ),
          background: Padding(
            padding: EdgeInsets.all(5.0),
            child: Container(color: Colors.red),
          ),
        );
      } else {
        return Card(child: Text('Post removed'));
      }
    });
  }
}
```

- wrapped in _Dismissible_ to stop watching post _later_
- indidating title can be clicked to open URL _later_

#### `lib/views/post.dart`

```dart
class PostsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<PostsCubit, PostsState>(builder: (context, state) {
        final posts = state.posts;
        return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return MultiBlocProvider(
                providers: [
                  BlocProvider<PostCubit>(create: (_) => PostCubit(post)),
                ],
                child: PostView(),
                key: Key(post.hashCode.toString()),
              );
            });
      }),
    );
  }
}
```

- each post gets its own _PostCubit_ which will handle score updates and removal requests
- using `MultiBlocProvider` since we'll add a _post launcher_ provider 

#### `lib/main.dart`

```dart
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Reddit Ticker',
    theme: ThemeData(primarySwatch: Colors.indigo),
    home: MultiBlocProvider(
      providers: [
        BlocProvider<PostsCubit>(create: (_) => PostsCubit()),
      ],
      child: RedditTickerPage(title: 'Reddit Ticker'),
    ),
  );
}

[ ... ]

        body: PostsView(),
```
 
- using `MultiBlocProvider` since we'll add an _add post_ provider 
- (`rt: post and posts views`)

## 12. Showing Post Scores

### Adding Google Charts Dependency

```sh
mkdir deps && git clone https://github.com/google/charts --depth=1 deps/charts && rm -rf deps/charts/.git
echo '**/doc/' >> deps/charts/.gitignore
echo '**/example/' >> deps/charts/.gitignore
echo '**/test/' >> deps/charts/.gitignore
```
#### `pubspec.yaml`

```yaml
  # Published version isn't Flutter 2.5 compat
  # See https://github.com/google/charts/issues/678
  charts_flutter:
    path: ./deps/charts/charts_flutter
```

- current published version is incompatible with Flutter 2.5
- (`rt: add google charts dependency`)

### Mocking Sample Scores

#### `./src/lib.rs`

```rust
let scores = vec![
    Score {
        score: 1,
        secs_since_post_added: 10,
    },
    Score {
        score: 2,
        secs_since_post_added: 20,
    },
    Score {
        score: 4,
        secs_since_post_added: 30,
    },
    Score {
        score: 8,
        secs_since_post_added: 40,
    },
    Score {
        score: 6,
        secs_since_post_added: 50,
    },
    Score {
        score: 10,
        secs_since_post_added: 60,
    },
    Score {
        score: 5,
        secs_since_post_added: 70,
    },
];
let post = Post {
    added: SystemTime::now(),
    id: post_id.clone(),
    title: String::from("My first fake reddit post"),
    url: String::from("https://fake.reddit.com/post1"),
    scores,
};
```

#### `./lib/views/post.dart`

```dart
import 'package:charts_flutter/flutter.dart' as charts;

charts.Series<Score, double> _toChartData(List<Score> scores) {
  return charts.Series<Score, double>(
    id: 'Scores',
    colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
    domainFn: (Score score, _) => score.secsSincePostAdded / 60.0,
    measureFn: (Score score, _) => score.score,
    data: scores,
  );
}

[ .. ]

if (state is PostActive) {
  final post = state.post;
  final chartData = _toChartData(post.scores);
  final chart = charts.LineChart(
    [chartData],
    animate: true,
  );

[ .. ]

  subtitle: SizedBox(
    height: 140,
    child: chart,
  ),
```

- (`rt: showing fake scores`)

## 13. Start Watching Post from Reddit

- first remove all fake post stuff from `src/lib.rs`

### `src/lib.rs`

```rust
// -----------------
// Message
// -----------------
#[rid::message(Reply)]
pub enum Msg {
    StartWatching(String),
}

// -----------------
// Reply
// -----------------
#[rid::reply]
pub enum Reply {
    StartedWatching(u64, String),
    FailedRequest(u64, String),
}
```

- we'll call `msgStartWatching(url)` and get back a successful or failed reply

```rust
fn update(&mut self, req_id: u64, msg: Msg) {
    match msg {
        Msg::StartWatching(url) => start_watching(req_id, url),
    }
}

[ .. ]

// Helpers to improve code assist
impl Store {
    fn read() -> RwLockReadGuard<'static, Store> {
        store::read()
    }

    fn write() -> RwLockWriteGuard<'static, Store> {
        store::write()
    }
}

[ .. ]

// -----------------
// Start watching Post
// -----------------
fn start_watching(req_id: u64, url: String) {
    thread::spawn(move || {
        match try_start_watching(url) {
            Ok(post) => {
                let id = post.id.clone();
                let mut store = Store::write();
                store.posts.insert(id.clone(), post);
                rid::post(Reply::StartedWatching(req_id, id))
            }
            Err(err) => rid::post(Reply::FailedRequest(req_id, err.to_string())),
        };
    });
}
```

- performing this on separate thread in order to not block UI while we're downloading post data
- calling `try_start_watching` since exceptions may occur in which case we respond with `FailedRequest`
- difference to `rid::error` or `rid::severe` is that this is directly related to a request we
sent for which we await a response, vs. something that went wrong in the app that's not
directly related, i.e. polling score count which we'll implement later

```rust
fn try_start_watching(url: String) -> Result<Post> {
    let page = query_page(&url)
        .map_err(|err| anyhow!("Failed to get valid page data: {}\nError: {}", url, err))?;

    rid::log_debug!("Got page for url '{}' with id '{}'.", url, page.id);

    let added = SystemTime::now();
    let post = Post {
        added,
        id: page.id,
        title: page.title,
        url: page.url,
        scores: vec![],
    };
    Ok(post)
}
```

- `map_err` allows us to add more context to the error and include the original error message
itself

- run `./sh/bindgen && ./sh/macos`

### `lib/cubit/add_post_state.dart`

```dart
@immutable
abstract class AddPostState {}

@immutable
class AddPostInactive extends AddPostState {}

@immutable
class AddPostPending extends AddPostState {
  final String url;
  AddPostPending(this.url) : super();
}

@immutable
class AddPostSucceeded extends AddPostState {
  final Post post;
  AddPostSucceeded(this.post) : super();
}

@immutable
class AddPostFailed extends AddPostState {
  final String url;
  final String errorMessage;
  AddPostFailed(this.url, this.errorMessage) : super();
}
```

- a post we are adding starts as _pending_ which either _succeeds_ or _fails_

### `lib/cubit/add_post_cubit.dart`

```dart
// Requests to reddit can be slow especially on not so great internet
final REQ_TIMEOUT = const Duration(seconds: 10);

class AddPostCubit extends Cubit<AddPostState> {
  final Store _store = Store.instance;
  AddPostCubit() : super(AddPostInactive());

  Future<void> addPost(String url) async {
    emit(AddPostPending(url));

    final res = await _store.msgStartWatching(url, timeout: REQ_TIMEOUT);

    switch (res.type) {
      case Reply.StartedWatching:
        assert(res.data != null, 'Successful reply should include post id');
        final post = _store.posts[res.data];
        assert(post != null, 'Watched post should be in the map');
        emit(AddPostSucceeded(post!));
        break;
      case Reply.FailedRequest:
        assert(res.data != null, 'Failed reply should include error message');
        assert(state is AddPostPending,
            'Adding post should only fail when it was pending');
        emit(AddPostFailed((state as AddPostPending).url, res.data!));
        break;
      default:
        throw ArgumentError.value(
            res.type, 'StartWatching Reply', 'Invalid reply!');
    }

    emit(AddPostInactive());
  }
}
```

- explain how we are `await`ing the response here as our request is handled on separate thread

### `lib/views/add_post.dart`

- copy/paste and walk through it explaining particularly `if (state is AddPostFailed)` section

### `lib/main.dart`

```dart
providers: [
  BlocProvider<PostsCubit>(create: (_) => PostsCubit()),
  BlocProvider<AddPostCubit>(create: (_) => AddPostCubit()),
],

[ .. ]

body: PostsView(),
floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
floatingActionButton: AddPostView(),
```

> just hooking it all up

### First Run

- `flutter run -d macos`
- use https://www.reddit.com/r/rust/comments/ncc9vc/rid_integrate_rust_into_your_dart_or_flutter_app/
- show that we get `StartedWatching` result but UI is not updating

### `lib/cubit/posts_cubit.dart`

```dart
class PostsCubit extends Cubit<PostsState> {
  final _store = Store.instance;
  late final StreamSubscription<PostedReply>? removedPostsSub;

  PostsCubit() : super(PostsState([])) {
    _subscribe();
    _refresh();
  }

  void _subscribe() {
    removedPostsSub = rid.replyChannel.stream
        .where((x) => x.type == Reply.StartedWatching)
        .listen((_) => _refresh());
  }

  Future<void> _unsubscribe() async {
    await removedPostsSub?.cancel();
    removedPostsSub = null;
  }

  void _refresh() {
    final posts = _store.posts.values.toList();
    // Show most recently added posts first
    posts.sort((a, b) => a.scores.length.compareTo(b.scores.length));
    emit(PostsState(posts));
  }

  @override
  Future<void> close() async {
    await _unsubscribe();
    return super.close();
  }
}
```

- add this point restart the app and add the post again which is now working
- (`rt: implemented add post`)

## 14. Stop Watching Post

```rust
Msg::StopWatching(id) => {
    self.posts.remove(&id);
    rid::post(Reply::StoppedWatching(req_id, id));
}

[ .. ]

// -----------------
// Message
// -----------------
#[rid::message(Reply)]
pub enum Msg {
    StartWatching(String),
    StopWatching(String),
}

// -----------------
// Reply
// -----------------
#[rid::reply]
pub enum Reply {
    StartedWatching(u64, String),
    StoppedWatching(u64, String),

    FailedRequest(u64, String),
}
```

- add message + reply enum first and show how the match in the update method guides us
- `./sh/bindgen && ./sh/macos`

### `lib/cubit/post_state.dart`

```dart
@immutable
class PostActive extends PostState {
  final Post post;
  PostActive(this.post) : super(post.id, post.url);

  PostRemoved intoRemoved() => PostRemoved.fromPostActive(this);
}

@immutable
class PostRemoved extends PostState {
  final String postId;
  PostRemoved(this.postId, String url) : super(postId, url);

  factory PostRemoved.fromPostActive(PostActive state) {
    final post = state.post;
    return PostRemoved(post.id, post.url);
  }
}
```

- explain `intoRemoved` idea from dart which also encodes possible state transitions
- here we also enforce that only an active post can be removed (private constructor + factory
method)
 

### `lib/cubit/post_cubit.dart`

```dart
class PostCubit extends Cubit<PostState> {
  final Store _store = Store.instance;
  PostCubit(Post post) : super(PostActive(post));

  Future<void> _refreshState() async {
    assert(state is PostActive, 'Should only refresh post when it is ticking');
    final postActive = state as PostActive;
    final post = _store.posts[postActive.postId];

    if (post == null) {
      emit(postActive.intoRemoved());
    } else {
      emit(PostActive(post));
    }
  }

  Future<bool> stopWatching() async {
    assert(state is PostActive, 'Can only remove active post');
    final post = (state as PostActive).post;
    await _store.msgStopWatching(post.id).then((_) => _refreshState());
    emit(PostRemoved(post.id, post.url));
    return true;
  }
}
```

### `lib/views/post.dart`

```dart
confirmDismiss: (_) => context.read<PostCubit>().stopWatching(),
background: Padding(
  padding: EdgeInsets.all(5.0),
  child: Container(color: Colors.red),
),
```

### `lib/views/posts.dart`

```dart
void _subscribe() {
  removedPostsSub = rid.replyChannel.stream
      .where((x) =>
          x.type == Reply.StartedWatching || x.type == Reply.StoppedWatching)
      .listen((_) => _refresh());
}
```

- (`rt: stop watching post`)

## 15. Poll Post Scores

```rust
// -----------------
// Message
// -----------------
#[rid::message(Reply)]
pub enum Msg {
    Initialize,

    StartWatching(String),
    StopWatching(String),
}

// -----------------
// Reply
// -----------------
#[rid::reply]
pub enum Reply {
    Initialized(u64),

    StartedWatching(u64, String),
    StoppedWatching(u64, String),

    FailedRequest(u64, String),
    
    UpdatedScores,
}
```

- we don't initialize polling and such during create store, but via a message in order to allow
the app to pass us information, i.e. the directory where we can store data
- again the _match_ statement guides us
- we add an `UpdatedScores` reply which is sent each time the scores were updated in the
background which will cause the UI to refresh

```rust
Msg::Initialize => {
    // Guard against more than one polling thread, i.e. due to hot restart
    if !self.polling {
        self.polling = true;
        poll_posts();
    }
    rid::post(Reply::Initialized(req_id));
}
```

- need to track `polling` on the store, but don't need it on the Dart side, thus we can
`rid(skip)` it

```rust
// -----------------
// Store
// -----------------
#[rid::store]
#[rid::structs(Post)]
#[derive(rid::Config)]
pub struct Store {
    posts: HashMap<String, Post>,

    #[rid(skip)]
    polling: bool,
}
```

### `src/reddit/mod.rs`

```rust
pub const RESOLUTION_MILLIS: u64 = 5_000;
```

```rust
// -----------------
// Poll Posts we are watching for Scores Updates
// -----------------
fn poll_posts() {
    rid::log_debug!("Creating thread to poll post data");
    thread::spawn(move || loop {
        // First we query all posts and only take a write lock on the store once we have all the
        // data in order to limit the amount of time that the UI or other threads cannot access the
        // store.

        // In order to release the read lock on the store immediately, we clone the post ids.
        let post_ids: Vec<_> = { Store::read().posts.keys().cloned().collect() };
        let scores: Vec<_> = post_ids
            .into_iter()
            .map(|id| {
                let score = query_score(&id);
                (id, score)
            })
            // Filter out all cases where we couldn't update the score and send an error so that we
            // can log the problem and alert the user
            .filter_map(|(id, score_res)| match score_res {
                Ok(score) => Some((id, score)),
                Err(err) => {
                    rid::error!("Failed to update score for a post", err.to_string());
                    None
                }
            })
            .collect();

        {
            // Aquire a write lock on the store once and make sure it gets dropped (at the end of
            // this block) when we no longer need it
            let mut store = Store::write();
            for (id, score) in scores {
                // A post could have been removed in between getting the post ids and aquiring
                // the write lock.
                if !store.posts.contains_key(&id) {
                    continue;
                }

                let time_stamp = SystemTime::now();
                let post = &mut store.posts.get_mut(&id).unwrap();
                let secs_since_post_added = time_stamp
                    .duration_since(post.added)
                    .expect("Getting duration")
                    .as_secs();

                post.scores.push(Score {
                    secs_since_post_added,
                    score,
                });
            }
        }
        rid::post(Reply::UpdatedScores);
        thread::sleep(time::Duration::from_millis(RESOLUTION_MILLIS));
    });
}
```

- even though it is long hand-code this method and explain all the nuisances especially around
efficient locking and error handling

- `./sh/bindgen && ./sh/macos`

### `lib/cubit/post_cubit.dart`

```dart
StreamSubscription<PostedReply>? scoreTickSub;
PostCubit(Post post) : super(PostActive(post)) {
  _subscribe();
}

void _subscribe() {
  assert(scoreTickSub == null, 'Should only subscribe to post ticks once');
  scoreTickSub = rid.replyChannel.stream
      .where((x) => x.type == Reply.UpdatedScores)
      .listen((_) => _refreshState());
}

Future<void> _unsubscribe() async {
  await scoreTickSub?.cancel();
  scoreTickSub = null;
}

[ .. ]


@override
Future<void> close() async {
  await _unsubscribe();
  return super.close();
}
````

### `lib/main.dart`

```dart
void main() async {
  // Register handlers for log messages as well as errors coming from Rust
  RidMessaging.init();

  // Don't clutter console with Store lock messages
  rid.debugLock = null;

  await Store.instance.msgInitialize();
  runApp(RedditTickerApp());
}
```

> show some error handling with totally invalid post URL + one with the post id changed

- (`rt: polling post scores`)

## 16. Supporting Android + iOS

### Android

- connect Pixel

```sh
./sh/android
flutter run -d FA7760303714
```

```sh
scrcpy
```

- show that it works (make sure to connect to WiFi)

### iOS

```sh
./sh/ios
open ios/Runner.xcworkspace
```

- choose iPhone 12 
- `I/O -> Keyboard` do not connect hardware keyboard
- instead go to Safari open reddit.com and select any post + get share URL
- alternatively just put a link into our mac clipboard (it is shared)
- back to app long press in test field to get to _paste_
- log messages are in Xcode
- (`rt: running on android + ios`)




***

Record screencast up to here + see how long it guess and decide if we include DB or
do a separate video later.

***

## 17. Add Database Support

**NOTE**: Ensure that no data from previous runs is present

```
rm '~/Library/Containers/com.example.redditTicker/Data/Library/Application Support/com.example.redditTicker/*.sqlite'
```

```sh
cargo add rusqlite
```

```toml
rusqlite = { version = "0.24.2", features = ["bundled"] }
````

### `src/db.rs`

```rust
pub const DB_NAME: &str = "reddit_ticker.sqlite";

pub struct DB {
    conn: Connection,
}

impl DB {
    // -----------------
    // Initializing Database
    // -----------------
    pub fn new(path: &str) -> Result<Self> {
        let conn = Connection::open(path)
            .map_err(|err| anyhow!("Failed to open Database at: {}\nError: {}", path, err))?;

        let db = Self { conn };
        db.init_tables()?;

        Ok(db)
    }

    fn init_tables(&self) -> Result<()> {
        self.conn
            .execute_batch(
                "
BEGIN;
CREATE TABLE IF NOT EXISTS reddit_posts (
    post_id  TEXT PRIMARY KEY,
    title    TEXT,
    url      TEXT,
    added    INTEGER
);
CREATE TABLE IF NOT EXISTS reddit_scores (
    post_id   TEXT,
    added     INTEGER,
    score     INTEGER
);
CREATE INDEX IF NOT EXISTS idx_post_id ON reddit_scores (post_id);
COMMIT;
",
            )
            .map_err(|err| anyhow!("Failed to create Database tables:\nError: {}", err))
    }
}
```

- posts and related scores have absolute timestamps
- when we retrieve scores we'll base them on the time the post was added
- making use of `map_err` here as well to forward any errors with as much info as possible

### `src/lib.rs`

```rust
pub struct Store {
    posts: HashMap<String, Post>,

    #[rid(skip)]
    polling: bool,

    #[rid(skip)]
    db: Option<DB>,
}

[ .. ]

Msg::Initialize(app_dir) => {
    // Guard against more than one polling thread, i.e. due to hot restart
    if !self.polling {
        self.polling = true;
        poll_posts();
    }
    if self.db.is_none() {
        let db_path = Path::new(&app_dir)
            .join(DB_NAME)
            .to_string_lossy()
            .to_string();

        match DB::new(&db_path) {
            Ok(db) => {
                self.db = Some(db);
                rid::log_info!("Initialized Database at '{}'", db_path);
            }
            Err(err) => {
                rid::severe!(
                    format!("Failed to open Database at '{}'", db_path),
                    err.to_string()
                );
            }
        };
    }
    rid::post(Reply::Initialized(req_id));
}

[ .. ]

pub enum Msg {
    Initialize(String),

    StartWatching(String),
    StopWatching(String),
}
```

- the app_dir is provided to us from Flutter (it differs per device)
- `./sh/bindgen && ./sh/macos`

```sh
flutter pub add path_provider
```

- (`rt: install path_provider`)

### `lib/main.dart`

```dart
// Connect the Database and kick off the thread that is polling post scores
WidgetsFlutterBinding.ensureInitialized();
final appDir = await getApplicationSupportDirectory();
await Store.instance.msgInitialize(appDir.path);
```

- `WidgetsFlutterBinding.ensureInitialized();` is needed to avoid `Null check operator used on
a null value` exception

- Note _Initialized Database at:_ message
- link to data directory
 
```sh
ln -s '~/Library/Containers/com.example.redditTicker/Data/Library/Application Support/com.example.redditTicker/' data-macos
```
- ensure that it is empty

```sh
sqlite3 data-macos/reddit_ticker.sqlite .tables
```


### `sql/all-posts.sql`

```sql
SELECT * FROM reddit_posts;
```

### `sql/all-scores.sql`

```sql
SELECT * FROM reddit_scores;
```

```sh
sqlite3 data-macos/reddit_ticker.sqlite < sql/all-posts.sql
```

- (`rt: connecting  DB and creating post and score tables`)

## 18. Store and Posts and Scores

### `src/db.rs`

```rust
impl Db {
    [ .. ]
    // -----------------
    // Inserting Posts and Scores
    // -----------------
    pub fn insert_post(&self, post: &Post) -> Result<usize> {
        let added: u32 = time_stamp_to_secs(post.added);

        self.conn
            .execute(
                "
INSERT OR IGNORE INTO reddit_posts (post_id, title, url, added)
VALUES (?1, ?2, ?3, ?4);
",
                params!(post.id, post.title, post.url, added),
            )
            .map_err(|err| anyhow!("Failed to add post with id {}:\nError: {}", post.id, err))
    }
}

// -----------------
// Timestamp Utils
// -----------------

// We keep timestamps stored as secs since  `UNIX_EPOCH` in order to be able to store them as u32
// which is the largest `INTEGER` supported by sqlite.

/// Takes a [UNIX_EPOCH] based [SystemTime] timestamp and converts it to seconds.
fn time_stamp_to_secs(time_stamp: SystemTime) -> u32 {
    // max u32:          4,294,967,295
    // UNIX_EPOCH secs: ~1,631,804,843
    time_stamp.duration_since(UNIX_EPOCH).unwrap().as_secs() as u32
}

/// Converts seconds passed since [UNIX_EPOCH] to a [SystemTime].
fn secs_to_time_stamp(secs: u32) -> SystemTime {
    UNIX_EPOCH + Duration::from_secs(secs as u64)
}
```

### `src/lib.rs`

```rust
fn try_start_watching(url: String) -> Result<Post> {
    [ .. ]

    // Store the new post in the Database
    if let Some(db) = Store::read().db.as_ref() {
        if let Err(err) = db.insert_post(&post) {
            rid::error!("Failed to insert post", err.to_string());
        }
    }
    Ok(post)
}
```
- `/sh/macos` (no need to bindgen since we changed no API)
- vim: `DB sqlite:data-macos/reddit_ticker.sqlite < sql/all-posts.sql` (`r` in the sql window
allows refreshing same query)
 
- (`rt: storing added posts in db`)

### `src/db.rs`

```rust
pub fn insert_score(&self, post_id: &str, time_stamp: SystemTime, score: i32) -> Result<usize> {
    let added = time_stamp_to_secs(time_stamp);
    let res = self
        .conn
        .execute(
            "
INSERT OR IGNORE INTO reddit_scores (post_id, added, score)
VALUES (?1, ?2, ?3);
",
            params!(post_id, added, score),
        )
        .map_err(|err| {
            anyhow!(
                "Failed to insert score for post {}:\nError: {}",
                post_id,
                err
            )
        })?;

    Ok(res)
}
```

### `src/lib.rs`

```rust
fn poll_posts() {
        [ .. ]
        
        if let Some(db) = &store.db.as_ref() {
            if let Err(err) = db.insert_score(&id, time_stamp, score) {
                rid::error!("Failed to add score for post", err.to_string());
            }
        }
    }
}
rid::post(Reply::UpdatedScores);
```

- `./sh/macos`
- vim: `DB < sql/all-scores.sql`
- (`rt: adding scores to database`)

## 19. Retrieving Posts and Scores on Startup

### `src/db.rs`

Just paste this in and walk through it (this isn't a detailed tutorial on SQL with Rust).

```rust
impl DB {
    [ .. ]
    
    // -----------------
    // Retrieving Posts and Scores
    // -----------------
    pub fn get_scores(&self, post: &Post) -> Result<Vec<Score>> {
        let mut stmt = self.conn.prepare(
            "
SELECT added, score
FROM reddit_scores
WHERE post_id = (?1)
",
        )?;

        let results: Vec<_> = stmt
            .query_map(params!(post.id), |row| try_extract_score(row, post.added))?
            .filter_map(|x| match x {
                Ok(score) => Some(score),
                Err(err) => {
                    rid::log_warn!("Found invalid score in Database {}", err.to_string());
                    None
                }
            })
            .collect();
        Ok(results)
    }

    pub fn get_all_posts(&self) -> Result<Vec<Post>> {
        let mut stmt = self.conn.prepare(
            "
SELECT post_id, title, url, added 
FROM reddit_posts;
",
        )?;
        let results = stmt.query_map(NO_PARAMS, try_extract_post)?;
        let mut posts: Vec<_> = results
            .filter_map(|res| match res {
                Ok(post) => Some(post),
                Err(err) => {
                    rid::error!("A post couldn't be properly extracted", err.to_string());
                    None
                }
            })
            .collect();

        for mut post in posts.iter_mut() {
            let scores = self.get_scores(&post)?;
            post.scores = scores
        }
        Ok(posts)
    }
}

// -----------------
// Sqlite helpers
// -----------------
fn try_extract_score(row: &Row, post_added: SystemTime) -> rusqlite::Result<Score> {
    // Score timestamps are stored [UNIX_EPOCH] seconds, however the rest
    // of the app treats score timestamps based on the time the post was added.
    let secs: u32 = row.get(0)?;
    let time_stamp = secs_to_time_stamp(secs);
    let secs_since_post_added = time_stamp
        .duration_since(post_added)
        .expect("Invalid timestamp")
        .as_secs();

    let score: i32 = row.get(1)?;

    Ok(Score {
        secs_since_post_added,
        score,
    })
}

fn try_extract_post(row: &Row) -> rusqlite::Result<Post> {
    Ok(Post {
        id: row.get(0)?,
        title: row.get(1)?,
        url: row.get(2)?,
        added: secs_to_time_stamp(row.get(3)?),
        scores: vec![],
    })
}
```

### `src/lib.rs`

```rust
if let Some(db) = &self.db {
    self.posts = match db.get_all_posts() {
        Ok(posts) => {
            let mut map = HashMap::<String, Post>::new();
            for post in posts {
                map.insert(post.id.clone(), post);
            }
            map
        }
        Err(err) => {
            rid::error!("Failed to retrieve existing posts", err);
            HashMap::new()
        }
    };
    rid::log_info!(
        "Loaded {} existing post(s) from the Database",
        self.posts.len()
    );
}
rid::post(Reply::Initialized(req_id));
```

- `./sh/macos`

> While working this out it is advisable to create a `test/db.dart` or similar in order to work
out the database queries without having to restart a Flutter app each time.

- (`rt: retrieving posts with scores from db on init`)
- leave app running

## 20. Removing posts from Database

- show (hot restart suffices) that a removed post reappears
- need to clear out post data including scores

### `src/db.rs`

```rust
impl DB {
    [ .. ]
    // -----------------
    // Deleting Posts and Scores
    // -----------------
    pub fn delete_post(&self, post_id: &str) -> Result<usize> {
        let post_rows_removed = self
            .conn
            .execute(
                "
DELETE FROM reddit_posts 
WHERE post_id = (?1);
",
                params!(post_id),
            )
            .map_err(|err| anyhow!("Failed to remove post from table:\nError: {}", err))?;

        let score_rows_removed = self
            .conn
            .execute(
                "
DELETE FROM reddit_scores 
WHERE post_id = (?1);
",
                params!(post_id),
            )
            .map_err(|err| anyhow!("Failed to remove scores from table:\nError: {}", err))?;
        Ok(post_rows_removed + score_rows_removed)
    }
}
```

### `src/lib.rs`

```rust
Msg::StopWatching(id) => {
    self.posts.remove(&id);
    if let Some(db) = &self.db {
        match db.delete_post(&id) {
            Ok(rows) => {
                rid::log_debug!("Removed post and {} scores from Database", rows - 1)
            }
            Err(err) => rid::error!("Failed to delete post from Database", err),
        }
    }
    rid::post(Reply::StoppedWatching(req_id, id));
}
```

- show that this works by SQL querying posts in vim
- hot restart and show it's gone
- SQL query scores + go to bottom -> remove a post and repeat showing that much less score rows
- also point out useful log messages
- (`rt: deleting removed posts and scored from db`)

***

## 21. Improve Perf and Wrapping Up

Use the below inside `PostCubit` to get a particluar post:

```dart
final post =
    _store.raw.runLocked((raw) => raw.posts.get(postActive.postId));
```

- (`rt: optimizing post access in post_cubit`)
- leave URL launcher as exercise

***

# Devices

```
flutter run -d <ios-device>
```
does not work.

Instead do:

```
open ios/Runner.xcworkspace/
```
and run it from there. The app works, but keyboard input is excrutiatingly slow (on dev
channel).

***

# Sample Reddit Posts

- https://www.reddit.com/r/rust/comments/ncc9vc/rid_integrate_rust_into_your_dart_or_flutter_app/ 
- https://www.reddit.com/r/rust/comments/oab8a0/multithreaded_flutter_rust_app_using_rid/
- https://www.reddit.com/r/rust/comments/nds4ox/building_a_flutter_todo_app_with_all_application/

***

# Prep Example Post

### Extract all Diffs

```
git lg fb4e614.. | awk '{print $2}' | xargs git show --oneline > commits.diff
