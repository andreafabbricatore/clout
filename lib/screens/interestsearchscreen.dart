import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';

import '../components/event.dart';

class InterestSearchScreen extends StatefulWidget {
  InterestSearchScreen(
      {Key? key,
      required this.interest,
      required this.events,
      required this.curruser,
      required this.city})
      : super(key: key);
  String interest;
  List<Event> events;
  AppUser curruser;
  String city;
  @override
  State<InterestSearchScreen> createState() => _InterestSearchScreenState();
}

class _InterestSearchScreenState extends State<InterestSearchScreen> {
  db_conn db = db_conn();

  void displayErrorSnackBar(String error) async {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    await Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  Future<void> refreshevents() async {
    try {
      List<Event> currcityeventlist = await db.getCurrCityEvents(widget.city);
      List<Event> interesteventlist = [];
      for (int i = 0; i < currcityeventlist.length; i++) {
        if (widget.interest == currcityeventlist[i].interest) {
          setState(() {
            interesteventlist.add(currcityeventlist[i]);
          });
        }
      }
      setState(() {
        widget.events = interesteventlist;
      });
    } catch (e) {
      displayErrorSnackBar("Could not refresh events");
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
  Widget build(BuildContext context) {
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
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 255, 48, 117),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventListView(
              isHorizontal: false,
              eventList: widget.events,
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
