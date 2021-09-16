import 'dart:async';
import '../generated/rid_api.dart';

const String RESPONSE_SEPARATOR = '^';

abstract class IReply {
  int? get reqId;
  String? get data;
}

typedef Decode<TReply> = TReply Function(ReplyStruct reply);

// TODO: error handling (could be part of Post data)
class ReplyChannel<TReply extends IReply> {
  final _zone = Zone.current;
  final StreamController<TReply> _sink;
  final Decode<TReply> _decode;
  final NativeLibrary _dl;
  late final _zonedAdd;
  late final Timer _pollTimer;
  int _lastReqId = 0;

  ReplyChannel._(this._dl, this._decode, bool isDebugMode)
      : _sink = StreamController.broadcast() {
    _zonedAdd = _zone.registerUnaryCallback(_add);
    _pollReplies();
  }

  void _pollReplies() {
    _pollTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      // TODO: ugly hack to prevent printing polling logs for now
      final save = rid.debugLock;
      rid.debugLock = null;
      // TODO: need to Readlock replies
      final ptr = _dl.rid_poll_reply();
      final castPtr = Pointer.fromAddress(RawReplyStruct(ptr.address));
      final reply = ptr.address == 0x0 ? null : castPtr.toDart();
      rid.debugLock = save;
      if (reply != null) {
        _onReceivedReply(reply);
        _dl.rid_handled_reply(reply.reqId);
      }
    });
  }

  void _onReceivedReply(ReplyStruct reply) {
    _zone.runUnary(_zonedAdd, reply);
  }

  void _add(ReplyStruct reply) {
    if (!_sink.isClosed) {
      _sink.add(_decode(reply));
    }
  }

  Stream<TReply> get stream => _sink.stream;
  Future<TReply> reply(int reqId) {
    assert(reqId != 0, "Invalid requestID ");
    return stream.firstWhere((reply) {
      final replyId = reply.reqId;
      if (replyId == null) return false;
      return reqId == replyId;
    }).onError((error, stackTrace) {
      print(
          "The responseChannel was disposed while a message was waiting for a reply.\n"
          "Did you forget to `await` the reply to the message with reqId: '$reqId'?\n"
          "Ignore the message further down about type 'Null'.\n"
          "The real problem is that no reply for the message was posted yet, but the reply \n"
          "stream is being disposed most likely via `store.dispose()` causing the following:.\n");
      print(error);
      print(stackTrace);
      return null as TReply;
    });
  }

  int get reqId {
    _lastReqId++;
    return _lastReqId;
  }

  Future<void> dispose() {
    if (_pollTimer.isActive) _pollTimer.cancel();
    return _sink.close();
  }

  static bool _initialized = false;
  static ReplyChannel<TReply> instance<TReply extends IReply>(
    NativeLibrary dl,
    Decode<TReply> decode,
    bool isDebugMode,
  ) {
    if (_initialized && !isDebugMode) {
      throw Exception(
          "The reply channel can only be initialized once unless running in debug mode");
    }
    _initialized = true;
    return ReplyChannel<TReply>._(dl, decode, isDebugMode);
  }
}
