import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'package:plugin/generated/rid_api.dart';

import 'package:reddit_ticker/cubit/add_post_cubit.dart';
import 'package:reddit_ticker/cubit/posts_cubit.dart';
import 'package:reddit_ticker/rid/messaging.dart';
import 'package:reddit_ticker/views/add_post.dart';
import 'package:reddit_ticker/views/posts.dart';

void main() async {
  // Register handlers for log messages as well as errors coming from Rust
  RidMessaging.init();

  // Don't clutter console with Store lock messages
  rid.debugLock = null;

  // Connect the Database and kick off the thread that is polling post scores
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationSupportDirectory();
  await Store.instance.msgInitialize(appDir.path);

  runApp(RedditTickerApp());
}

class RedditTickerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reddit Ticker',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<PostsCubit>(create: (_) => PostsCubit()),
          BlocProvider<AddPostCubit>(create: (_) => AddPostCubit()),
        ],
        child: RedditTickerPage(title: 'Reddit Ticker'),
      ),
    );
  }
}

class RedditTickerPage extends StatefulWidget {
  final String title;
  RedditTickerPage({Key? key, required this.title}) : super(key: key);

  @override
  _RedditTickerPageState createState() => _RedditTickerPageState();
}

class _RedditTickerPageState extends State<RedditTickerPage> {
  @override
  void initState() {
    super.initState();

    // Provide our BuildContext to the Rust error handler so it can a snackbar and material banner
    ErrorHandler.instance.context = context;
  }

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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AddPostView(),
      ),
    );
  }
}
