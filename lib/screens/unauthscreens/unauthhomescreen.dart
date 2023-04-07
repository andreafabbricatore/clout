import 'dart:async';
import 'package:clout/components/event.dart';
import 'package:clout/components/loadingwidget.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/unautheventlistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/unauthscreens/unautheventdetailscreen.dart';
import 'package:clout/services/db.dart';
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
      currloceventlist = await db.UnAuthgetLngLatEvents(
          widget.curruserlocation.center[0],
          widget.curruserlocation.center[1],
          widget.curruserlocation.country);
      for (int i = 0; i < currloceventlist.length; i++) {
        generaleventlist.add(currloceventlist[i]);
      }
      setState(() {
        totaleventlist = generaleventlist;
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
        displayErrorSnackBar("Could not display event");
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
                child: UnAuthEventListView(
                  eventList: totaleventlist,
                  onTap: navigate,
                  scrollable: true,
                  leftpadding: 2.0,
                  screenheight: screenheight,
                  screenwidth: screenwidth,
                )),
          ),
        ));
  }
}
