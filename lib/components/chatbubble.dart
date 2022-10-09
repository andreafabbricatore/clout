import 'package:flutter/material.dart';

Widget chatbubble(String sender, String content, bool curruser) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
    child: Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      constraints: const BoxConstraints(maxWidth: 250),
      decoration: BoxDecoration(
          color: curruser
              ? const Color.fromARGB(255, 238, 238, 238)
              : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.all(color: const Color.fromARGB(255, 238, 238, 238))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        child: curruser
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  sender,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.left,
                ),
              ]),
      ),
    ),
  );
}
