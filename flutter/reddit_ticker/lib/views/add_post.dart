import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reddit_ticker/cubit/add_post_cubit.dart';

class AddPostView extends StatefulWidget {
  @override
  State<AddPostView> createState() => _AddPostViewState();
}

class _AddPostViewState extends State<AddPostView> {
  final _textFieldController = TextEditingController();
  String? addPostURL;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        _textFieldController.clear();
        await _addPostDialog(context);

        final url = addPostURL;
        if (url != null && url.trim().isNotEmpty) {
          context.read<AddPostCubit>().addPost(url);
        }
      },
      tooltip: 'Add URL of Post to Watch',
      child: BlocListener<AddPostCubit, AddPostState>(
        listener: (context, state) {
          if (state is AddPostFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('Failed to add Post'),
              ),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addPostDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Post URL'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(
                hintText:
                    "https://www.reddit.com/r/rust/comments/ncc9vc/rid_integrate_rust_into_your_dart_or_flutter_app/",
              ),
              autofocus: true,
              onSubmitted: (_) => _onSubmitted(),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Done'),
                onPressed: _onSubmitted,
              ),
            ],
          );
        });
  }

  void _onSubmitted() {
    addPostURL = _textFieldController.value.text;
    Navigator.pop(context);
  }
}
