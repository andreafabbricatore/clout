import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/unautheventlistview.dart';
import 'package:clout/components/unauthuserlistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/unauthscreens/unautheventdetailscreen.dart';
import 'package:clout/screens/unauthscreens/unauthprofilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class UnAuthSearchBarListView extends StatefulWidget {
  UnAuthSearchBarListView(
      {super.key,
      required this.searchevents,
      required this.eventres,
      required this.userres,
      required this.query,
      required this.curruserlocation,
      required this.analytics});
  bool searchevents;
  List<Event> eventres;
  List<AppUser> userres;
  FirebaseAnalytics analytics;
  String query;
  AppLocation curruserlocation;

  @override
  State<UnAuthSearchBarListView> createState() =>
      _UnAuthSearchBarListViewState();
}

class _UnAuthSearchBarListViewState extends State<UnAuthSearchBarListView> {
  db_conn db = db_conn();

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

  Future<void> refresh() async {
    try {
      await refreshsearch();
    } catch (e) {
      displayErrorSnackBar("Could not refresh");
    }
  }

  Future<void> refreshsearch() async {
    try {
      if (widget.searchevents) {
        List<Event> temp = await db.UnAuthsearchEvents(widget.query);
        setState(() {
          widget.eventres = temp;
        });
      } else {
        List<AppUser> temp = await db.UnAuthsearchUsers(widget.query);
        setState(() {
          widget.userres = temp;
        });
      }
    } catch (e) {
      displayErrorSnackBar("Could not refresh events");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> eventnavigate(Event event, int index) async {
      try {
        Event chosenEvent = await db.getEventfromDocId(event.docid);
        List<AppUser> participants =
            await db.geteventparticipantslist(chosenEvent);
        await Future.delayed(const Duration(milliseconds: 50));

        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => UnAuthEventDetailScreen(
                      event: chosenEvent,
                      participants: participants,
                      curruserlocation: widget.curruserlocation,
                      analytics: widget.analytics,
                    ),
                settings: RouteSettings(name: "UnAuthEventDetailScreen")));
      } catch (e) {
        displayErrorSnackBar("Could not refresh");
      }
      refresh();
    }

    Future<void> usernavigate(AppUser user, int index) async {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UnAuthProfileScreen(
                  analytics: widget.analytics,
                  visit: true,
                ),
            fullscreenDialog: true,
            settings: RouteSettings(name: "UnAuthProfileScreen")),
      );
    }

    return widget.searchevents
        ? Expanded(
            child: UnAuthEventListView(
              eventList: widget.eventres,
              onTap: eventnavigate,
              scrollable: true,
              leftpadding: 8.0,
              screenheight: screenheight,
              screenwidth: screenwidth,
            ),
          )
        : Expanded(
            child: UnAuthUserListView(
                userres: widget.userres,
                screenwidth: screenwidth,
                onTap: usernavigate),
          );
  }
}
