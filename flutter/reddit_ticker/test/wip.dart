import 'package:reddit_ticker/generated/rid_api.dart';

import 'logging.dart';

void main() async {
  RidMessaging.init();
  rid_ffi.rid_export_page_request();
}
