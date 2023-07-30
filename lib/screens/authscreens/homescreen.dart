import 'dart:async';
import 'package:clout/defs/event.dart';
import 'package:clout/models/eventlistview.dart';
import 'package:clout/components/loadingwidget.dart';
import 'package:clout/defs/location.dart';
import 'package:clout/components/noeventsbox.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/screens/authscreens/eventdetailscreen.dart';
import 'package:clout/screens/authscreens/notificationscreen.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  bool justloaded;
  AppUser curruser;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  final Function(int index) changePage;
  HomeScreen(
      {Key? key,
      required this.justloaded,
      required this.curruser,
      required this.curruserlocation,
      required this.analytics,
      required this.changePage})
      : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  db_conn db = db_conn();
  applogic logic = applogic();
  List<Event> generaleventlist = [];
  List<Event> interesteventlist = [];
  List<Event> totaleventlist = [];
  final double _offsetToArmed = 200;
  bool blank = true;

  @override
  void dispose() {
    super.dispose();
  }

  void getSortedCurrLocEventsList() async {
    try {
      interesteventlist = [];
      generaleventlist = [];
      List<Event> currloceventlist = [];
      currloceventlist = await db.getLngLatEvents(
          widget.curruserlocation.center[0],
          widget.curruserlocation.center[1],
          widget.curruser);
      for (int i = 0; i < currloceventlist.length; i++) {
        if (widget.curruser.interests.contains(currloceventlist[i].interest)) {
          if (widget.curruser.friends.contains(currloceventlist[i].hostdocid)) {
            interesteventlist.insert(0, currloceventlist[i]);
          } else {
            interesteventlist.add(currloceventlist[i]);
          }
        } else {
          if (widget.curruser.friends.contains(currloceventlist[i].hostdocid)) {
            interesteventlist.insert(0, currloceventlist[i]);
          } else {
            generaleventlist.add(currloceventlist[i]);
          }
        }
      }
      setState(() {
        totaleventlist = interesteventlist + generaleventlist;
        if (totaleventlist.isEmpty) {
          blank = false;
        } else {
          blank = true;
        }
      });
    } catch (e) {
      logic.displayErrorSnackBar("Could not get events around you", context);
    }
  }

  Future<void> refreshevents() async {
    try {
      getSortedCurrLocEventsList();
    } catch (e) {
      logic.displayErrorSnackBar("Could not refresh events", context);
    }
  }

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
      logic.displayErrorSnackBar("Could not update favorites", context);
    } finally {
      updatecurruser();
    }
  }

  Future<void> refresh() async {
    try {
      await updatecurruser();
      await refreshevents();
    } catch (e) {
      logic.displayErrorSnackBar("Could not refresh", context);
    }
  }

  void screenview() async {
    await widget.analytics.logScreenView(screenName: "HomeScreen");
  }

  Future<void> navigate(Event event) async {
    try {
      Event chosenEvent = await db.getEventfromDocId(event.docid);
      List<AppUser> participants =
          await db.geteventparticipantslist(chosenEvent);
      await Future.delayed(const Duration(milliseconds: 50));
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
              settings: RouteSettings(name: "EventDetailScreen")));
    } catch (e) {
      logic.displayErrorSnackBar("Could not display event", context);
    }
    refresh();
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

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: homescreenappbar(context),
        body: CustomRefreshIndicator(
          onRefresh: refresh,
          builder: (context, child, controller) {
            return LoadingWidget(
              screenheight: screenheight,
              screenwidth: screenwidth,
              controller: controller,
              child: child,
            );
          },
          child: SizedBox(
            height: totaleventlist.length * (screenheight * 0.1 + 210.0) >=
                    screenheight
                ? totaleventlist.length * (screenheight * 0.1 + 210.0)
                : screenheight,
            child: Padding(
                padding: EdgeInsets.all(screenheight * 0.02),
                child: totaleventlist.isNotEmpty
                    ? EventListView(
                        eventList: totaleventlist,
                        onTap: navigate,
                        scrollable: true,
                        leftpadding: 2.0,
                        curruser: widget.curruser,
                        interactfav: interactfav,
                        screenheight: screenheight,
                        screenwidth: screenwidth,
                      )
                    : ListView(
                        children: [
                          Center(
                            child: delayedNoEventsBox(
                                screenheight: screenheight,
                                curruser: widget.curruser,
                                screenwidth: screenwidth,
                                interest: "Sports",
                                analytics: widget.analytics,
                                allcolor: Colors.black,
                                blank: blank),
                          ),
                        ],
                      )),
          ),
        ));
  }

  AppBar homescreenappbar(BuildContext context) {
    return AppBar(
      title: GestureDetector(
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
      centerTitle: true,
      automaticallyImplyLeading: false,
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
          onTap: () {
            widget.changePage.call(1);
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
    );
  }
}
