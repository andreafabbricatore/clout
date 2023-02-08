import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/createeventscreen.dart';
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
      required this.userlocation})
      : super(key: key);
  String interest;
  List<Event> events;
  AppUser curruser;
  AppLocation userlocation;
  @override
  State<InterestSearchScreen> createState() => _InterestSearchScreenState();
}

class _InterestSearchScreenState extends State<InterestSearchScreen> {
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

  Future<void> updatecurruser() async {
    try {
      AppUser updateduser = await db.getUserFromUID(widget.curruser.uid);
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
        await db.remFromFav(widget.curruser.uid, event.docid);
      } else {
        await db.addToFav(widget.curruser.uid, event.docid);
      }
    } catch (e) {
      displayErrorSnackBar("Could not update favorites");
    } finally {
      updatecurruser();
    }
  }

  Future<void> refreshevents() async {
    try {
      List<Event> interesteventlist = [];
      interesteventlist = await db.getLngLatEventsByInterest(
          widget.userlocation.center[0],
          widget.userlocation.center[1],
          widget.interest,
          widget.userlocation.country,
          widget.curruser);

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
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> navigate(Event event, int index) async {
      try {
        List<AppUser> participants = [
          for (String x in event.participants) await db.getUserFromUID(x)
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
                    EventListView(
                      isHorizontal: false,
                      eventList: widget.events,
                      onTap: navigate,
                      scrollable: true,
                      leftpadding: false,
                      curruser: widget.curruser,
                      interactfav: interactfav,
                      screenheight: screenheight,
                      screenwidth: screenwidth,
                    )
                  ],
                )
              : SizedBox(
                  width: screenwidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenheight * 0.1,
                      ),
                      const Text(
                        "No Events yet :(",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                        textScaleFactor: 1.0,
                      ),
                      SizedBox(
                        height: screenheight * 0.03,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  CreateEventScreen(
                                curruser: widget.curruser,
                                allowbackarrow: true,
                                startinterest: widget.interest,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: screenwidth * 0.13,
                          width: screenwidth * 0.6,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1, color: Colors.black)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Create Event",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
