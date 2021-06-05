import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin/plugin.dart';

mixin ConsumerLock on ConsumerWidget {
  @override
  StatefulElement createElement() => RidStatefulElement(this);
}

class RidConsumer extends ConsumerWidget {
  const RidConsumer({
    Key? key,
    required ConsumerBuilder builder,
    Widget? child,
  })  : _child = child,
        _builder = builder,
        super(key: key);

  final ConsumerBuilder _builder;
  final Widget? _child;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    try {
      rid_ffi.rid_store_lock();
      return _builder(context, watch, _child);
    } finally {
      rid_ffi.rid_store_unlock();
    }
  }
}
