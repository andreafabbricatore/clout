import 'package:clout/components/location.dart';
import 'package:clout/components/unautheventlistview.dart';
import 'package:clout/components/unauthnoeventsbox.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/unauthscreens/unautheventdetailscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:clout/components/event.dart';

class UnAuthInterestSearchScreen extends StatefulWidget {
  UnAuthInterestSearchScreen(
      {Key? key,
      required this.interest,
      required this.events,
      required this.curruserlocation,
      required this.analytics})
      : super(key: key);
  String interest;
  List<Event> events;
  FirebaseAnalytics analytics;
  AppLocation curruserlocation;

  @override
  State<UnAuthInterestSearchScreen> createState() =>
      _UnAuthInterestSearchScreenState();
}

class _UnAuthInterestSearchScreenState
    extends State<UnAuthInterestSearchScreen> {
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

  Future<void> refreshevents() async {
    try {
      List<Event> interesteventlist = [];
      interesteventlist = await db.UnAuthgetLngLatEventsByInterest(
        widget.curruserlocation.center[0],
        widget.curruserlocation.center[1],
        widget.interest,
        widget.curruserlocation.country,
      );

      setState(() {
        widget.events = interesteventlist;
      });
    } catch (e) {
      displayErrorSnackBar("Could not refresh events");
    }
  }

  Future<void> refresh() async {
    try {
      await refreshevents();
    } catch (e) {
      displayErrorSnackBar("Could not refresh");
    }
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
                settings: RouteSettings(name: "EventDetailScreen")));
      } catch (e) {
        displayErrorSnackBar("Could not display event");
      }
      refresh();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "${widget.interest} events",
          style: const TextStyle(
              color: Color.fromARGB(
                255,
                255,
                48,
                117,
              ),
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Theme.of(context).primaryColor,
        child: Padding(
            padding: EdgeInsets.all(screenheight * 0.02),
            child: widget.events.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UnAuthEventListView(
                        eventList: widget.events,
                        onTap: navigate,
                        scrollable: true,
                        leftpadding: 2.0,
                        screenheight: screenheight,
                        screenwidth: screenwidth,
                      )
                    ],
                  )
                : Center(
                    child: UnAuthnoEventsBox(
                      screenheight: screenheight,
                      screenwidth: screenwidth,
                      interest: widget.interest,
                      allcolor: Colors.black,
                      analytics: widget.analytics,
                    ),
                  )),
      ),
    );
  }
}
