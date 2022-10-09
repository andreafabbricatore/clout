import 'package:clout/components/chat.dart';
import 'package:flutter/material.dart';

class ChatListView extends StatelessWidget {
  ChatListView(
      {Key? key,
      required this.chatlist,
      required this.screenwidth,
      required this.onTap})
      : super(key: key);
  List<Chat> chatlist;
  double screenwidth;
  final Function(Chat chat, int index)? onTap;

  Widget _listviewitem(
    Chat chat,
    int index,
  ) {
    Widget widget;
    widget = Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: SizedBox(
            height: 50,
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Image.network(
                chat.iconurl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(
          width: screenwidth * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${chat.chatname}",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "${chat.mostrecentmessage}",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
    return GestureDetector(
      onTap: () => onTap?.call(chat, index),
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 16, 0, 0),
          shrinkWrap: true,
          itemCount: chatlist.length,
          itemBuilder: (_, index) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                child: _listviewitem(chatlist[index], index));
          }),
    );
  }
}
