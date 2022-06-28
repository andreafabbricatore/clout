import 'package:flutter/material.dart';

Widget createeventtextfield(
    double screenwidth,
    String hinttext,
    TextEditingController controller,
    TextAlign alignment,
    TextStyle hintstyle,
    TextStyle inputstyle) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: screenwidth * 0.2),
    child: TextField(
      style: hintstyle,
      decoration: InputDecoration(
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 48, 117))),
          hintText: hinttext,
          hintStyle: inputstyle),
      textAlign: alignment,
      enableSuggestions: false,
      autocorrect: false,
      controller: controller,
    ),
  );
}
