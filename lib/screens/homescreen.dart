import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/services/auth.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class HomeScreen extends StatefulWidget {
  List interests = [];
  List<Event> eventlist = [];
  List<Event> interestevents = [];
  bool updatehome;
  AppUser curruser;
  HomeScreen(
      {Key? key,
      required this.interests,
      required this.eventlist,
      required this.interestevents,
      required this.updatehome,
      required this.curruser})
      : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  db_conn db = db_conn();
  List<Event> generaleventlist = [];
  List<Event> interesteventlist = [];
  List userinterests = [];

  void getEventsList(interests) async {
    List<Event> events = await db.getEvents(interests);
    setState(() {
      generaleventlist = events;
    });
  }

  void getInterestEventsList(interests) async {
    List<Event> interestevents = await db.getInterestEvents(interests);
    setState(() {
      interesteventlist = interestevents;
    });
  }

  Future<void> refreshevents() async {
    print("refreshed");
    List<Event> events = await db.getEvents(userinterests);
    List<Event> interestevents = await db.getInterestEvents(userinterests);
    setState(() {
      generaleventlist = events;
      interesteventlist = interestevents;
    });
  }

  Future<void> updatecurruser() async {
    AppUser updateduser = await db.getUserFromDocID(widget.curruser.docid);
    setState(() {
      widget.curruser = updateduser;
    });
  }

  Future interactfav(Event event) async {
    try {
      if (widget.curruser.favorites.contains(event.docid)) {
        await db.remFromFav(widget.curruser.docid, event.docid);
      } else {
        await db.addToFav(widget.curruser.docid, event.docid);
      }
    } catch (e) {
      print("Could not interact");
    } finally {
      updatecurruser();
    }
  }

  Future<void> refresh() async {
    try {
      await updatecurruser();
      await refreshevents();
    } catch (e) {
      print("error");
    }
  }

  @override
  void initState() {
    generaleventlist = widget.eventlist;
    userinterests = widget.interests;
    interesteventlist = widget.interestevents;
    if (generaleventlist.isEmpty) {
      getEventsList(userinterests);
    }
    if (interesteventlist.isEmpty) {
      getInterestEventsList(userinterests);
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

    Future<void> _navigate(Event event, int index) async {
      List<AppUser> participants = [
        for (String x in event.participants) await db.getUserFromDocID(x)
      ];

      Event newevent = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EventDetailScreen(
                    event: event,
                    curruser: widget.curruser,
                    participants: participants,
                    interactfav: interactfav,
                  )));
      refreshevents();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Clout",
          style: TextStyle(
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
            child: Padding(
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
            InkWell(
              onTap: () async {
                await db.createevent(
                    "Baking",
                    "Making cakes then eating them",
                    "Food",
                    "Cracco restaurant duomo",
                    widget.curruser.username,
                    DateTime(2022, 9, 7, 17, 30),
                    3,
                    widget.curruser,
                    widget.curruser.docid);
              },
              child: Text(
                "Suggested",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: screenheight * 0.02),
            EventListView(
              eventList: interesteventlist,
              onTap: _navigate,
              scrollable: true,
              leftpadding: false,
              curruser: widget.curruser,
              interactfav: interactfav,
            ),
            Text("Popular",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600)),
            EventListView(
              isHorizontal: false,
              eventList: generaleventlist,
              onTap: _navigate,
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
