import 'dart:async';
import 'dart:io';

import 'generated/rid_api.dart';

final REQ_TIMEOUT = const Duration(seconds: 10);

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

class KeyboardHandler {
  final Store store;

  KeyboardHandler(this.store);

  printStatus() {
    for (final post in store.posts.values) {
      print('${post.title} (${post.id}):\n   ${post.scores.join(", ")}\n');
    }
  }

  void printCommands() {
    print("\nPlease select one of the below:\n");
    print("  a  -- to start watching a reddit post url");
    print("  r  -- to remove a reddid post id");
    print("  q  -- to quit");
  }

  Future<bool> handleCommand(String cmd, String payload) async {
    print('cmd: "$cmd"');
    switch (cmd) {
      case "a":
        await startWatching(store, payload);
        break;
      case "r":
        await store.msgStopWatching(payload);
        resetScreen();
        break;
      case "q":
        return false;
      default:
        print("\nUnknown command '$cmd'\n");
        return false;
    }
    return true;
  }

  void resetScreen() {
    print("\x1B[2J\x1B[0;0H");
    printStatus();
    printCommands();
    stdout.write("\n> ");
  }

  StreamSubscription<PostedReply> subscribeScoreUpdates() {
    return replyChannel.stream
        .where((x) => x.type == Reply.UpdatedScores)
        .listen(
      (_) {
        resetScreen();
      },
    );
  }

  void start() async {
    resetScreen();
    subscribeScoreUpdates();
    stdin.listen((bytes) async {
      final cmd = String.fromCharCode(bytes.first);
      final payload = (bytes.length > 2)
          ? bytes
              .map((b) => String.fromCharCode(b))
              .join('')
              .substring(2)
              .trim()
          : "";

      final ok = await handleCommand(cmd, payload);
      if (!ok || cmd == "q") {
        exit(0);
      }
      resetScreen();
    });
  }
}
