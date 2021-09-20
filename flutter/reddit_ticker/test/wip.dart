import 'package:reddit_ticker/generated/rid_api.dart';

import 'logging.dart';

void main() async {
  RidMessaging.init();
  final id = await rid_ffi.rid_export_page_request();
  final score = await rid_ffi.rid_export_post_score_request(id);
  print('Score: $score');
}
