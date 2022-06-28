import 'package:flutter/material.dart';

Widget datetextfield(double screenwidth, String hinttext,
    TextEditingController controller, formatter) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: screenwidth * 0.2),
    child: TextField(
      decoration: InputDecoration(
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 255, 48, 117))),
          hintText: hinttext,
          hintStyle: const TextStyle(color: Color.fromARGB(39, 0, 0, 0))),
      textAlign: TextAlign.start,
      enableSuggestions: false,
      autocorrect: false,
      controller: controller,
      inputFormatters: [formatter],
    ),
  );
}
