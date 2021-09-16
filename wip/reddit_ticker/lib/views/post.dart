import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plugin/generated/rid_api.dart';
import 'package:reddit_ticker/blocs/cubit/post_cubit.dart';
import 'package:reddit_ticker/blocs/cubit/post_launcher_cubit.dart';

charts.Series<Score, double> toChartData(List<Score> scores) {
  return charts.Series<Score, double>(
    id: 'Scores',
    colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
    domainFn: (Score score, _) => score.secsSincePostAdded / 60.0,
    measureFn: (Score score, _) => score.score,
    data: scores,
  );
}

class PostView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostCubit, PostState>(builder: (context, state) {
      if (state is PostActive) {
        final post = state.post;
        final chartData = toChartData(post.scores);
        final chart = charts.LineChart(
          [chartData],
          animate: true,
        );
        return Dismissible(
          key: Key("Post Dismissible ${state.post.id}"),
          child: Card(
            child: BlocListener<PostLauncherCubit, PostLauncherState>(
              listener: (context, state) {
                if (state is PostLauncherFailed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(state.errMsg),
                    ),
                  );
                }
              },
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
                  subtitle: SizedBox(height: 140, child: chart),
                ),
                onTap: () => context.read<PostLauncherCubit>().tryLaunch(),
              ),
            ),
          ),
          confirmDismiss: (_) => context.read<PostCubit>().stopWatching(),
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
