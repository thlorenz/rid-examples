import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:plugin/generated/rid_api.dart';

import 'package:reddit_ticker/blocs/cubit/add_post_cubit.dart';
import 'package:reddit_ticker/blocs/cubit/posts_cubit.dart';
import 'package:reddit_ticker/views/add_post.dart';
import 'package:reddit_ticker/views/posts.dart';

final REQ_TIMEOUT = const Duration(seconds: 10);
const URL =
    'https://www.reddit.com/r/FlutterDev/comments/pk9uzs/magic_url_authentication_with_flutter_and_not/';

void main(List<String> args) async {
  final store = Store.instance;
  await store.msgInitializeTicker();
  runApp(RedditTickerApp());
}

class RedditTickerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reddit Ticker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AddPostCubit>(create: (_) => AddPostCubit()),
          BlocProvider<PostsCubit>(create: (_) => PostsCubit()),
        ],
        child: RedditTickerPage(title: 'Reddit Ticker'),
      ),
    );
  }
}

class RedditTickerPage extends StatefulWidget {
  RedditTickerPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _RedditTickerPageState createState() => _RedditTickerPageState();
}

class _RedditTickerPageState extends State<RedditTickerPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title),
              Row(
                children: [
                  Image.asset(
                    "assets/dash.png",
                    height: 40.0,
                    width: 40.0,
                  ),
                  Icon(Icons.favorite, color: Colors.red),
                  Image.asset(
                    "assets/ferris.png",
                    height: 50.0,
                    width: 50.0,
                  ),
                ],
              )
            ],
          ),
        ),
        body: PostsView(),
        floatingActionButton: AddPostView(),
      ),
    );
  }
}
