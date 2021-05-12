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
    rid_model_debug(nil);
    rid_model_debug_pretty(nil);
    rid_cstring_free(nil);
    rid_model_last_added_id(nil);
    rid_model_todos(nil);
    rid_vec_Todo_len(nil);
    rid_vec_Todo_get(nil, 0);
    rid_model_filter(nil);
    initModel();
    rid_export_Model_filtered_todos(nil);
    rid_free_vec_Pointer_Todo(RidVec_Pointer_Todo());
    rid_get_item_Pointer_Todo(RidVec_Pointer_Todo(), 0);
    rid_free_Model(nil);
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
    rid_msg_AddTodo(nil, nil);
    rid_msg_RemoveTodo(nil, 0);
    rid_msg_RemoveCompleted(nil);
    rid_msg_ToggleTodo(nil, 0);
    rid_msg_CompleteAll(nil);
    rid_msg_RestartAll(nil);
    rid_msg_SetFilter(nil, Filter(rawValue: 0));
}
// <rid:prevent_tree_shake End>