import 'dart:async' as dart_async;
import 'dart:collection' as dart_collection;
import 'dart:convert' as dart_convert;
import 'package:plugin/wasm/utils.dart';
import 'package:plugin/wasm/reply_channel.dart';

import 'ffigen_binding.dart' as package_ffi;
import 'ffigen_binding.dart' as dart_ffi;
import 'ffigen_binding.dart' as ffigen_bind;

import 'package:flutter/foundation.dart' as Foundation;

// Forwarding dart_ffi types essential to access raw Rust structs
export 'ffigen_binding.dart' show Pointer;

// Forwarding Dart Types for raw Rust structs
export 'ffigen_binding.dart'
    show
        ReplyStruct,
        RawReplyStruct,
        RawSettings,
        RawStore,
        RawTodo,
        Vec_RawTodo;

// Forwarding library itself
export 'ffigen_binding.dart' show NativeLibrary;

//
// Rid internal Utils
//
// This file defines identical util functions and vars as ./_rid_utils_dart.dart
final _isDebugMode = Foundation.kDebugMode;

//
// Extensions to provide an API for FFI calls into Rust
//
/// Dart enum implementation for Rust Filter enum.
enum Filter { Completed, Pending, All }

// Dart class representation of ReplyStruct.
class ReplyStruct {
  final int ty;

  final int reqId;
  final String data;
  const ReplyStruct._(this.ty, this.reqId, this.data);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReplyStruct &&
            ty == other.ty &&
            reqId == other.reqId &&
            data == other.data;
  }

  @override
  int get hashCode {
    return ty.hashCode ^ reqId.hashCode ^ data.hashCode;
  }

  @override
  String toString() {
    return 'ReplyStruct{ty: $ty, reqId: $reqId, data: $data}';
  }
}

// Extension method `toDart` to instantiate a Dart ReplyStruct by resolving all fields from Rust
extension Rid_ToDart_ExtOnReplyStruct
    on dart_ffi.Pointer<ffigen_bind.RawReplyStruct> {
  ReplyStruct toDart() {
    ridStoreLock();
    final instance = ReplyStruct._(this.ty, this.req_id, this.data);
    ridStoreUnlock();
    return instance;
  }
}

extension rid_rawreplystruct_debug_ExtOnReplyStruct
    on dart_ffi.Pointer<ffigen_bind.RawReplyStruct> {
  String debug([bool pretty = false]) {
    final ptr = pretty
        ? rid_ffi.rid_rawreplystruct_debug_pretty(this)
        : rid_ffi.rid_rawreplystruct_debug(this);
    final s = ptr.toDartString();
    ptr.free();
    return s;
  }
}

extension Rid_Model_ExtOnPointerRawReplyStruct
    on dart_ffi.Pointer<ffigen_bind.RawReplyStruct> {
  int get ty => rid_ffi.rid_replystruct_ty(this);

  int get req_id => rid_ffi.rid_replystruct_req_id(this);
  String get data {
    int len = rid_ffi.rid_replystruct_data_len(this);
    dart_ffi.Pointer<dart_ffi.Int8> ptr = rid_ffi.rid_replystruct_data(this);
    String s = ptr.toDartString(len);
    ptr.free();
    return s;
  }
}

Future<void> initWasm(String wasmFile) async {
  final moduleData = await loadWasmFromNetwork(wasmFile);
  await ffigen_bind.NativeLibrary.init(moduleData);
}

// rid API that provides memory safety and which is recommended to use.
// Use the lower level API (via `Store.raw`) only when you need more control,
// i.e. if you run into performance issues with this higher level API.
class Store {
  final dart_ffi.Pointer<ffigen_bind.RawStore> _store;

  /// Provides direct access to the underlying Rust store.
  /// You should not need to work with this lower level API except for cases
  /// where you want more fine grained control over how data is retrieved from
  /// Rust and converted into Dart, i.e. to tweak performance.
  /// In all other cases you should use the higher level API which is much
  /// easier to use and also guarantees memory safety.
  dart_ffi.Pointer<ffigen_bind.RawStore> get raw => _store;
  const Store(this._store);
  T _read<T>(T Function(dart_ffi.Pointer<ffigen_bind.RawStore> store) accessor,
      String? request) {
    return _store.runLocked(accessor, request: request);
  }

