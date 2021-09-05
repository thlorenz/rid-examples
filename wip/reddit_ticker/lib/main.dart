import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin/generated/rid_api.dart';

final REQ_TIMEOUT = const Duration(seconds: 10);
const URL =
    'https://www.reddit.com/r/rust/comments/phr5n2/formally_implement_let_chains/';

Future<void> startWatching(Store store, String url) async {
  final res = await store.msgStartWatching(url, timeout: REQ_TIMEOUT);

  switch (res.type) {
    case Reply.StartedWatching:
      assert(store.posts.containsKey(res.data),
          'Watched post should be in the map');
      break;
    case Reply.FailedRequest:
      print('Failed watching ${url}\nError: ${res.data}');
      break;
    default:
      throw ArgumentError.value(
          res.type, 'StartWatching Reply', 'Invalid reply!');
  }
}

StreamSubscription<PostedReply> subscribeScoreUpdates(Store store) {
  return replyChannel.stream.where((x) => x.type == Reply.UpdatedScores).listen(
    (_) {
      for (final post in store.posts.values) {
        debugPrint(
            '${post.title} (${post.id}):\n   ${post.scores.join(", ")}\n');
      }
    },
  );
}

void main(List<String> args) async {
  final store = Store.instance;

  subscribeScoreUpdates(store);
  await startWatching(store, URL);
  await store.msgInitializeTicker();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Store _store = Store.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rust/Flutter Counter App Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RedditTickerPage(_store, title: 'Rust/Flutter Reddit Ticker'),
    );
  }
}

class RedditTickerPage extends StatefulWidget {
  final Store _store;
  RedditTickerPage(this._store, {Key? key, required this.title})
      : super(key: key);
  final String title;
  @override
  _RedditTickerPageState createState() => _RedditTickerPageState();
}

class _RedditTickerPageState extends State<RedditTickerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ticker App will be here shortly',
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {},
            tooltip: 'Add Watch URL',
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
