
import 'dart:async';

import 'package:flutter/services.dart';

class Plugin {
  static const MethodChannel _channel = MethodChannel('plugin');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