  StoreState toDartState() => _store.toDart();
  String debug([bool pretty = false]) => _store.debug(pretty);

  /// Disposes the store and closes the Rust reply channel in order to allow the app
  /// to exit properly. This needs to be called when exiting a Dart application.
  Future<void> dispose() => _store.dispose();
  static Store? _instance;
  static Store get instance {
    if (_instance == null) {
      _instance = Store(_createStore());
    }
    return _instance!;
  }
}

// Dart class representation of Store.
class StoreState {
  final int lastAddedId;
  final List<Todo> todos;
  final Filter filter;
  final Settings settings;
  const StoreState._(this.lastAddedId, this.todos, this.filter, this.settings);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StoreState &&
            lastAddedId == other.lastAddedId &&
            todos == other.todos &&
            filter == other.filter &&
            settings == other.settings;
  }

  @override
  int get hashCode {
    return lastAddedId.hashCode ^
        todos.hashCode ^
        filter.hashCode ^
        settings.hashCode;
  }

  @override
  String toString() {
    return 'StoreState{lastAddedId: $lastAddedId, todos: $todos, filter: $filter, settings: $settings}';
  }
}

// Extension method `toDart` to instantiate a Dart Store by resolving all fields from Rust
extension Rid_ToDart_ExtOnStore on dart_ffi.Pointer<ffigen_bind.RawStore> {
  StoreState toDart() {
    ridStoreLock();
    final instance = StoreState._(this.last_added_id, this.todos.toDart(),
        Filter.values[this.filter], this.settings.toDart());
    ridStoreUnlock();
    return instance;
  }
}

extension rid_rawstore_debug_ExtOnStore
    on dart_ffi.Pointer<ffigen_bind.RawStore> {
  String debug([bool pretty = false]) {
    final ptr = pretty
        ? rid_ffi.rid_rawstore_debug_pretty(this)
        : rid_ffi.rid_rawstore_debug(this);
    final s = ptr.toDartString();
    ptr.free();
    return s;
  }
}

void _initRid() {
  print('Set RID_DEBUG_LOCK to change if/how locking the rid store is logged');
  print('Set RID_DEBUG_REPLY to change if/how posted replies are logged');
  print(
      'Set RID_MSG_TIMEOUT to change the default for if/when messages without reply time out');
}

dart_ffi.Pointer<ffigen_bind.RawStore> _createStore() {
  _initRid();
  return rid_ffi.create_store();
}

int _locks = 0;
void Function(bool, int, {String? request})? RID_DEBUG_LOCK =
    (bool locking, int locks, {String? request}) {
  if (locking) {
    if (locks == 1) print('🔐 {');
    if (request != null) print(' $request');
  } else {
    if (locks == 0) print('} 🔓');
  }
};
void ridStoreLock({String? request}) {
  if (_locks == 0) rid_ffi.rid_store_lock();
  _locks++;
  if (RID_DEBUG_LOCK != null) RID_DEBUG_LOCK!(true, _locks, request: request);
}

void ridStoreUnlock() {
  _locks--;
  if (RID_DEBUG_LOCK != null) RID_DEBUG_LOCK!(false, _locks);
  if (_locks == 0) rid_ffi.rid_store_unlock();
}

extension rid_store_specific_extension
    on dart_ffi.Pointer<ffigen_bind.RawStore> {
  /// Executes the provided callback while locking the store to guarantee that the
  /// store is not modified while that callback runs.
  T runLocked<T>(T Function(dart_ffi.Pointer<ffigen_bind.RawStore>) fn,
      {String? request}) {
    try {
      ridStoreLock(request: request);
      return fn(this);
    } finally {
      ridStoreUnlock();
    }
  }

  /// Disposes the store and closes the Rust reply channel in order to allow the app
  /// to exit properly. This needs to be called when exiting a Dart application.
  Future<void> dispose() {
    return replyChannel.dispose();
  }
}

