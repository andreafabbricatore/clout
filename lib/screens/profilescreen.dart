import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/profiletopcontainer.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/editprofilescreen.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/screens/followerfollowingscreen.dart';
import 'package:clout/screens/settings.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';

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

  void displayErrorSnackBar(String error) async {
    final snackBar = SnackBar(
      content: Text(error),
      duration: Duration(seconds: 2),
    );
    await Future.delayed(Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> refresh() async {
    try {
      updateuser();
      updatecurruser();
      geteventlist(widget.user.joined_events, true);
      geteventlist(widget.user.hosted_events, false);
    } catch (e) {
      displayErrorSnackBar("Could not refresh");
    }
  }

  Future<void> updateuser() async {
    try {
      AppUser updateduser = await db.getUserFromDocID(widget.user.docid);
      setState(() {
        widget.user = updateduser;
      });
    } catch (e) {
      displayErrorSnackBar("Could not refresh user");
    }
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

  Future<void> geteventlist(List events, bool joined) async {
    List<Event> temp = [];
    try {
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
    } catch (e) {
      displayErrorSnackBar("Could not retrieve events");
    }
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

  void settings() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => SetttingsScreen()));
    refresh();
  }

  void followerscreen() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => FollowerFollowingScreen(
                  user: widget.user,
                  curruser: widget.curruser,
                  iscurruser: widget.iscurruser,
                  onfollowers: true,
                )));
    refresh();
  }

  void followingscreen() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => FollowerFollowingScreen(
                  user: widget.user,
                  curruser: widget.curruser,
                  iscurruser: widget.iscurruser,
                  onfollowers: false,
                )));
    refresh();
  }

  Future<void> follow() async {
    try {
      await db.Follow(widget.curruser.docid, widget.user.docid);
      refresh();
    } catch (e) {
      displayErrorSnackBar("Could not follow @${widget.user.username}");
    }
  }

  Future<void> unfollow() async {
    try {
      await db.unFollow(widget.curruser.docid, widget.user.docid);
      refresh();
    } catch (e) {
      displayErrorSnackBar("Could not unfollow @${widget.user.username}");
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

  Future<void> init() async {
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
      try {
        List<AppUser> participants = [
          for (String x in event.participants) await db.getUserFromDocID(x)
        ];

        Event newevent = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EventDetailScreen(
                      event: event,
                      curruser: widget.curruser,
                      participants: participants,
                      interactfav: interactfav,
                    )));
      } catch (e) {
        displayErrorSnackBar("Could not display event");
      }
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
                  onTap: () {
                    settings();
                  },
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
          editprofile: editprofile,
          followerscreen: followerscreen,
          followingscreen: followingscreen,
          follow: widget.curruser.following.contains(widget.user.docid)
              ? unfollow
              : follow,
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
          curruser: widget.curruser,
          interactfav: interactfav,
        ),
      ]),
    );
  }
}
