part of 'add_post_cubit.dart';

@immutable
abstract class AddPostState {}

@immutable
class AddPostInactive extends AddPostState {}

@immutable
class AddPostPending extends AddPostState {
  final String url;

  AddPostPending(this.url) : super();
}

@immutable
class AddPostSucceeded extends AddPostState {
  final Post post;

  AddPostSucceeded(this.post) : super();
}

@immutable
class AddPostFailed extends AddPostState {
  final String url;
  final String errorMessage;

  AddPostFailed(this.url, this.errorMessage) : super();
}