extension Rid_Model_ExtOnPointerRawStore
    on dart_ffi.Pointer<ffigen_bind.RawStore> {
  int get last_added_id => rid_ffi.rid_store_last_added_id(this);
  dart_ffi.Pointer<ffigen_bind.Vec_RawTodo> get todos =>
      rid_ffi.rid_store_todos(this);
  int get filter => rid_ffi.rid_store_filter(this);
  dart_ffi.Pointer<ffigen_bind.RawSettings> get settings =>
      rid_ffi.rid_store_settings(this);
}

extension Rid_Vec_ExtOnPointerVec_RawTodo
    on dart_ffi.Pointer<ffigen_bind.Vec_RawTodo> {
  int get length => rid_ffi.rid_vec_Todo_len(this);
  dart_ffi.Pointer<ffigen_bind.RawTodo> operator [](int idx) {
    final len = this.length;
    if (!(0 <= idx && idx < len)) {
      throw AssertionError(
          "Out of range access on List<RawTodo>[$idx] of length $len");
    }
    return rid_ffi.rid_vec_Todo_get(this, idx);
  }

  Rid_Vec_RawTodo_Iterable iter() => Rid_Vec_RawTodo_Iterable(this);

  /// Converts this Vec pointer into a Dart [List&lt;Todo&gt;]
  List<Todo> toDart() {
    ridStoreLock();
    final list = this.iter().map((raw) => raw.toDart()).toList();
    ridStoreUnlock();
    return list;
  }
}

class Rid_Vec_RawTodo_Iterator
    implements Iterator<dart_ffi.Pointer<ffigen_bind.RawTodo>> {
  int _currentIdx = -1;
  final dart_ffi.Pointer<ffigen_bind.Vec_RawTodo> _vec;
  final int _limit;
  Rid_Vec_RawTodo_Iterator(this._vec) : _limit = _vec.length - 1;
  dart_ffi.Pointer<ffigen_bind.RawTodo> get current => _vec[_currentIdx];
  bool moveNext() {
    if (_currentIdx >= _limit) return false;
    _currentIdx++;
    return true;
  }
}

class Rid_Vec_RawTodo_Iterable
    with dart_collection.IterableMixin<dart_ffi.Pointer<ffigen_bind.RawTodo>> {
  final dart_ffi.Pointer<ffigen_bind.Vec_RawTodo> _vec;
  Rid_Vec_RawTodo_Iterable(this._vec);
  Iterator<dart_ffi.Pointer<ffigen_bind.RawTodo>> get iterator =>
      Rid_Vec_RawTodo_Iterator(this._vec);
}

/// Wrappers to access fields with the higher level API which is memory safe.
extension FieldAccessWrappersOn_Store on Store {
  int get lastAddedId =>
      _read((store) => store.last_added_id, 'store.last_added_id');
  List<Todo> get todos => _read((store) => store.todos.toDart(), 'store.todos');
  Filter get filter =>
      _read((store) => Filter.values[store.filter], 'store.filter');
  Settings get settings =>
      _read((store) => store.settings.toDart(), 'store.settings');
}

// FFI methods generated for exported instance impl methods of struct 'RawStore'.
// Below is the dart extension to call those methods.
extension Rid_ImplInstanceMethods_ExtOnPointerRawStore
    on dart_ffi.Pointer<ffigen_bind.RawStore> {
  String filtered_todos() {
    final ptr = rid_ffi.rid_export_RawStore_filtered_todos_string(this);
    final s = ptr.toDartString();
    ptr.free();
    return s;
  }

  dart_ffi.Pointer<ffigen_bind.RawTodo>? todo_by_id(int arg0) {
    final res = rid_ffi.rid_export_RawStore_todo_by_id(this, arg0);
    final ret = res.address == 0x0 ? null : res;
    return ret;
  }
}

// Below are the higher level API wrappers for the same instance method available on Store.
extension Rid_ImplInstanceMethods_ExtOnStore on Store {
  List<Todo> filteredTodos() => _read((store) {
        final res = store.filtered_todos();
        final json = dart_convert.jsonDecode(res).cast<Map<String, dynamic>>();
        return json
            .map<Todo>((Map<String, dynamic> x) => Todo.fromJSON(x))
            .toList();
      }, 'store.filteredTodos()');

  Todo? todoById(int arg0) => _read(
      (store) => store.todo_by_id(arg0)?.toDart(), 'store.todoById($arg0)');
}

// Dart class representation of Settings.
class Settings {
  final bool autoExpireCompletedTodos;

