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
    rid_rawstore_debug(nil);
    rid_rawstore_debug_pretty(nil);
    rid_cstring_free(nil);
    rid_store_last_added_id(nil);
    rid_store_todos(nil);
    rid_vec_Todo_len(nil);
    rid_vec_Todo_get(nil, 0);
    rid_store_filter(nil);
    rid_store_auto_expire_completed_todos(nil);
    rid_export_RawStore_filtered_todos(nil);
    rid_export_RawStore_todo_by_id(nil, 0);
    rid_free_vec_Pointer_RawTodo(RidVec_Pointer_RawTodo());
    rid_get_item_Pointer_RawTodo(RidVec_Pointer_RawTodo(), 0);
    rid_rawtodo_debug(nil);
    rid_rawtodo_debug_pretty(nil);
    rid_rawtodo_display(nil);
    _to_dart_for_Todo();
    rid_todo_id(nil);
    rid_todo_title(nil);
    rid_todo_title_len(nil);
    rid_todo_completed(nil);
    rid_todo_expiry_millis(nil);
    completedExpiryMillis();
    rid_filter_debug(0);
    rid_filter_debug_pretty(0);
    rid_filter_display(0);
    create_store();
    rid_store_lock();
    rid_store_unlock();
    rid_store_free();
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
    include_reply();
}
// <rid:prevent_tree_shake End>