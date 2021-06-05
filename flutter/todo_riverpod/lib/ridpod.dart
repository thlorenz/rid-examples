import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin/plugin.dart';

abstract class RidConsumerWidget extends ConsumerWidget {
  const RidConsumerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final widget = buildLocked(context, watch);
    rid_ffi.rid_store_lock();
    rid_ffi.rid_store_unlock();
    return widget;
  }

  Widget buildLocked(BuildContext context, ScopedReader watch);
}
