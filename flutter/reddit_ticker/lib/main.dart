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
  RidMessaging.init();

  rid.debugLock = null;

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
    ErrorHandler.instance.context = context;
    UserMsgHandler.instance.context = context;
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
