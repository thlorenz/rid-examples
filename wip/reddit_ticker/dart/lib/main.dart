import 'generated/rid_api.dart';
import 'keyboard_handler.dart';

const URL =
    'https://www.reddit.com/r/rust/comments/phr5n2/formally_implement_let_chains/';

void main(List<String> args) async {
  RID_DEBUG_LOCK = null;
  RID_DEBUG_REPLY = null;

  final store = Store.instance;

  await startWatching(store, URL);
  await store.msgInitializeTicker();

  final handler = new KeyboardHandler(store);
  handler.start();
}
