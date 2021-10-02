import 'package:reddit_ticker/generated/rid_api.dart';

import 'logging.dart';

void main() async {
  RidMessaging.init();
  final store = Store.instance;
  print('${store.posts}');
}
