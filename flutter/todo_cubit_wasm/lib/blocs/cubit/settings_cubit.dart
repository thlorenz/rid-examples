import 'package:bloc/bloc.dart';
import 'package:plugin/generated/rid_api.dart';

class SettingsCubit extends Cubit<Settings> {
  final Store _store = Store.instance;
  SettingsCubit() : super(Store.instance.settings);

  Future<void> setAutoExpireCompleted(bool val) async {
    await _store.msgSetAutoExpireCompletedTodos(val);
    emit(_store.settings);
  }
}