  final int completedExpiryMillis;
  const Settings._(this.autoExpireCompletedTodos, this.completedExpiryMillis);
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Settings &&
            autoExpireCompletedTodos == other.autoExpireCompletedTodos &&
            completedExpiryMillis == other.completedExpiryMillis;
  }

  @override
  int get hashCode {
    return autoExpireCompletedTodos.hashCode ^ completedExpiryMillis.hashCode;
  }

  @override
  String toString() {
    return 'Settings{autoExpireCompletedTodos: $autoExpireCompletedTodos, completedExpiryMillis: $completedExpiryMillis}';
  }
}

// Extension method `toDart` to instantiate a Dart Settings by resolving all fields from Rust
extension Rid_ToDart_ExtOnSettings
    on dart_ffi.Pointer<ffigen_bind.RawSettings> {
  Settings toDart() {
    ridStoreLock();
    final instance = Settings._(
        this.auto_expire_completed_todos, this.completed_expiry_millis);
    ridStoreUnlock();
    return instance;
  }
}

extension rid_rawsettings_debug_ExtOnSettings
    on dart_ffi.Pointer<ffigen_bind.RawSettings> {
  String debug([bool pretty = false]) {
    final ptr = pretty
        ? rid_ffi.rid_rawsettings_debug_pretty(this)
        : rid_ffi.rid_rawsettings_debug(this);
    final s = ptr.toDartString();
    ptr.free();
    return s;
  }
}

extension Rid_Model_ExtOnPointerRawSettings
    on dart_ffi.Pointer<ffigen_bind.RawSettings> {
  bool get auto_expire_completed_todos =>
      rid_ffi.rid_settings_auto_expire_completed_todos(this) != 0;

  int get completed_expiry_millis =>
      rid_ffi.rid_settings_completed_expiry_millis(this);
}

// Dart class representation of Todo.
class Todo {
  final int id;
  final String title;
  final bool completed;

  final int expiryMillis;
  const Todo._(this.id, this.title, this.completed, this.expiryMillis);

  // TODO(thlorenz): should be easy enough to generate
  factory Todo.fromJSON(Map<String, dynamic> json) => Todo._(
        json['id'] as int,
        json['title'] as String,
        json['completed'] as bool,
        json['expiry_millis'] as int,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Todo &&
            id == other.id &&
            title == other.title &&
            completed == other.completed &&
            expiryMillis == other.expiryMillis;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        completed.hashCode ^
        expiryMillis.hashCode;
  }

  @override
  String toString() {
    return 'Todo{id: $id, title: $title, completed: $completed, expiryMillis: $expiryMillis}';
  }
}

// Extension method `toDart` to instantiate a Dart Todo by resolving all fields from Rust
extension Rid_ToDart_ExtOnTodo on dart_ffi.Pointer<ffigen_bind.RawTodo> {
  Todo toDart() {
    ridStoreLock();
    final instance =
        Todo._(this.id, this.title, this.completed, this.expiry_millis);
    ridStoreUnlock();
    return instance;
  }
}

extension rid_rawtodo_debug_ExtOnTodo on dart_ffi.Pointer<ffigen_bind.RawTodo> {
  String debug([bool pretty = false]) {
    final ptr = pretty
        ? rid_ffi.rid_rawtodo_debug_pretty(this)
        : rid_ffi.rid_rawtodo_debug(this);
    final s = ptr.toDartString();
    ptr.free();
    return s;
  }
}

extension Rid_Model_ExtOnPointerRawTodo
    on dart_ffi.Pointer<ffigen_bind.RawTodo> {
  int get id => rid_ffi.rid_todo_id(this);
  String get title {
    int len = rid_ffi.rid_todo_title_len(this);
    dart_ffi.Pointer<dart_ffi.Int8> ptr = rid_ffi.rid_todo_title(this);
    String s = ptr.toDartString(len);
    ptr.free();
    return s;
  }

  bool get completed => rid_ffi.rid_todo_completed(this) != 0;

  int get expiry_millis => rid_ffi.rid_todo_expiry_millis(this);
}

