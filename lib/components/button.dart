import 'package:clout/screens/signinscreen.dart';
import 'package:flutter/material.dart';

Widget primaryButton(context, double screenwidth, String text) {
  Color buttoncolor = Color.fromARGB(255, 255, 48, 117);
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    },
    child: SizedBox(
        height: 50,
        width: screenwidth * 0.5,
        child: Container(
          child: Center(
              child: Text(
            text,
            style: TextStyle(fontSize: 20, color: Colors.white),
          )),
          decoration: BoxDecoration(
              color: buttoncolor,
              borderRadius: BorderRadius.all(Radius.circular(20))),
        )),
  );
}
