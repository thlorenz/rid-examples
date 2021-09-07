part of 'posts_cubit.dart';

@immutable
class PostsState {
  final List<Post> posts;
  const PostsState(this.posts);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PostsState && other.posts == posts;

  @override
  int get hashCode => posts.hashCode;
}
