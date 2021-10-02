import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin/generated/rid_api.dart';

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
        case RidMessageType.MsgWarn:
        case RidMessageType.MsgInfo:
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

      debugPrint('$prefix: ${msg.message}');
    });
  }

  void dispose() {
    _logMessagesSub?.cancel();
    _logMessagesSub = null;
  }

  static LogMessageHandler? _instance;
  static LogMessageHandler get instance {
    _instance ??= LogMessageHandler._();
    return _instance!;
  }
}

class ErrorHandler {
  BuildContext? _context;
  late final StreamSubscription<RidMessage>? _errorSub;

  ErrorHandler._() {
    _errorSub = rid.messageChannel.stream.listen((RidMessage msg) {
      switch (msg.type) {
        case RidMessageType.LogWarn:
        case RidMessageType.LogInfo:
        case RidMessageType.LogDebug:
        case RidMessageType.MsgWarn:
        case RidMessageType.MsgInfo:
          return;
        case RidMessageType.Severe:
          final indentedDetails = msg.details?.split('\n').join(DETAILS_INDENT);
          debugPrint(
              '$ERR_PREFIX: ${msg.message}$DETAILS_INDENT$indentedDetails');

          // Show UI message if we were provided a BuildContext
          if (_context != null) {
            ScaffoldMessenger.of(_context!).showMaterialBanner(
              MaterialBanner(
                backgroundColor: Colors.deepOrange,
                content: Text(msg.message),
                actions: [
                  TextButton(
                    child: const Text('Dismiss'),
                    onPressed: () => ScaffoldMessenger.of(_context!)
                        .hideCurrentMaterialBanner(),
                  ),
                ],
              ),
            );
          }
          break;

        case RidMessageType.Error:
          final indentedDetails = msg.details?.split('\n').join('\n    ');
          debugPrint('$ERR_PREFIX: ${msg.message}\n       $indentedDetails');

          // Show UI message if we were provided a BuildContext
          if (_context != null) {
            ScaffoldMessenger.of(_context!).showSnackBar(
              SnackBar(
                backgroundColor: Colors.orange,
                content: Text(msg.message),
              ),
            );
          }
          break;
      }
    });
  }

  set context(BuildContext val) => _context = val;

  void dispose() {
    _errorSub?.cancel();
    _errorSub = null;
  }

  static ErrorHandler? _instance;
  static ErrorHandler get instance {
    _instance ??= ErrorHandler._();
    return _instance!;
  }
}

class UserMsgHandler {
  BuildContext? _context;
  late final StreamSubscription<RidMessage>? _errorSub;

  UserMsgHandler._() {
    _errorSub = rid.messageChannel.stream.listen((RidMessage msg) {
      switch (msg.type) {
        case RidMessageType.LogWarn:
        case RidMessageType.LogInfo:
        case RidMessageType.LogDebug:
        case RidMessageType.Severe:
        case RidMessageType.Error:
          return;
        case RidMessageType.MsgWarn:
          debugPrint('$WARN_PREFIX ${msg.message}');

          // Show UI message if we were provided a BuildContext
          if (_context != null) {
            ScaffoldMessenger.of(_context!).showMaterialBanner(
              MaterialBanner(
                backgroundColor: Colors.orange,
                content: Text(msg.message),
                actions: [
                  TextButton(
                    child: const Text('Dismiss'),
                    onPressed: () => ScaffoldMessenger.of(_context!)
                        .hideCurrentMaterialBanner(),
                  ),
                ],
              ),
            );
          } else {
            debugPrint(
                'WARN: cannot show user message since no `BuildContext` was provided to UserMsgHandler');
          }
          break;

        case RidMessageType.MsgInfo:
          debugPrint('$INFO_PREFIX ${msg.message}');

          // Show UI message if we were provided a BuildContext
          if (_context != null) {
            ScaffoldMessenger.of(_context!).showSnackBar(
              SnackBar(
                backgroundColor: Colors.orange,
                content: Text(msg.message),
              ),
            );
          } else {
            debugPrint(
                'WARN: cannot show user message since no `BuildContext` was provided to UserMsgHandler');
          }
          break;
      }
    });
  }

  set context(BuildContext val) => _context = val;

  void dispose() {
    _errorSub?.cancel();
    _errorSub = null;
  }

  static UserMsgHandler? _instance;
  static UserMsgHandler get instance {
    _instance ??= UserMsgHandler._();
    return _instance!;
  }
}

class RidMessaging {
  static void init() {
    LogMessageHandler.instance;
    ErrorHandler.instance;
    UserMsgHandler.instance;
  }
}
