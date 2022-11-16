import 'package:clout/components/chat.dart';
import 'package:clout/components/user.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';

class ChatListView extends StatelessWidget {
  ChatListView(
      {Key? key,
      required this.chatlist,
      required this.screenwidth,
      required this.onTap,
      required this.curruser})
      : super(key: key);
  List<Chat> chatlist;
  double screenwidth;
  final Function(Chat chat, int index)? onTap;
  AppUser curruser;

  db_conn db = db_conn();

  Widget _listviewitem(
    Chat chat,
    int index,
  ) {
    String chatname = "";
    String iconurl = "";
    Widget widget;
    List temp1 = chat.chatname;
    List temp2 = chat.iconurl;
    if (chat.type == "user") {
      temp1.removeWhere((element) => element == curruser.username);
      chatname = temp1[0];
      temp2.removeWhere((element) => element == curruser.pfpurl);
      iconurl = temp2[0];
    } else {
      chatname = temp1[0];
      iconurl = temp2[0];
    }
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
                iconurl,
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
                chatname,
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
                child: Dismissible(
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    direction: chatlist[index].type == "user"
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    key: Key(chatlist[index].chatid),
                    onDismissed: chatlist[index].type == "user"
                        ? (direction) async {
                            await db.deletechat(chatlist[index].chatid);
                          }
                        : (direction) {},
                    child: _listviewitem(chatlist[index], index)));
          }),
    );
  }
}
