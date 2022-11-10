import 'package:clout/components/chat.dart';
import 'package:clout/components/chatlistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/chatroomscreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  ChatListScreen({super.key, required this.curruser});
  AppUser curruser;
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Chat> chatlist = [];
  db_conn db = db_conn();
  TextEditingController searchcontroller = TextEditingController();

  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> getchatlist() async {
    List<Chat> chats = [];
    try {
      for (int i = 0; i < widget.curruser.chats.length; i++) {
        Chat temp = await db.getChatfromDocId(widget.curruser.chats[i]);
        chats.add(temp);
      }
      setState(() {
        chatlist = chats;
      });
    } catch (e) {
      displayErrorSnackBar("Could not retrieve chats");
    }
  }

  void setup() async {
    await getchatlist();
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> chatnavigate(Chat chat, int index) async {
      await Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => ChatRoomScreen(
                    chatinfo: chat,
                    curruser: widget.curruser,
                  )));
      getchatlist();
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: GestureDetector(
            onTap: () async {
              await db.createuserchat(widget.curruser, "Swds3X740Fju18nULnep");
            },
            child: Text(
              widget.curruser.username,
              textScaleFactor: 1.0,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          elevation: 0.0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_back_ios,
                color: Color.fromARGB(255, 255, 48, 117),
              ),
            ),
          ),
        ),
        body: Column(children: [
          Center(
            child: SizedBox(
              width: screenwidth * 0.9,
              child: TextField(
                controller: searchcontroller,
                onChanged: (String searchquery) async {},
                decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                    )),
              ),
            ),
          ),
          chatlist.isNotEmpty
              ? ChatListView(
                  chatlist: chatlist,
                  screenwidth: screenwidth,
                  onTap: chatnavigate,
                  curruser: widget.curruser,
                )
              : SizedBox(
                  width: screenwidth,
                  height: screenheight * 0.7,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: screenheight * 0.1,
                      ),
                      const Text(
                        "No Chats yet :(",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                        textScaleFactor: 1.0,
                      ),
                      SizedBox(
                        height: screenheight * 0.03,
                      ),
                    ],
                  ),
                ),
        ]));
  }
}