extension rid_filter_debug_ExtOnFilter on Filter {
  String debug([bool pretty = false]) {
    final ptr = pretty
        ? rid_ffi.rid_filter_debug_pretty(this.index)
        : rid_ffi.rid_filter_debug(this.index);
    final s = ptr.toDartString();
    ptr.free();
    return s;
  }
}

final Duration? RID_MSG_TIMEOUT = const Duration(milliseconds: 200);
Future<PostedReply> _replyWithTimeout(
  Future<PostedReply> reply,
  String msgCall,
  StackTrace applicationStack,
  Duration timeout,
) {
  final failureMsg = '''$msgCall timed out\n
  ---- Application Stack ----\n
  $applicationStack\n
  ---- Internal Stack ----
  ''';
  return reply.timeout(timeout,
      onTimeout: () => throw dart_async.TimeoutException(failureMsg, timeout));
}

extension Rid_Message_ExtOnPointerStoreForMsg
    on dart_ffi.Pointer<ffigen_bind.RawStore> {
  Future<PostedReply> msgAddTodo(String arg0, {Duration? timeout}) {
    final reqId = replyChannel.reqId;
    rid_ffi.rid_msg_AddTodo(reqId, arg0.toNativeInt8());
    final reply = _isDebugMode && RID_DEBUG_REPLY != null
        ? replyChannel.reply(reqId).then((PostedReply reply) {
            if (RID_DEBUG_REPLY != null) RID_DEBUG_REPLY!(reply);
            return reply;
          })
        : replyChannel.reply(reqId);
    if (!_isDebugMode) return reply;
    timeout ??= RID_MSG_TIMEOUT;
    if (timeout == null) return reply;
    final msgCall = 'msgAddTodo($arg0) with reqId: $reqId';
    return _replyWithTimeout(reply, msgCall, StackTrace.current, timeout);
  }

  Future<PostedReply> msgRemoveTodo(int arg0, {Duration? timeout}) {
    final reqId = replyChannel.reqId;
    rid_ffi.rid_msg_RemoveTodo(reqId, arg0);
    final reply = _isDebugMode && RID_DEBUG_REPLY != null
        ? replyChannel.reply(reqId).then((PostedReply reply) {
            if (RID_DEBUG_REPLY != null) RID_DEBUG_REPLY!(reply);
            return reply;
          })
        : replyChannel.reply(reqId);
    if (!_isDebugMode) return reply;
    timeout ??= RID_MSG_TIMEOUT;
    if (timeout == null) return reply;
    final msgCall = 'msgRemoveTodo($arg0) with reqId: $reqId';
    return _replyWithTimeout(reply, msgCall, StackTrace.current, timeout);
  }

  Future<PostedReply> msgRemoveCompleted({Duration? timeout}) {
    final reqId = replyChannel.reqId;
    rid_ffi.rid_msg_RemoveCompleted(
      reqId,
    );
    final reply = _isDebugMode && RID_DEBUG_REPLY != null
        ? replyChannel.reply(reqId).then((PostedReply reply) {
            if (RID_DEBUG_REPLY != null) RID_DEBUG_REPLY!(reply);
            return reply;
          })
        : replyChannel.reply(reqId);
    if (!_isDebugMode) return reply;
    timeout ??= RID_MSG_TIMEOUT;
    if (timeout == null) return reply;
    final msgCall = 'msgRemoveCompleted() with reqId: $reqId';
    return _replyWithTimeout(reply, msgCall, StackTrace.current, timeout);
  }

  Future<PostedReply> msgCompleteTodo(int arg0, {Duration? timeout}) {
    final reqId = replyChannel.reqId;
    rid_ffi.rid_msg_CompleteTodo(reqId, arg0);
    final reply = _isDebugMode && RID_DEBUG_REPLY != null
        ? replyChannel.reply(reqId).then((PostedReply reply) {
            if (RID_DEBUG_REPLY != null) RID_DEBUG_REPLY!(reply);
            return reply;
          })
        : replyChannel.reply(reqId);
    if (!_isDebugMode) return reply;
    timeout ??= RID_MSG_TIMEOUT;
    if (timeout == null) return reply;
    final msgCall = 'msgCompleteTodo($arg0) with reqId: $reqId';
    return _replyWithTimeout(reply, msgCall, StackTrace.current, timeout);
  }

  Future<PostedReply> msgRestartTodo(int arg0, {Duration? timeout}) {
    final reqId = replyChannel.reqId;
    rid_ffi.rid_msg_RestartTodo(reqId, arg0);
    final reply = _isDebugMode && RID_DEBUG_REPLY != null
        ? replyChannel.reply(reqId).then((PostedReply reply) {
            if (RID_DEBUG_REPLY != null) RID_DEBUG_REPLY!(reply);
            return reply;
          })
        : replyChannel.reply(reqId);
    if (!_isDebugMode) return reply;
    timeout ??= RID_MSG_TIMEOUT;
    if (timeout == null) return reply;
    final msgCall = 'msgRestartTodo($arg0) with reqId: $reqId';
    return _replyWithTimeout(reply, msgCall, StackTrace.current, timeout);
  }

  Future<PostedReply> msgToggleTodo(int arg0, {Duration? timeout}) {
    final reqId = replyChannel.reqId;
    rid_ffi.rid_msg_ToggleTodo(reqId, arg0);
    final reply = _isDebugMode && RID_DEBUG_REPLY != null
        ? replyChannel.reply(reqId).then((PostedReply reply) {
            if (RID_DEBUG_REPLY != null) RID_DEBUG_REPLY!(reply);
            return reply;
          })
        : replyChannel.reply(reqId);
    if (!_isDebugMode) return reply;
    timeout ??= RID_MSG_TIMEOUT;
    if (timeout == null) return reply;
    final msgCall = 'msgToggleTodo($arg0) with reqId: $reqId';
    return _replyWithTimeout(reply, msgCall, StackTrace.current, timeout);
  }

  Future<PostedReply> msgCompleteAll({Duration? timeout}) {
    final reqId = replyChannel.reqId;
    rid_ffi.rid_msg_CompleteAll(
      reqId,
    );
    final reply = _isDebugMode && RID_DEBUG_REPLY != null
        ? replyChannel.reply(reqId).then((PostedReply reply) {
            if (RID_DEBUG_REPLY != null) RID_DEBUG_REPLY!(reply);
            return reply;
          })
        : replyChannel.reply(reqId);
    if (!_isDebugMode) return reply;
    timeout ??= RID_MSG_TIMEOUT;
    if (timeout == null) return reply;
    final msgCall = 'msgCompleteAll() with reqId: $reqId';
    return _replyWithTimeout(reply, msgCall, StackTrace.current, timeout);
  }

  Future<PostedReply> msgRestartAll({Duration? timeout}) {
    final reqId = replyChannel.reqId;
    rid_ffi.rid_msg_RestartAll(
      reqId,
    );
    final reply = _isDebugMode && RID_DEBUG_REPLY != null
        ? replyChannel.reply(reqId).then((PostedReply reply) {
            if (RID_DEBUG_REPLY != null) RID_DEBUG_REPLY!(reply);
            return reply;
          })
        : replyChannel.reply(reqId);
    if (!_isDebugMode) return reply;
    timeout ??= RID_MSG_TIMEOUT;
    if (timeout == null) return reply;
    final msgCall = 'msgRestartAll() with reqId: $reqId';
    return _replyWithTimeout(reply, msgCall, StackTrace.current, timeout);
  }

  Future<PostedReply> msgSetFilter(int arg0, {Duration? timeout}) {
    final reqId = replyChannel.reqId;
    rid_ffi.rid_msg_SetFilter(reqId, arg0);
    final reply = _isDebugMode && RID_DEBUG_REPLY != null
        ? replyChannel.reply(reqId).then((PostedReply reply) {
            if (RID_DEBUG_REPLY != null) RID_DEBUG_REPLY!(reply);
            return reply;
          })
        : replyChannel.reply(reqId);
    if (!_isDebugMode) return reply;
    timeout ??= RID_MSG_TIMEOUT;
    if (timeout == null) return reply;
    final msgCall = 'msgSetFilter($arg0) with reqId: $reqId';
    return _replyWithTimeout(reply, msgCall, StackTrace.current, timeout);
  }

  Future<PostedReply> msgSetAutoExpireCompletedTodos(bool arg0,
      {Duration? timeout}) {
    final reqId = replyChannel.reqId;
    rid_ffi.rid_msg_SetAutoExpireCompletedTodos(reqId, arg0 ? 1 : 0);
    final reply = _isDebugMode && RID_DEBUG_REPLY != null
        ? replyChannel.reply(reqId).then((PostedReply reply) {
            if (RID_DEBUG_REPLY != null) RID_DEBUG_REPLY!(reply);
            return reply;
          })
        : replyChannel.reply(reqId);
    if (!_isDebugMode) return reply;
    timeout ??= RID_MSG_TIMEOUT;
    if (timeout == null) return reply;
    final msgCall = 'msgSetAutoExpireCompletedTodos($arg0) with reqId: $reqId';
    return _replyWithTimeout(reply, msgCall, StackTrace.current, timeout);
  }
}

