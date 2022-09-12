import 'dart:async';

import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/screens/loading.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  List interests = [];
  List<Event> eventlist = [];
  List<Event> interestevents = [];
  bool firstsetup;
  AppUser curruser;
  AppLocation userlocation;
  HomeScreen(
      {Key? key,
      required this.interests,
      required this.eventlist,
      required this.interestevents,
      required this.firstsetup,
      required this.curruser,
      required this.userlocation})
      : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  db_conn db = db_conn();
  List<Event> generaleventlist = [];
  List<Event> interesteventlist = [];
  List userinterests = [];

  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  void getInterestEventsList(interests) async {
    try {
      List<Event> interestevents = await db.getInterestEvents(interests);
      setState(() {
        interesteventlist = interestevents;
      });
    } catch (e) {
      displayErrorSnackBar("Could not retrieve events");
    }
  }

  void getSortedCurrLocEventsList(interests) async {
    try {
      interesteventlist = [];
      generaleventlist = [];
      List<Event> currloceventlist = [];
      currloceventlist = await db.getLngLatEvents(widget.userlocation.center[0],
          widget.userlocation.center[1], widget.userlocation.country);
      for (int i = 0; i < currloceventlist.length; i++) {
        if (interests.contains(currloceventlist[i].interest)) {
          setState(() {
            interesteventlist.add(currloceventlist[i]);
          });
        } else {
          setState(() {
            generaleventlist.add(currloceventlist[i]);
          });
        }
      }
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
      getSortedCurrLocEventsList(userinterests);
    } catch (e) {
      displayErrorSnackBar("Could not refresh events");
    }
  }

  Future<void> updatecurruser() async {
    try {
      AppUser updateduser = await db.getUserFromDocID(widget.curruser.docid);
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
        await db.remFromFav(widget.curruser.docid, event.docid);
      } else {
        await db.addToFav(widget.curruser.docid, event.docid);
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

  @override
  void initState() {
    userinterests = widget.interests;
    if (!widget.firstsetup) {
      generaleventlist = widget.eventlist;
      interesteventlist = widget.interestevents;
      updatecurruser();
    }
    if (generaleventlist.isEmpty || interesteventlist.isEmpty) {
      getSortedCurrLocEventsList(userinterests);
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
        List<AppUser> participants = [
          for (String x in chosenEvent.participants)
            await db.getUserFromDocID(x)
        ];

        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EventDetailScreen(
                      event: chosenEvent,
                      curruser: widget.curruser,
                      participants: participants,
                      interactfav: interactfav,
                    )));
      } catch (e) {
        displayErrorSnackBar("Could not display event");
      }
      refresh();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Clout",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontFamily: "Kristi",
              fontWeight: FontWeight.w500,
              fontSize: 50),
          textScaleFactor: 1.0,
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        actions: [
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
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(screenheight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {},
              child: const Text(
                "Suggested",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600),
                textScaleFactor: 1.2,
              ),
            ),
            SizedBox(height: screenheight * 0.02),
            EventListView(
              eventList: interesteventlist,
              onTap: navigate,
              scrollable: true,
              leftpadding: false,
              curruser: widget.curruser,
              interactfav: interactfav,
              screenheight: screenheight,
              screenwidth: screenwidth,
            ),
            const Text(
              "Popular",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600),
              textScaleFactor: 1.2,
            ),
            EventListView(
              isHorizontal: false,
              eventList: generaleventlist,
              onTap: navigate,
              scrollable: true,
              leftpadding: false,
              curruser: widget.curruser,
              interactfav: interactfav,
              screenheight: screenheight,
              screenwidth: screenwidth,
            )
          ],
        ),
      ),
    );
  }
}
