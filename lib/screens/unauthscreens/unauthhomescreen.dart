import 'dart:async';
import 'package:clout/defs/event.dart';
import 'package:clout/components/loadingwidget.dart';
import 'package:clout/defs/location.dart';
import 'package:clout/models/unautheventlistview.dart';
import 'package:clout/components/unauthnoeventsbox.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/screens/unauthscreens/unautheventdetailscreen.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class UnAuthHomeScreen extends StatefulWidget {
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  UnAuthHomeScreen(
      {Key? key, required this.curruserlocation, required this.analytics})
      : super(key: key);
  @override
  State<UnAuthHomeScreen> createState() => _UnAuthHomeScreenState();
}

class _UnAuthHomeScreenState extends State<UnAuthHomeScreen> {
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
      currloceventlist = await db.UnAuthgetLngLatEvents(
        widget.curruserlocation.center[0],
        widget.curruserlocation.center[1],
      );
      for (int i = 0; i < currloceventlist.length; i++) {
        generaleventlist.add(currloceventlist[i]);
      }
      setState(() {
        totaleventlist = generaleventlist;
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

  Future interactfav(Event event) async {}

  @override
  void initState() {
    refreshevents();

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
        logic.displayErrorSnackBar("Could not display event", context);
      }
      refreshevents();
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Clout.",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w900,
              fontSize: 50,
            ),
            textScaleFactor: 1.0,
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: CustomRefreshIndicator(
          onRefresh: refreshevents,
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
                    ? UnAuthEventListView(
                        eventList: totaleventlist,
                        onTap: navigate,
                        scrollable: true,
                        leftpadding: 2.0,
                        screenheight: screenheight,
                        screenwidth: screenwidth,
                      )
                    : ListView(
                        children: [
                          Center(
                            child: UnAuthdelayedNoEventsBox(
                                screenheight: screenheight,
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
}
