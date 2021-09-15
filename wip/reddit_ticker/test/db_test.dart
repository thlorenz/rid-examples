import 'dart:io';

import 'package:reddit_ticker/generated/rid_api.dart';

import 'logging.dart';

void main() async {
  RidMessaging.init();

  final store = Store.instance;
  await store.msgInitialize(Directory.current.path);
  print('initialized');
  await store.msgStartWatching('https://1');
  await store.msgStartWatching('https://2');

  print(store.posts.values.first);
}
