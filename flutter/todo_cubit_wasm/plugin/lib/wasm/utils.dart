import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:universal_io/io.dart';

String HTTP_ROOT = window.location.href.replaceFirst(RegExp('#/\$'), '');
Future<Uint8List> loadWasmFromNetwork(String wasmFile) async {
  final path = '$HTTP_ROOT/$wasmFile';
  try {
    // http-server --cors
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(path));
    if (request is BrowserHttpClientRequest) {
      request.browserResponseType = 'arraybuffer';
    }
    final response = await request.close();
    final list = await response.toList().then((List<List<int>> lists) {
      return lists.fold<List<int>>(<int>[], (List<int> acc, List<int> list) {
        acc.addAll(list);
        return acc;
      });
    });
    return Uint8List.fromList(list);
  } catch (e) {
    print(e);
    print("Couldn't open $path");
    return Uint8List.fromList([]);
  }
}

// This is currently not working for web apps
// It may be useful once we support Wasm for non-web apps
Future<Uint8List> loadWasmAsset(String wasmAsset) async {
  return rootBundle.load(wasmAsset).then((bytes) => bytes.buffer.asUint8List());
}
