import 'package:flutter/material.dart';
import 'package:plugin/generated/rid_api.dart';

void main() {
  debugPrint(rid_ffi.rid_export_hello_world().toDartString());
}
