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

  PostRemoved intoRemoved() => PostRemoved.fromPostActive(this);
}

@immutable
class PostRemoved extends PostState {
  final String postId;

  PostRemoved(this.postId, String url) : super(postId, url);

  factory PostRemoved.fromPostActive(PostActive state) {
    final post = state.post;
    return PostRemoved(post.id, post.url);
  }
}
