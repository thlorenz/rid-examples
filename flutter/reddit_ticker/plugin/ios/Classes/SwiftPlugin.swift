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
    _to_dart_for_Store();
    rid_store_debug(nil);
    rid_store_debug_pretty(nil);
    create_store();
    rid_store_unlock();
    rid_store_free();
    rid_store_count(nil);
    _include_Store_field_wrappers();
    rid_cstring_free(nil);
    rid_init_msg_isolate(0);
    rid_init_reply_isolate(0);
    rid_msg_Inc(0);
    rid_msg_Add(0, 0);
}
// <rid:prevent_tree_shake End>