extension MsgApiFor_Store on Store {
  Future<PostedReply> msgAddTodo(String arg0, {Duration? timeout}) {
    return _store.msgAddTodo(arg0, timeout: timeout);
  }

  Future<PostedReply> msgRemoveTodo(int arg0, {Duration? timeout}) {
    return _store.msgRemoveTodo(arg0, timeout: timeout);
  }

  Future<PostedReply> msgRemoveCompleted({Duration? timeout}) {
    return _store.msgRemoveCompleted(timeout: timeout);
  }

  Future<PostedReply> msgCompleteTodo(int arg0, {Duration? timeout}) {
    return _store.msgCompleteTodo(arg0, timeout: timeout);
  }

  Future<PostedReply> msgRestartTodo(int arg0, {Duration? timeout}) {
    return _store.msgRestartTodo(arg0, timeout: timeout);
  }

  Future<PostedReply> msgToggleTodo(int arg0, {Duration? timeout}) {
    return _store.msgToggleTodo(arg0, timeout: timeout);
  }

  Future<PostedReply> msgCompleteAll({Duration? timeout}) {
    return _store.msgCompleteAll(timeout: timeout);
  }

  Future<PostedReply> msgRestartAll({Duration? timeout}) {
    return _store.msgRestartAll(timeout: timeout);
  }

