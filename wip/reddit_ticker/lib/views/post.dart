import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plugin/generated/rid_api.dart';
import 'package:reddit_ticker/blocs/cubit/post_cubit.dart';
import 'package:intl/intl.dart';

charts.Series<Score, double> toChartData(List<Score> scores) {
  return charts.Series<Score, double>(
    id: 'Scores',
    colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
    domainFn: (Score score, _) => score.postAddedSecsAgo / 60.0,
    measureFn: (Score score, _) => score.score,
    data: scores,
  );
}

final simpleCurrencyFormatter =
    new charts.BasicNumericTickFormatterSpec.fromNumberFormat(
        NumberFormat.compact());

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
          domainAxis: new charts.NumericAxisSpec(
              tickFormatterSpec: simpleCurrencyFormatter),
        );
        return ListTile(
          title: Text(post.title),
          subtitle: SizedBox(height: 200, child: chart),
        );
      } else {
        return Card(child: Text('Post removed'));
      }
    });
  }
}

/*
Dismissible(
          key: Key("Post Dismissible ${state.post.id}"),
          child: Card(
            child: Column(
              children: [
                Text('${state.post.title}'),
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
        )
        */
