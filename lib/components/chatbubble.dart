import 'package:flutter/material.dart';
import 'package:dart_emoji/dart_emoji.dart' as dart_emoji;
import 'package:flutter_emoji/flutter_emoji.dart' as flutter_emoji;

Widget chatbubble(String sender, String content, bool curruser) {
  flutter_emoji.EmojiParser parser = flutter_emoji.EmojiParser();
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
            ? dart_emoji.EmojiUtil.hasOnlyEmojis(content) &&
                    parser.count(content) <= 2
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 60,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  )
                : Column(
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
            : dart_emoji.EmojiUtil.hasOnlyEmojis(content)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                          sender,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          content,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
