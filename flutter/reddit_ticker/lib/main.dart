import 'package:flutter/material.dart';
import 'package:plugin/generated/rid_api.dart';

void main() {
  rid.messageChannel.stream.listen((msg) => debugPrint("rid-msg: $msg"));
  debugPrint(rid_ffi.rid_export_hello_world(1).toDartString());
}
