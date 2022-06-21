import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/profiletopcontainer.dart';
import 'package:clout/components/user.dart';
import 'package:clout/main.dart';
import 'package:clout/screens/editprofilescreen.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/screens/loading.dart';
import 'package:clout/services/auth.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/event.dart';

class ProfileScreen extends StatefulWidget {
  AppUser user;
  AppUser curruser;
  bool visit;
  bool iscurruser = false;
  List interestpics;
  List interests;
  ProfileScreen({
    super.key,
    required this.user,
    required this.curruser,
    required this.visit,
    required this.interestpics,
    required this.interests,
    iscurruser,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  db_conn db = db_conn();

  bool joinedevents = true;
  List<Event> joined_events = [];
  List<Event> hosted_events = [];
  String userdocid = "";
  String curruserdocid = "";

  Future<void> refresh() async {
    try {
      updateuser();
      updatecurruser();
      geteventlist(widget.user.joined_events, true);
      geteventlist(widget.user.hosted_events, false);
    } catch (e) {
      print("error");
    }
  }

  Future<void> updateuser() async {
    AppUser updateduser = await db.getUserFromDocID(userdocid);
    setState(() {
      widget.user = updateduser;
    });
  }

  Future<void> updatecurruser() async {
    AppUser updateduser = await db.getUserFromDocID(curruserdocid);
    setState(() {
      widget.curruser = updateduser;
    });
  }

  Future<void> geteventlist(List events, bool joined) async {
    List<Event> temp = [];
    for (int i = 0; i < events.length; i++) {
      Event event = await db.getEventfromDocId(events[i]);
      temp.add(event);
    }
    if (joined) {
      setState(() {
        joined_events = temp;
      });
    } else {
      setState(() {
        hosted_events = temp;
      });
    }
  }

  Future<void> getuserid(String uid) async {
    String id = await db.getUserDocID(widget.user.uid);
    setState(() {
      userdocid = id;
    });
  }

  Future<void> getcurruserid(String uid) async {
    String id = await db.getUserDocID(widget.curruser.uid);
    setState(() {
      curruserdocid = id;
    });
  }

  void editprofile() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EditProfileScreen(
                  curruser: widget.curruser,
                  interestpics: widget.interestpics,
                  interests: widget.interests,
                )));
    refresh();
  }

  Future<void> follow() async {
    try {
      await db.Follow(curruserdocid, userdocid);
      refresh();
    } catch (e) {
      print("error");
    }
  }

  Future<void> unfollow() async {
    try {
      await db.unFollow(curruserdocid, userdocid);
      refresh();
    } catch (e) {
      print("error");
    }
  }

  Future<void> init() async {
    await getuserid(widget.user.uid);
    await getcurruserid(widget.curruser.uid);
    updateuser();
    updatecurruser();
    geteventlist(widget.user.joined_events, true);
    geteventlist(widget.user.hosted_events, false);
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.iscurruser = widget.user.uid == widget.curruser.uid;
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    Future<void> _navigate(Event event, int index) async {
      List pfpurls = [
        for (String x in event.participants) await db.getUserPFPfromUsername(x)
      ];
      Event newevent = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(
                    event: event,
                    pfp_urls: pfpurls,
                    userdocid: curruserdocid,
                    curruser: widget.curruser,
                  )));
      refresh();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: widget.visit
            ? GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Color.fromARGB(255, 255, 48, 117),
                  ),
                ),
              )
            : SizedBox(
                width: 0,
                height: 0,
              ),
        centerTitle: true,
        title: Text(
          widget.user.username,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: widget.iscurruser ? 30 : 20),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: widget.visit ? true : false,
        actions: widget.iscurruser
            ? [
                InkWell(
                  onTap: () {
                    refresh();
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.black,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      Icons.settings,
                      color: Colors.black,
                    ),
                  ),
                ),
              ]
            : [
                InkWell(
                  onTap: () {
                    refresh();
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
        shape: Border(
            bottom: BorderSide(color: Color.fromARGB(55, 158, 158, 158))),
      ),
      body: Column(children: [
        ProfileTopContainer(
          user: widget.user,
          iscurruser: widget.iscurruser,
          curruser: widget.curruser,
          curruserdocid: curruserdocid,
          userdocid: userdocid,
          editprofile: editprofile,
          follow:
              widget.curruser.following.contains(userdocid) ? unfollow : follow,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  joinedevents = true;
                });
              },
              child: Container(
                child: Center(
                    child: Text(
                  "Joined Events",
                  style: TextStyle(
                      fontWeight:
                          joinedevents ? FontWeight.bold : FontWeight.normal),
                )),
                height: screenheight * 0.045,
                width: screenwidth * 0.5,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: joinedevents
                                ? Colors.black
                                : Color.fromARGB(55, 158, 158, 158)),
                        right: BorderSide(
                            color: Color.fromARGB(55, 158, 158, 158)))),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  joinedevents = false;
                });
              },
              child: Container(
                child: Center(
                    child: Text(
                  "Hosted Events",
                  style: TextStyle(
                      fontWeight:
                          joinedevents ? FontWeight.normal : FontWeight.bold),
                )),
                height: screenheight * 0.045,
                width: screenwidth * 0.5,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: joinedevents
                                ? Color.fromARGB(55, 158, 158, 158)
                                : Colors.black),
                        left: BorderSide(color: Colors.white))),
              ),
            )
          ],
        ),
        EventListView(
          eventList: joinedevents ? joined_events : hosted_events,
          isHorizontal: false,
          onTap: _navigate,
          scrollable: true,
          leftpadding: true,
        ),
      ]),
    );
  }
}
