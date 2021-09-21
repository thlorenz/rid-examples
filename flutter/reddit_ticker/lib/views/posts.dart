import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reddit_ticker/cubit/post_cubit.dart';
import 'package:reddit_ticker/cubit/posts_cubit.dart';
import 'package:reddit_ticker/views/post.dart';

class PostsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<PostsCubit, PostsState>(builder: (context, state) {
        final posts = state.posts;
        return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return MultiBlocProvider(
                providers: [
                  BlocProvider<PostCubit>(create: (_) => PostCubit(post)),
                ],
                child: PostView(),
                key: Key(post.hashCode.toString()),
              );
            });
      }),
    );
  }
}
