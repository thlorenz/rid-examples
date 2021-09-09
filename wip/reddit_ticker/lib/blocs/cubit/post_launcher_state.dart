part of 'post_launcher_cubit.dart';

@immutable
abstract class PostLauncherState {
  final String postUrl;
  PostLauncherState(this.postUrl);

  PostLauncherFailed intoFailed(errMsg) =>
      PostLauncherFailed.from(this, errMsg);

  PostLauncherSucceeded intoSucceeded() => PostLauncherSucceeded.from(this);
}

@immutable
class PostLauncherInitial extends PostLauncherState {
  PostLauncherInitial(String postUrl) : super(postUrl);
}

@immutable
class PostLauncherFailed extends PostLauncherState {
  final String errMsg;
  PostLauncherFailed(String postUrl, this.errMsg) : super(postUrl);

  factory PostLauncherFailed.from(PostLauncherState state, String errMsg) =>
      PostLauncherFailed(state.postUrl, errMsg);
}

@immutable
class PostLauncherSucceeded extends PostLauncherState {
  PostLauncherSucceeded(String postUrl) : super(postUrl);

  factory PostLauncherSucceeded.from(PostLauncherState state) =>
      PostLauncherSucceeded(state.postUrl);
}
