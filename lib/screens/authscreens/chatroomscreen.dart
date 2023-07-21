import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clout/defs/chat.dart';
import 'package:clout/components/chatbubble.dart';
import 'package:clout/defs/event.dart';
import 'package:clout/defs/location.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/screens/authscreens/eventdetailscreen.dart';
import 'package:clout/screens/authscreens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatRoomScreen extends StatefulWidget {
  ChatRoomScreen(
      {Key? key,
      required this.chatinfo,
      required this.curruser,
      required this.curruserlocation,
      required this.analytics})
      : super(key: key);
  Chat chatinfo;
  AppUser curruser;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController _textmessage = TextEditingController();
  db_conn db = db_conn();
  late Stream<QuerySnapshot> chatmessages;
  String chatname = "";
  applogic logic = applogic();

  Future<void> updatecurruser() async {
    try {
      AppUser updateduser = await db.getUserFromUID(widget.curruser.uid);
      setState(() {
        widget.curruser = updateduser;
      });
    } catch (e) {
      logic.displayErrorSnackBar("Could not refresh user", context);
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

  void gotoprofilescreen(AppUser otheruser) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (_) => ProfileScreen(
                  user: otheruser,
                  curruser: widget.curruser,
                  visit: true,
                  curruserlocation: widget.curruserlocation,
                  analytics: widget.analytics,
                ),
            settings: RouteSettings(name: "ProfileScreen")));
  }

  void gotoeventscreen(Event chosenEvent, List<AppUser> participants) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EventDetailScreen(
                  event: chosenEvent,
                  curruser: widget.curruser,
                  participants: participants,
                  curruserlocation: widget.curruserlocation,
                  analytics: widget.analytics,
                ),
            settings: const RouteSettings(name: "EventDetailScreen")));
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
              temp.removeWhere((element) => element == widget.curruser.uid);
              AppUser otheruser = await db.getUserFromUID(temp[0]);
              gotoprofilescreen(otheruser);
            } else {
              Event chosenEvent =
                  await db.getEventfromDocId(widget.chatinfo.connectedid[0]);
              List<AppUser> participants =
                  await db.geteventparticipantslist(chosenEvent);
              await Future.delayed(const Duration(milliseconds: 50));
              gotoeventscreen(chosenEvent, participants);
            }
          },
          child: Text(
            chatname,
            textScaleFactor: 1.0,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
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
      body: Center(child: messagestreamview(screenheight, screenwidth)),
      bottomNavigationBar: chatbox(context),
    );
  }

  Container chatbox(BuildContext context) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        padding: MediaQuery.of(context).viewInsets,
        color: Colors.white,
        child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(200, 238, 238, 238),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 2),
            margin: const EdgeInsets.fromLTRB(15, 0, 15, 25),
            child: TextField(
              controller: _textmessage,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  border: InputBorder.none,
                  hintText: 'Type a message',
                  suffixIcon: IconButton(
                    icon: const Icon(CupertinoIcons.arrow_right_square_fill,
                        color: Colors.black),
                    onPressed: () {
                      if (_textmessage.text.trim().isNotEmpty) {
                        db.sendmessage(
                            _textmessage.text.trim(),
                            widget.curruser,
                            widget.chatinfo.chatid,
                            chatname,
                            widget.chatinfo.type,
                            "text",
                            "",
                            "",
                            DateTime.now());
                        _textmessage.clear();
                      }
                    },
                  )),
            )));
  }

  StreamBuilder<QuerySnapshot<Object?>> messagestreamview(
      double screenheight, double screenwidth) {
    return StreamBuilder<QuerySnapshot>(
        stream: chatmessages,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
            return SpinKitFadingFour(
              color: Theme.of(context).primaryColor,
            );
          }
          return ListView(
            reverse: true,
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              db.setReadReceipt(widget.chatinfo.chatid, widget.curruser.uid);
              if (widget.curruser.username == data['sender']) {
                return Align(
                    alignment: Alignment.centerRight,
                    child: data['type'] == "event"
                        ? GestureDetector(
                            onTap: () async {
                              Event chosenEvent =
                                  await db.getEventfromDocId(data['content']);
                              List<AppUser> participants = await db
                                  .geteventparticipantslist(chosenEvent);
                              await Future.delayed(
                                  const Duration(milliseconds: 50));
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => EventDetailScreen(
                                            event: chosenEvent,
                                            curruser: widget.curruser,
                                            participants: participants,
                                            curruserlocation:
                                                widget.curruserlocation,
                                            analytics: widget.analytics,
                                          ),
                                      settings: RouteSettings(
                                          name: "EventDetailScreen")));
                            },
                            child: eventchatbubble(
                                data['sender'],
                                data['event_title'],
                                data['banner_url'],
                                data['date'].toDate(),
                                true,
                                screenheight,
                                screenwidth),
                          )
                        : chatbubble(data['sender'], data['content'], true));
              } else if (data['sender'] == 'server') {
                return Align(
                    alignment: Alignment.center,
                    child: Container(
                        color: Colors.white,
                        width: screenwidth * 0.8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                                child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 0.0),
                              child: Text(
                                data['content'].toString().toUpperCase(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                                textScaleFactor: 1.0,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            )),
                          ],
                        )));
              } else {
                return Align(
                    alignment: Alignment.centerLeft,
                    child: data['type'] == "event"
                        ? GestureDetector(
                            onTap: () async {
                              Event chosenEvent =
                                  await db.getEventfromDocId(data['content']);
                              List<AppUser> participants = await db
                                  .geteventparticipantslist(chosenEvent);
                              await Future.delayed(
                                  const Duration(milliseconds: 50));
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => EventDetailScreen(
                                            event: chosenEvent,
                                            curruser: widget.curruser,
                                            participants: participants,
                                            curruserlocation:
                                                widget.curruserlocation,
                                            analytics: widget.analytics,
                                          ),
                                      settings: RouteSettings(
                                          name: "EventDetailScreen")));
                            },
                            child: eventchatbubble(
                                data['sender'],
                                data['event_title'],
                                data['banner_url'],
                                data['date'].toDate(),
                                false,
                                screenheight,
                                screenwidth),
                          )
                        : chatbubble(data['sender'], data['content'], false));
              }
            }).toList(),
          );
        });
  }
}
