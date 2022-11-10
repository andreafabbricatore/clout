import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clout/components/chat.dart';
import 'package:clout/components/chatbubble.dart';
import 'package:clout/components/event.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/screens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatRoomScreen extends StatefulWidget {
  ChatRoomScreen({Key? key, required this.chatinfo, required this.curruser})
      : super(key: key);
  Chat chatinfo;
  AppUser curruser;
  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController _textmessage = TextEditingController();
  db_conn db = db_conn();
  late Stream<QuerySnapshot> chatmessages;
  String chatname = "";

  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> updatecurruser() async {
    try {
      AppUser updateduser = await db.getUserFromDocID(widget.curruser.docid);
      setState(() {
        widget.curruser = updateduser;
      });
    } catch (e) {
      displayErrorSnackBar("Could not refresh user");
    }
  }

  Future interactfav(Event event) async {
    try {
      if (widget.curruser.favorites.contains(event.docid)) {
        await db.remFromFav(widget.curruser.docid, event.docid);
      } else {
        await db.addToFav(widget.curruser.docid, event.docid);
      }
    } catch (e) {
      displayErrorSnackBar("Could not update favorites");
    } finally {
      updatecurruser();
    }
  }

  void setupnames() async {
    if (widget.chatinfo.type == "user") {
      List temp = widget.chatinfo.chatname;
      temp.removeWhere((element) => element == widget.curruser.username);
      chatname = temp[0];
    } else {
      chatname = widget.chatinfo.chatname[0];
    }
  }

  @override
  void initState() {
    super.initState();
    chatmessages = db.retrievemessages(widget.chatinfo.chatid);
    setupnames();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: GestureDetector(
          onTap: () async {
            if (widget.chatinfo.type == "user") {
              List temp = widget.chatinfo.connectedid;
              temp.removeWhere((element) => element == widget.curruser.docid);
              AppUser otheruser = await db.getUserFromDocID(temp[0]);
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (_) => ProfileScreen(
                            user: otheruser,
                            curruser: widget.curruser,
                            visit: true,
                          )));
            } else {
              Event chosenEvent =
                  await db.getEventfromDocId(widget.chatinfo.connectedid[0]);
              List<AppUser> participants = [
                for (String x in chosenEvent.participants)
                  await db.getUserFromDocID(x)
              ];

              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EventDetailScreen(
                            event: chosenEvent,
                            curruser: widget.curruser,
                            participants: participants,
                            interactfav: interactfav,
                          )));
            }
          },
          child: Text(
            chatname,
            textScaleFactor: 1.0,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
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
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Center(
          child: StreamBuilder<QuerySnapshot>(
              stream: chatmessages,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    "Error Loading Chat",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                    textScaleFactor: 1.0,
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SpinKitFadingFour(
                    color: Color.fromARGB(255, 255, 48, 117),
                  );
                }
                return ListView(
                  reverse: true,
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    if (widget.curruser.username == data['sender']) {
                      return Align(
                          alignment: Alignment.centerRight,
                          child: chatbubble(
                              data['sender'], data['content'], true));
                    } else if (data['sender'] == 'server') {
                      return Align(
                          alignment: Alignment.center,
                          child: Container(
                              color: Colors.white,
                              height: 100,
                              width: screenwidth,
                              child: Center(
                                  child: Text(
                                data['content'].toString().toUpperCase(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ))));
                    } else {
                      return Align(
                          alignment: Alignment.centerLeft,
                          child: chatbubble(
                              data['sender'], data['content'], false));
                    }
                  }).toList(),
                );
              })),
      bottomNavigationBar: Container(
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: MediaQuery.of(context).viewInsets,
          color: Colors.white,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              padding: EdgeInsets.symmetric(vertical: 2),
              margin: EdgeInsets.fromLTRB(15, 0, 15, 25),
              child: TextField(
                controller: _textmessage,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 5),
                    border: InputBorder.none,
                    hintText: 'Type a message',
                    suffixIcon: IconButton(
                      icon: Icon(
                        CupertinoIcons.arrow_right_square_fill,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        db.sendmessage(_textmessage.text.trim(),
                            widget.curruser.username, widget.chatinfo.chatid);
                        _textmessage.clear();
                      },
                    )),
              ))),
    );
  }
}
