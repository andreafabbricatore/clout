import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/services/db.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  List interests = [];
  List<Event> eventlist = [];
  List<Event> interestevents = [];
  bool updatehome;
  AppUser curruser;
  AppLocation userlocation;
  HomeScreen(
      {Key? key,
      required this.interests,
      required this.eventlist,
      required this.interestevents,
      required this.updatehome,
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
  String city = "";

  void displayErrorSnackBar(String error) async {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    await Future.delayed(const Duration(milliseconds: 400));
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

  void getSortedCurrCityEventsList(interests) async {
    try {
      interesteventlist = [];
      generaleventlist = [];
      List<Event> currcityeventlist = await db.getCurrCityEvents(city);
      for (int i = 0; i < currcityeventlist.length; i++) {
        if (interests.contains(currcityeventlist[i].interest)) {
          setState(() {
            interesteventlist.add(currcityeventlist[i]);
          });
        } else {
          setState(() {
            generaleventlist.add(currcityeventlist[i]);
          });
        }
      }
    } catch (e) {
      displayErrorSnackBar("Could not get events in $city");
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
      getSortedCurrCityEventsList(userinterests);
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
    setState(() {
      city = widget.userlocation.city.split(" ").last;
    });
    generaleventlist = widget.eventlist;
    userinterests = widget.interests;
    interesteventlist = widget.interestevents;
    if (generaleventlist.isEmpty || interesteventlist.isEmpty) {
      getSortedCurrCityEventsList(userinterests);
    }
    if (widget.updatehome) {
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
        List<AppUser> participants = [
          for (String x in event.participants) await db.getUserFromDocID(x)
        ];

        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EventDetailScreen(
                      event: event,
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
        title: Text(
          "Clout - $city",
          style: const TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontWeight: FontWeight.bold,
              fontSize: 30),
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
            const Text(
              "Suggested",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: screenheight * 0.02),
            EventListView(
              eventList: interesteventlist,
              onTap: navigate,
              scrollable: true,
              leftpadding: false,
              curruser: widget.curruser,
              interactfav: interactfav,
            ),
            const Text("Popular",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600)),
            EventListView(
              isHorizontal: false,
              eventList: generaleventlist,
              onTap: navigate,
              scrollable: true,
              leftpadding: false,
              curruser: widget.curruser,
              interactfav: interactfav,
            )
          ],
        ),
      ),
    );
  }
}
