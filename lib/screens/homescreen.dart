import 'dart:async';
import 'dart:ui';

import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/noeventsbox.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/chatlistscreen.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/screens/notificationscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  bool justloaded;
  AppUser curruser;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  HomeScreen(
      {Key? key,
      required this.justloaded,
      required this.curruser,
      required this.curruserlocation,
      required this.analytics})
      : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  db_conn db = db_conn();
  List<Event> generaleventlist = [];
  List<Event> interesteventlist = [];
  List<Event> totaleventlist = [];
  final double _offsetToArmed = 200;

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

  @override
  void dispose() {
    super.dispose();
  }

  void getEventsList(interests) async {
    try {
      List<Event> events = await db.getEvents(interests);
      setState(() {
        generaleventlist = events;
      });
    } catch (e) {
      displayErrorSnackBar("Could not retrieve events");
    }
  }

  void getSortedCurrLocEventsList() async {
    try {
      interesteventlist = [];
      generaleventlist = [];
      List<Event> currloceventlist = [];
      currloceventlist = await db.getLngLatEvents(
          widget.curruserlocation.center[0],
          widget.curruserlocation.center[1],
          widget.curruserlocation.country,
          widget.curruser);
      for (int i = 0; i < currloceventlist.length; i++) {
        if (widget.curruser.interests.contains(currloceventlist[i].interest)) {
          if (widget.curruser.following
              .contains(currloceventlist[i].hostdocid)) {
            interesteventlist.insert(0, currloceventlist[i]);
          } else {
            interesteventlist.add(currloceventlist[i]);
          }
        } else {
          if (widget.curruser.following
              .contains(currloceventlist[i].hostdocid)) {
            interesteventlist.insert(0, currloceventlist[i]);
          } else {
            generaleventlist.add(currloceventlist[i]);
          }
        }
      }
      setState(() {
        totaleventlist = interesteventlist + generaleventlist;
      });
    } catch (e) {
      displayErrorSnackBar("Could not get events around you");
    }
  }

  Future<void> refreshevents() async {
    try {
      //List<Event> events = await db.getEvents(userinterests);
      //List<Event> interestevents = await db.getInterestEvents(userinterests);
      //setState(() {
      //  generaleventlist = events;
      //  interesteventlist = interestevents;
      //});
      getSortedCurrLocEventsList();
    } catch (e) {
      displayErrorSnackBar("Could not refresh events");
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

  Future interactfav(Event event) async {
    try {
      if (widget.curruser.favorites.contains(event.docid)) {
        await db.remFromFav(widget.curruser.uid, event.docid);
        await widget.analytics.logEvent(name: "rem_from_fav", parameters: {
          "interest": event.interest,
          "inviteonly": event.isinviteonly.toString(),
          "maxparticipants": event.maxparticipants,
          "currentparticipants": event.participants.length
        });
      } else {
        await db.addToFav(widget.curruser.uid, event.docid);
        await widget.analytics.logEvent(name: "add_to_fav", parameters: {
          "interest": event.interest,
          "inviteonly": event.isinviteonly.toString(),
          "maxparticipants": event.maxparticipants,
          "currentparticipants": event.participants.length
        });
      }
    } catch (e) {
      displayErrorSnackBar("Could not update favorites");
    } finally {
      updatecurruser();
    }
  }

  Future<void> refresh() async {
    try {
      await updatecurruser();
      await refreshevents();
    } catch (e) {
      displayErrorSnackBar("Could not refresh");
    }
  }

  void screenview() async {
    await widget.analytics.logScreenView(screenName: "HomeScreen");
  }

  @override
  void initState() {
    screenview();
    if (widget.justloaded) {
      refreshevents();
    } else {
      refresh();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    Future<void> navigate(Event event, int index) async {
      try {
        Event chosenEvent = await db.getEventfromDocId(event.docid);
        List<AppUser> participants =
            await db.geteventparticipantslist(chosenEvent);

        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EventDetailScreen(
                      event: chosenEvent,
                      curruser: widget.curruser,
                      participants: participants,
                      interactfav: interactfav,
                      curruserlocation: widget.curruserlocation,
                      analytics: widget.analytics,
                    ),
                settings: RouteSettings(name: "EventDetailScreen")));
      } catch (e) {
        displayErrorSnackBar("Could not display event");
      }
      refresh();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            await db.addAttributetoAllDocuments();
          },
          child: Text(
            "Clout.",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w900,
              fontSize: 50,
            ),
            textScaleFactor: 1.0,
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => NotificationScreen(
                            curruser: widget.curruser,
                            curruserlocation: widget.curruserlocation,
                            analytics: widget.analytics,
                          ),
                      settings: RouteSettings(name: "NotificationScreen")));
              refresh();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
              child: Center(
                child: SizedBox(
                  height: 30,
                  width: 32,
                  child: Stack(children: [
                    const Icon(
                      CupertinoIcons.heart,
                      color: Colors.black,
                      size: 30,
                    ),
                    widget.curruser.notificationcounter != 0
                        ? Align(
                            alignment: Alignment.topRight,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: Container(
                                height: 15,
                                width: 15,
                                color: const Color.fromARGB(255, 255, 48, 117),
                                child: Text(
                                  widget.curruser.notificationcounter > 9
                                      ? ""
                                      : widget.curruser.notificationcounter
                                          .toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ]),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatListScreen(
                            curruser: widget.curruser,
                            curruserlocation: widget.curruserlocation,
                            analytics: widget.analytics,
                          ),
                      settings: RouteSettings(name: "ChatListScreen")));
              refresh();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 9, 0),
              child: Center(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: Stack(children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.black,
                      size: 30,
                    ),
                    widget.curruser.chatnotificationcounter != 0
                        ? Align(
                            alignment: Alignment.topRight,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: Container(
                                height: 15,
                                width: 15,
                                color: const Color.fromARGB(255, 255, 48, 117),
                                child: Text(
                                  widget.curruser.chatnotificationcounter > 9
                                      ? ""
                                      : widget.curruser.chatnotificationcounter
                                          .toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Theme.of(context).primaryColor,
        child: Padding(
            padding: EdgeInsets.all(screenheight * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventListView(
                  isHorizontal: false,
                  eventList: totaleventlist,
                  onTap: navigate,
                  scrollable: true,
                  leftpadding: false,
                  curruser: widget.curruser,
                  interactfav: interactfav,
                  screenheight: screenheight,
                  screenwidth: screenwidth,
                )
              ],
            )),
      ),
    );
  }
}
