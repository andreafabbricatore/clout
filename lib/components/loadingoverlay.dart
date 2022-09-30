import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  LoadingOverlay({Key? key, required this.text, required this.color})
      : super(key: key);
  String text;
  Color color;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 50,
              fontFamily: "Kristi",
              fontWeight: FontWeight.w500,
            ),
            textScaleFactor: 1.0,
          ),
        ),
      ),
    );
  }
}
