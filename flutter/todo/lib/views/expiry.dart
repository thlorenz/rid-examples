import 'package:flutter/material.dart';

Color expiryColor(double completedExpiryMillis, double remaining) {
  return remaining > completedExpiryMillis * 0.80
      ? Colors.greenAccent
      : remaining > completedExpiryMillis * 0.60
          ? Colors.green
          : remaining > completedExpiryMillis * 0.4
              ? Colors.orange
              : remaining > completedExpiryMillis * 0.2
                  ? Colors.redAccent
                  : Colors.red;
}

class ExpiryWidget extends StatelessWidget {
  final double completedExpiryMillis;
  final double remainingMillis;

  const ExpiryWidget({
    required this.completedExpiryMillis,
    required this.remainingMillis,
  }) : super();

  Widget build(BuildContext context) {
    final totalWidth = MediaQuery.of(context).size.width * 0.8;
    final expiryWidth = (remainingMillis / completedExpiryMillis) * totalWidth;
    return Container(
      height: 10,
      width: totalWidth,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: 1.0,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.all(Radius.circular(2.0)),
      ),
      child: Container(
        margin: EdgeInsets.only(right: totalWidth - expiryWidth),
        color: expiryColor(completedExpiryMillis, remainingMillis),
      ),
    );
  }
}
