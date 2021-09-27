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
    _to_dart_for_Score();
    rid_score_debug(nil);
    rid_score_debug_pretty(nil);
    rid_score_secs_since_post_added(nil);
    rid_score_score(nil);
    rid_cstring_free(nil);
    rid_init_msg_isolate(0);
    rid_init_reply_isolate(0);
    _to_dart_for_Post();
    rid_post_debug(nil);
    rid_post_debug_pretty(nil);
    __include_dart_for_vec_score();
    rid_post_id(nil);
    rid_post_id_len(nil);
    rid_post_title(nil);
    rid_post_title_len(nil);
    rid_post_url(nil);
    rid_post_url_len(nil);
    rid_post_scores(nil);
    rid_len_vec_score(nil);
    rid_get_item_vec_score(nil, 0);
    _to_dart_for_Store();
    create_store();
    rid_store_unlock();
    rid_store_free();
    __include_dart_for_hash_map_string_post();
    rid_store_posts(nil);
    rid_export_rid_len_hash_map_string_post(nil);
    rid_export_rid_get_hash_map_string_post(nil, nil);
    rid_export_rid_contains_key_hash_map_string_post(nil, nil);
    rid_export_rid_keys_hash_map_string_post(nil);
    __include_dart_for_ridvec_string();
    rid_free_ridvec_string(RidVec_Pointer_String());
    rid_get_item_ridvec_string(RidVec_Pointer_String(), 0);
    _include_Store_field_wrappers();
    rid_msg_Initialize(0, nil);
    rid_msg_StartWatching(0, nil);
    rid_msg_StopWatching(0, nil);
}
// <rid:prevent_tree_shake End>