  Future<PostedReply> msgSetFilter(Filter arg0, {Duration? timeout}) {
    return _store.msgSetFilter(arg0.index, timeout: timeout);
  }

  Future<PostedReply> msgSetAutoExpireCompletedTodos(bool arg0,
      {Duration? timeout}) {
    return _store.msgSetAutoExpireCompletedTodos(arg0, timeout: timeout);
  }
}

/// Dart enum implementation for Rust Reply enum.
enum Reply {
  AddedTodo,
  RemovedTodo,
  RemovedCompleted,
  CompletedTodo,
  RestartedTodo,
  ToggledTodo,
  CompletedAll,
  RestartedAll,
  SetFilter,
  SetAutoExpireCompletedTodos,
  CompletedTodoExpired,
  Tick
}

class PostedReply extends IReply {
  final Reply type;
  final int? reqId;
  final String? data;
  PostedReply._(this.type, this.reqId, this.data);
  @override
  String toString() {
    return '''PostedReply {
    type:  ${this.type.toString().substring('Reply.'.length)}
    reqId: $reqId
    data:  $data
  }
  ''';
  }
}

void Function(PostedReply)? RID_DEBUG_REPLY = (PostedReply reply) {
  print('$reply');
};
PostedReply wasmDecode(ReplyStruct reply) {
  return PostedReply._(Reply.values[reply.ty], reply.reqId, null);
}

late ReplyChannel<PostedReply>? _replyChannel = null;
ReplyChannel<PostedReply> get replyChannel {
  if (_replyChannel == null) {
    _replyChannel = ReplyChannel.instance(_dl, wasmDecode, _isDebugMode);
  }
  return _replyChannel!;
}

extension Rid_ExtOnPointerInt8 on dart_ffi.Pointer<dart_ffi.Int8> {
  String toDartString([int? len]) {
    return ffigen_bind.toDartString(this);
  }

  void free() {
    rid_ffi.rid_cstring_free(this);
  }
}

//
// Exporting Native Library to call Rust functions directly
//
ffigen_bind.NativeLibrary get _dl => ffigen_bind.NativeLibrary.instance;
ffigen_bind.NativeLibrary get rid_ffi => _dl;
