import 'package:clout/models/eventlistview.dart';
import 'package:clout/components/loadingwidget.dart';
import 'package:clout/defs/location.dart';
import 'package:clout/components/noeventsbox.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/screens/authscreens/eventdetailscreen.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'package:clout/defs/event.dart';

class InterestSearchScreen extends StatefulWidget {
  InterestSearchScreen(
      {Key? key,
      required this.interest,
      required this.events,
      required this.curruser,
      required this.curruserlocation,
      required this.analytics})
      : super(key: key);
  String interest;
  List<Event> events;
  AppUser curruser;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  @override
  State<InterestSearchScreen> createState() => _InterestSearchScreenState();
}

class _InterestSearchScreenState extends State<InterestSearchScreen> {
  db_conn db = db_conn();
  applogic logic = applogic();

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

  Future<void> refreshevents() async {
    try {
      List<Event> interesteventlist = [];
      interesteventlist = await db.getLngLatEventsByInterest(
          widget.curruserlocation.center[0],
          widget.curruserlocation.center[1],
          widget.interest,
          widget.curruser);

      setState(() {
        widget.events = interesteventlist;
      });
    } catch (e) {
      logic.displayErrorSnackBar("Could not refresh events", context);
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
                    child: EventListView(
                      eventList: widget.events,
                      onTap: navigate,
                      scrollable: true,
                      leftpadding: 2.0,
                      curruser: widget.curruser,
                      interactfav: interactfav,
                      screenheight: screenheight,
                      screenwidth: screenwidth,
                    ),
                  )
                : Center(
                    child: noEventsBox(
                      screenheight: screenheight,
                      curruser: widget.curruser,
                      screenwidth: screenwidth,
                      interest: widget.interest,
                      analytics: widget.analytics,
                      allcolor: Colors.black,
                    ),
                  )),
      ),
    );
  }
}
