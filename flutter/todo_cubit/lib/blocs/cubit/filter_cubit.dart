import 'package:bloc/bloc.dart';
import 'package:plugin/generated/rid_api.dart';

class FilterCubit extends Cubit<Filter> {
  final Store _store = Store.instance;
  FilterCubit() : super(Store.instance.filter);

  Future<void> setFilter(Filter filter) async {
    await _store.msgSetFilter(filter);
    emit(_store.filter);
  }
}
