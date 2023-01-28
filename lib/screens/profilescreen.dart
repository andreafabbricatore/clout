import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/profiletopcontainer.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/cloutscorescreen.dart';
import 'package:clout/screens/editprofilescreen.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/screens/followerfollowingscreen.dart';
import 'package:clout/screens/settings.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';

import '../components/event.dart';

class ProfileScreen extends StatefulWidget {
  AppUser user;
  AppUser curruser;
  bool visit;
  bool iscurruser = false;
  ProfileScreen({
    super.key,
    required this.user,
    required this.curruser,
    required this.visit,
    iscurruser,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  db_conn db = db_conn();

  bool joinedevents = true;
  List<Event> joinedEvents = [];
  List<Event> hostedEvents = [];
  List<AppUser> globalrankedusers = [];

  void displayErrorSnackBar(
    String error,
  ) {
    final snackBar = SnackBar(
      content: Text(
        error,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color.fromARGB(230, 255, 48, 117),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: false,
      closeIconColor: Colors.white,
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> reportuser(AppUser user) async {
    try {
      await db.reportUser(user);
      displayErrorSnackBar("Reported @${user.username}");
    } catch (e) {
      displayErrorSnackBar("Could not report, please try again");
    }
  }

  Future<void> refresh() async {
    try {
      await updateuser();
      await updatecurruser();
      geteventlist(widget.user.joinedEvents, true);
      geteventlist(widget.user.hostedEvents, false);
    } catch (e) {
      displayErrorSnackBar("Could not refresh");
    }
  }

  Future<void> updateuser() async {
    try {
      AppUser updateduser = await db.getUserFromUID(widget.user.uid);
      setState(() {
        widget.user = updateduser;
      });
    } catch (e) {
      displayErrorSnackBar("Could not refresh user");
    }
  }

  Future<void> updatecurruser() async {
    try {
      AppUser updateduser = await db.getUserFromUID(widget.curruser.uid);
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
          joinedEvents = temp;
        });
      } else {
        setState(() {
          hostedEvents = temp;
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
                )));
    refresh();
  }

  void settings() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SetttingsScreen(
                  curruser: widget.curruser,
                )));
    refresh();
  }

  void followerscreen() async {
    await Navigator.push(
        context,
        CupertinoPageRoute(
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
        CupertinoPageRoute(
            builder: (_) => FollowerFollowingScreen(
                  user: widget.user,
                  curruser: widget.curruser,
                  iscurruser: widget.iscurruser,
                  onfollowers: false,
                )));
    refresh();
  }

  void cloutscreen() async {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (_) => CloutScoreScreen(
                  curruser: widget.curruser,
                )));
  }

  Future<void> follow() async {
    try {
      await db.follow(widget.curruser.uid, widget.user.uid);
      refresh();
    } catch (e) {
      displayErrorSnackBar("Could not follow @${widget.user.username}");
    }
  }

  Future<void> unfollow() async {
    try {
      await db.unFollow(widget.curruser.uid, widget.user.uid);
      refresh();
    } catch (e) {
      displayErrorSnackBar("Could not unfollow @${widget.user.username}");
    }
  }

  Future interactfav(Event event) async {
    try {
      if (widget.curruser.favorites.contains(event.docid)) {
        await db.remFromFav(widget.curruser.uid, event.docid);
      } else {
        await db.addToFav(widget.curruser.uid, event.docid);
      }
    } catch (e) {
      displayErrorSnackBar("Could not update favorites");
    } finally {
      updatecurruser();
    }
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.iscurruser = widget.user.uid == widget.curruser.uid;
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    Future<void> navigate(Event event, int index) async {
      try {
        List<AppUser> participants = [
          for (String x in event.participants) await db.getUserFromUID(x)
        ];

        await Navigator.push(
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

    AlertDialog alert = AlertDialog(
      title: const Text("Block Account"),
      content: const Text("Would you also like to block this account?"),
      actions: [
        TextButton(
          child: const Text("Block Account"),
          onPressed: () async {
            await db.blockUser(widget.curruser.uid, widget.user.uid);
            displayErrorSnackBar(
                "Blocked User! To unblock, please visit Settings.");
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: widget.visit
            ? GestureDetector(
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
              )
            : const SizedBox(
                width: 0,
                height: 0,
              ),
        centerTitle: true,
        title: Text(
          widget.user.username,
          textScaleFactor: 1.0,
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
                    settings();
                  },
                  child: const Padding(
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
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.black,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await reportuser(widget.user);
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });
                  },
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      Icons.flag_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
        shape: const Border(
            bottom: BorderSide(color: Color.fromARGB(55, 158, 158, 158))),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        color: const Color.fromARGB(255, 255, 48, 117),
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenheight,
            width: screenwidth,
            child: Column(children: [
              ProfileTopContainer(
                user: widget.user,
                iscurruser: widget.iscurruser,
                curruser: widget.curruser,
                editprofile: editprofile,
                followerscreen: followerscreen,
                followingscreen: followingscreen,
                cloutscreen: cloutscreen,
                follow: widget.curruser.following.contains(widget.user.uid)
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
                      height: screenheight * 0.045,
                      width: screenwidth * 0.5,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: joinedevents
                                      ? Colors.black
                                      : const Color.fromARGB(
                                          55, 158, 158, 158)),
                              right: const BorderSide(
                                  color: Color.fromARGB(55, 158, 158, 158)))),
                      child: Center(
                          child: Text(
                        "Joined Events",
                        style: TextStyle(
                            fontWeight: joinedevents
                                ? FontWeight.bold
                                : FontWeight.normal),
                      )),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        joinedevents = false;
                      });
                    },
                    child: Container(
                      height: screenheight * 0.045,
                      width: screenwidth * 0.5,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: joinedevents
                                      ? const Color.fromARGB(55, 158, 158, 158)
                                      : Colors.black),
                              left: const BorderSide(color: Colors.white))),
                      child: Center(
                          child: Text(
                        "Hosted Events",
                        style: TextStyle(
                            fontWeight: joinedevents
                                ? FontWeight.normal
                                : FontWeight.bold),
                      )),
                    ),
                  )
                ],
              ),
              EventListView(
                eventList: joinedevents ? joinedEvents : hostedEvents,
                isHorizontal: false,
                onTap: navigate,
                scrollable: false,
                leftpadding: true,
                curruser: widget.curruser,
                interactfav: interactfav,
                screenheight: screenheight,
                screenwidth: screenwidth,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
