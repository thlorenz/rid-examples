import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reddit_ticker/cubit/post_cubit.dart';

class PostView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(builder: (context, state) {
      if (state is PostActive) {
        final post = state.post;
        return Dismissible(
          key: Key("Post Dismissible ${state.post.id}"),
          child: Card(
            child: InkWell(
              child: ListTile(
                title: Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      post.title,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            decoration: TextDecoration.underline,
                            overflow: TextOverflow.ellipsis,
                            color: Colors.blue,
                          ),
                    ),
                  ),
                ),
                subtitle: SizedBox(
                  height: 140,
                  child: Text('TODO Scores Chart'),
                ),
                onTap: () => {/* TODO: launch post url */},
              ),
            ),
          ),
          background: Padding(
            padding: EdgeInsets.all(5.0),
            child: Container(color: Colors.red),
          ),
        );
      } else {
        return Card(child: Text('Post removed'));
      }
    });
  }
}