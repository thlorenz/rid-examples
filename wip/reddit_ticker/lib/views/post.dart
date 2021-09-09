import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plugin/generated/rid_api.dart';
import 'package:reddit_ticker/blocs/cubit/post_cubit.dart';

charts.Series<Score, double> toChartData(List<Score> scores) {
  return charts.Series<Score, double>(
    id: 'Scores',
    colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
    domainFn: (Score score, _) => score.postAddedSecsAgo / 60.0,
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
            child: ListTile(
              title: Center(
                child: Text(post.title,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                          decoration: TextDecoration.underline,
                          overflow: TextOverflow.ellipsis,
                        )),
              ),
              subtitle: SizedBox(height: 200, child: chart),
            ),
          ),
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
