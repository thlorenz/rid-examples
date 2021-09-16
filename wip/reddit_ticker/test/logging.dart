import 'dart:async';
import 'package:reddit_ticker/generated/rid_api.dart';

const RUST_ICON = '🦀';
const WARN_ICON = '⚠️ ';
const INFO_ICON = '💡';
const DEBG_ICON = '🪲';
const ERR_ICON = '❌';

const WARN_PREFIX = '$RUST_ICON $WARN_ICON';
const INFO_PREFIX = '$RUST_ICON $INFO_ICON';
const DEBG_PREFIX = '$RUST_ICON $DEBG_ICON';
const ERR_PREFIX = '$RUST_ICON $ERR_ICON';

const DETAILS_INDENT = '\n       ';

class LogMessageHandler {
  late final StreamSubscription<RidMessage>? _logMessagesSub;

  LogMessageHandler._() {
    _logMessagesSub = rid.messageChannel.stream.listen((RidMessage msg) {
      late final String prefix;
      switch (msg.type) {
        case RidMessageType.Severe:
        case RidMessageType.Error:
          return;
        case RidMessageType.LogWarn:
          prefix = WARN_PREFIX;
          break;
        case RidMessageType.LogInfo:
          prefix = INFO_PREFIX;
          break;
        case RidMessageType.LogDebug:
          prefix = DEBG_PREFIX;
          break;
      }

      print('$prefix: ${msg.message}');
    });
  }

  void dispose() {
    _logMessagesSub?.cancel();
    _logMessagesSub = null;
  }

  static LogMessageHandler? _instance;
  static LogMessageHandler get instance {
    if (_instance == null) {
      _instance = LogMessageHandler._();
    }
    return _instance!;
  }
}

class ErrorHandler {
  late final StreamSubscription<RidMessage>? _errorSub;

  ErrorHandler._() {
    _errorSub = rid.messageChannel.stream.listen((RidMessage msg) {
      switch (msg.type) {
        case RidMessageType.LogWarn:
        case RidMessageType.LogInfo:
        case RidMessageType.LogDebug:
          return;
        case RidMessageType.Severe:
          final indentedDetails = msg.details?.split('\n').join(DETAILS_INDENT);
          print('$ERR_PREFIX: ${msg.message}$DETAILS_INDENT$indentedDetails');
          break;

        case RidMessageType.Error:
          final indentedDetails = msg.details?.split('\n').join('\n    ');
          print('$ERR_PREFIX: ${msg.message}\n       $indentedDetails');
          break;
      }
    });
  }

  void dispose() {
    _errorSub?.cancel();
    _errorSub = null;
  }

  static ErrorHandler? _instance;
  static ErrorHandler get instance {
    if (_instance == null) {
      _instance = ErrorHandler._();
    }
    return _instance!;
  }
}

class RidMessaging {
  static void init() {
    LogMessageHandler.instance;
    ErrorHandler.instance;
  }
}
