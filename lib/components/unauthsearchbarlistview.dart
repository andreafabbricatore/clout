import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/unautheventlistview.dart';
import 'package:clout/components/unauthuserlistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/unauthscreens/unautheventdetailscreen.dart';
import 'package:clout/screens/unauthscreens/unauthprofilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
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
  applogic logic = applogic();
  Future<void> refresh() async {
    try {
      await refreshsearch();
    } catch (e) {
      logic.displayErrorSnackBar("Could not refresh", context);
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
      logic.displayErrorSnackBar("Could not refresh events", context);
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
        logic.displayErrorSnackBar("Could not refresh", context);
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
