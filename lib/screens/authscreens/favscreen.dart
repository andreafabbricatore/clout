import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'eventdetailscreen.dart';

class FavScreen extends StatefulWidget {
  AppUser curruser;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  FavScreen(
      {Key? key,
      required this.curruser,
      required this.curruserlocation,
      required this.analytics})
      : super(key: key);

  @override
  State<FavScreen> createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  List<Event> favorites = [];
  db_conn db = db_conn();
  Color loadedcolor = Colors.white;

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

  Future<void> updatefavevents() async {
    List<Event> updatedfavevents = await db.getFavEvents(widget.curruser);
    setState(() {
      favorites = updatedfavevents;
    });
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
      displayErrorSnackBar("Could not update favorites");
    } finally {
      refresh();
    }
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

  Future<void> refresh() async {
    try {
      await updatecurruser();
      await updatefavevents();
    } catch (e) {
      displayErrorSnackBar("Could not refresh");
    }
  }

  Future<void> setcolour() async {
    await Future.delayed(const Duration(milliseconds: 250));
    setState(() {
      loadedcolor = Colors.black;
    });
  }

  @override
  void initState() {
    refresh();
    super.initState();
    setcolour();
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
        displayErrorSnackBar("Could not display event");
      }
      refresh();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Favorites",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(children: [
        favorites.isEmpty
            ? SizedBox(
                height: screenheight * 0.4,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Add events you don't want to miss!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: loadedcolor),
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.0,
                      ),
                      SizedBox(
                        height: screenheight * 0.01,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Click on the favorites icon.",
                            style: TextStyle(fontSize: 20, color: loadedcolor),
                            textScaleFactor: 1.0,
                          ),
                          Icon(
                            Icons.bookmark,
                            color: loadedcolor,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            : EventListView(
                scrollable: true,
                eventList: favorites,
                leftpadding: 20.0,
                curruser: widget.curruser,
                interactfav: interactfav,
                onTap: navigate,
                screenheight: screenheight,
                screenwidth: screenwidth,
              )
      ]),
    );
  }
}
