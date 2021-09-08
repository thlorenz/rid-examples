import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:plugin/generated/rid_api.dart';

part 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  final _store = Store.instance;
  PostsCubit() : super(PostsState(Store.instance.posts.values.toList()));

  void refresh() {
    emit(PostsState(_store.posts.values.toList()));
  }
}
