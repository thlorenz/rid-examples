import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reddit_ticker/blocs/cubit/post_cubit.dart';

class PostView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(builder: (context, state) {
      if (state is PostActive) {
        return Dismissible(
          key: Key("Post Dismissible ${state.post.id}"),
          child: Card(
            child: Column(
              children: [
                Text('${state.post.title}'),
                Text('${state.post.scores.map((x) => x.score).join(', ')}'),
              ],
            ),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) =>
              context.read<PostCubit>().removePost().then((_) => true),
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
