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
      required this.curruser})
      : super(key: key);
  String interest;
  List<Event> events;
  AppUser curruser;

  @override
  State<InterestSearchScreen> createState() => _InterestSearchScreenState();
}

class _InterestSearchScreenState extends State<InterestSearchScreen> {
  db_conn db = db_conn();

  void displayErrorSnackBar(String error) async {
    final snackBar = SnackBar(
      content: Text(error),
      duration: Duration(seconds: 2),
    );
    await Future.delayed(Duration(milliseconds: 400));
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

  @override
  Widget build(BuildContext context) {
    Future<void> _navigate(Event event, int index) async {
      try {
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

        int index = widget.events.indexWhere((element) => element == event);
        setState(() {
          widget.events[index] = newevent;
        });
      } catch (e) {
        displayErrorSnackBar("Could not display event");
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "${widget.interest} events",
          style: TextStyle(
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
          child: Icon(
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
