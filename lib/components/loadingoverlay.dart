import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  LoadingOverlay({Key? key, required this.text}) : super(key: key);
  String text;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
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
