part of 'post_cubit.dart';

@immutable
abstract class PostState {
  final String url;
  final String postId;

  PostState(this.postId, this.url);
}

@immutable
class PostActive extends PostState {
  final Post post;
  PostActive(this.post) : super(post.id, post.url);

  PostRemoved intoRemoved() => PostRemoved._fromPostActive(this);
}

@immutable
class PostRemoved extends PostState {
  final String postId;
  PostRemoved._(this.postId, String url) : super(postId, url);

  factory PostRemoved._fromPostActive(PostActive state) {
    final post = state.post;
    return PostRemoved._(post.id, post.url);
  }
}
