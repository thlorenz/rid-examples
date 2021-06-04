import Cocoa
import FlutterMacOS

public class Plugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(nil)
  }
}
// <rid:prevent_tree_shake Start>
func dummyCallsToPreventTreeShaking() {
    rid_store_debug(nil);
    rid_store_debug_pretty(nil);
    rid_cstring_free(nil);
    rid_store_last_added_id(nil);
    rid_store_todos(nil);
    rid_vec_Todo_len(nil);
    rid_vec_Todo_get(nil, 0);
    rid_store_filter(nil);
    rid_export_Store_filtered_todos(nil);
    rid_free_vec_Pointer_Todo(RidVec_Pointer_Todo());
    rid_get_item_Pointer_Todo(RidVec_Pointer_Todo(), 0);
    rid_todo_debug(nil);
    rid_todo_debug_pretty(nil);
    rid_todo_display(nil);
    rid_todo_id(nil);
    rid_todo_title(nil);
    rid_todo_title_len(nil);
    rid_todo_completed(nil);
    rid_filter_debug(0);
    rid_filter_debug_pretty(0);
    rid_filter_display(0);
    createStore();
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
    include_reply();
}
// <rid:prevent_tree_shake End>