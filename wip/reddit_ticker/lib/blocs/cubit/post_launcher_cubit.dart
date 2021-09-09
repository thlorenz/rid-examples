import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

part 'post_launcher_state.dart';

class PostLauncherCubit extends Cubit<PostLauncherState> {
  PostLauncherCubit(String url) : super(PostLauncherInitial(url));

  Future<void> tryLaunch() async {
    if (await canLaunch(state.postUrl)) {
      try {
        await launch(state.postUrl);
        emit(state.intoSucceeded());
      } catch (err, stack) {
        debugPrintStack(stackTrace: stack, label: err.toString());
        emit(state.intoFailed(err.toString()));
      }
    } else {
      emit(state.intoFailed('Cannot open:\n${state.postUrl}'));
    }
  }
}
