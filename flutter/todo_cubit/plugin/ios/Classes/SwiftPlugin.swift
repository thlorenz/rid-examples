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
    _export_dart_enum_Filter();
    _to_dart_for_Store();
    rid_store_debug(nil);
    rid_store_debug_pretty(nil);
    create_store();
    rid_store_unlock();
    rid_store_free();
    __include_dart_for_vec_todo();
    rid_store_last_added_id(nil);
    rid_store_todos(nil);
    rid_store_filter(nil);
    rid_store_settings(nil);
    rid_len_vec_todo(nil);
    rid_get_item_vec_todo(nil, 0);
    _include_Store_field_wrappers();
    rid_cstring_free(nil);
    rid_init_msg_isolate(0);
    rid_init_reply_isolate(0);
    rid_export_Store_filtered_todos(nil);
    rid_export_Store_todo_by_id(nil, 0);
    __include_dart_for_ridvec_todo();
    rid_free_ridvec_todo(RidVec_Pointer_Todo());
    rid_get_item_ridvec_todo(RidVec_Pointer_Todo(), 0);
    _to_dart_for_Settings();
    rid_settings_debug(nil);
    rid_settings_debug_pretty(nil);
    rid_settings_auto_expire_completed_todos(nil);
    rid_settings_completed_expiry_millis(nil);
    _to_dart_for_Todo();
    rid_todo_debug(nil);
    rid_todo_debug_pretty(nil);
    rid_todo_id(nil);
    rid_todo_title(nil);
    rid_todo_title_len(nil);
    rid_todo_completed(nil);
    rid_todo_expiry_millis(nil);
    rid_filter_debug(0);
    rid_filter_debug_pretty(0);
    rid_msg_AddTodo(0, nil);
    rid_msg_RemoveTodo(0, 0);
    rid_msg_RemoveCompleted(0);
    rid_msg_CompleteTodo(0, 0);
    rid_msg_RestartTodo(0, 0);
    rid_msg_ToggleTodo(0, 0);
    rid_msg_CompleteAll(0);
    rid_msg_RestartAll(0);
    rid_msg_SetFilter(0, Filter(rawValue: 0));
    rid_msg_SetAutoExpireCompletedTodos(0, 0);
}
// <rid:prevent_tree_shake End>