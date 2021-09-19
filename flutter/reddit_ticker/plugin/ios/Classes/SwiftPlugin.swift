import Flutter
import UIKit

public class SwiftPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(nil)
  }
}
// <rid:prevent_tree_shake Start>
func dummyCallsToPreventTreeShaking() {
    rid_export_hello_world(0);
    rid_cstring_free(nil);
    rid_init_msg_isolate(0);
    rid_init_reply_isolate(0);
}
// <rid:prevent_tree_shake End>