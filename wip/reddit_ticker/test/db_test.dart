import 'dart:io';

import 'package:reddit_ticker/generated/rid_api.dart';

import 'logging.dart';

const REAL_REDDIT_POST =
    'https://www.reddit.com/r/rust/comments/bod7eq/how_to_use_with_option_and_result/';
const MOCK_REDDIT_POST = 'https://1';

void main() async {
  final useMock = !Platform.environment.containsKey('USE_REDDIT');
  final redditPost = useMock ? MOCK_REDDIT_POST : REAL_REDDIT_POST;

  RidMessaging.init();

  final store = Store.instance;
  await store.msgInitialize(Directory.current.path);
  print('initialized');
  final res = await store.msgStartWatching(redditPost);
  if (res.type == Reply.FailedRequest) {
    print('Failed request for first page: $res');
    return;
  }

  print(store.posts.values.first);
}
