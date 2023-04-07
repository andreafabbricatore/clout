import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  LoadingWidget(
      {super.key,
      required this.screenheight,
      required this.screenwidth,
      required this.child,
      required this.controller});

  final double screenheight;
  final double screenwidth;
  Widget child;
  IndicatorController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).primaryColor,
          height: controller.value * screenheight * 0.08,
          width: screenwidth,
        ),
        child
      ],
    );
  }
}
