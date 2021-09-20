part of 'post_cubit.dart';

@immutable
abstract class PostState {
  final String postId;
  final String url;

  PostState(this.postId, this.url);
}

@immutable
class PostActive extends PostState {
  final Post post;

  PostActive(this.post) : super(post.id, post.url);
}
