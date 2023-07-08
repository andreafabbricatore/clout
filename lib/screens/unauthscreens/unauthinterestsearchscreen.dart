import 'package:clout/components/loadingwidget.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/unautheventlistview.dart';
import 'package:clout/components/unauthnoeventsbox.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/unauthscreens/unautheventdetailscreen.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
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
  applogic logic = applogic();

  Future<void> refreshevents() async {
    try {
      List<Event> interesteventlist = [];
      interesteventlist = await db.UnAuthgetLngLatEventsByInterest(
        widget.curruserlocation.center[0],
        widget.curruserlocation.center[1],
        widget.interest,
      );

      setState(() {
        widget.events = interesteventlist;
      });
    } catch (e) {
      logic.displayErrorSnackBar("Could not refresh events", context);
    }
  }

  Future<void> refresh() async {
    try {
      await refreshevents();
    } catch (e) {
      logic.displayErrorSnackBar("Could not refresh", context);
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
                settings: RouteSettings(name: "UnAuthEventDetailScreen")));
      } catch (e) {
        logic.displayErrorSnackBar("Could not display event", context);
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
        child: Padding(
            padding: EdgeInsets.all(screenheight * 0.02),
            child: widget.events.isNotEmpty
                ? SizedBox(
                    height: widget.events.length *
                                (screenheight * 0.1 + 210.0) >=
                            screenheight
                        ? widget.events.length * (screenheight * 0.1 + 210.0)
                        : screenheight,
                    child: UnAuthEventListView(
                      eventList: widget.events,
                      onTap: navigate,
                      scrollable: true,
                      leftpadding: 2.0,
                      screenheight: screenheight,
                      screenwidth: screenwidth,
                    ),
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
