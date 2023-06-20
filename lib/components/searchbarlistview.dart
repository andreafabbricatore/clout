import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/authscreens/eventdetailscreen.dart';
import 'package:clout/screens/authscreens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBarListView extends StatefulWidget {
  SearchBarListView(
      {super.key,
      required this.searchevents,
      required this.eventres,
      required this.userres,
      required this.curruser,
      required this.query,
      required this.curruserlocation,
      required this.analytics});
  bool searchevents;
  List<Event> eventres;
  List<AppUser> userres;
  AppUser curruser;
  String query;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  @override
  State<SearchBarListView> createState() => _SearchBarListViewState();
}

class _SearchBarListViewState extends State<SearchBarListView> {
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
    AppUser updateduser = await db.getUserFromUID(widget.curruser.uid);
    setState(() {
      widget.curruser = updateduser;
    });
  }

  Future<void> refresh() async {
    try {
      await updatecurruser();
      await refreshsearch();
    } catch (e) {
      displayErrorSnackBar("Could not refresh");
    }
  }

  Future<void> refreshsearch() async {
    try {
      await updatecurruser();
      if (widget.searchevents) {
        List<Event> temp = await db.searchEvents(widget.query, widget.curruser);
        setState(() {
          widget.eventres = temp;
        });
      } else {
        List<AppUser> temp =
            await db.searchUsers(widget.query, widget.curruser);
        setState(() {
          widget.userres = temp;
        });
      }
      await widget.analytics.logEvent(name: "search", parameters: {
        "searchevent": widget.searchevents.toString(),
        "searchuser": (!widget.searchevents).toString(),
        "searchterm": widget.query,
        "searchreslength": widget.searchevents
            ? widget.eventres.length
            : widget.userres.length,
      });
    } catch (e) {
      displayErrorSnackBar("Could not refresh events");
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
      displayErrorSnackBar("Could not update favorites");
    } finally {
      updatecurruser();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> eventnavigate(Event event, int index) async {
      try {
        Event chosenEvent = await db.getEventfromDocId(event.docid);
        List<AppUser> participants =
            await db.geteventparticipantslist(chosenEvent);
        await Future.delayed(const Duration(milliseconds: 50));
        await widget.analytics
            .logEvent(name: "event_navigate_from_search", parameters: {
          "searchterm": widget.query,
          "searchreslength": widget.searchevents
              ? widget.eventres.length
              : widget.userres.length,
          "eventinterest": event.interest,
          "hostinfriends":
              widget.curruser.friends.contains(event.hostdocid).toString(),
        });
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
        displayErrorSnackBar("Could not refresh");
      }
      refresh();
    }

    Future<void> usernavigate(AppUser user, int index) async {
      await widget.analytics
          .logEvent(name: "user_navigate_from_search", parameters: {
        "searchterm": widget.query,
        "searchreslength": widget.searchevents
            ? widget.eventres.length
            : widget.userres.length,
        "userinfriends": widget.curruser.friends.contains(user.uid).toString(),
      });
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => ProfileScreen(
                    user: user,
                    curruser: widget.curruser,
                    visit: true,
                    curruserlocation: widget.curruserlocation,
                    analytics: widget.analytics,
                  ),
              settings: RouteSettings(name: "ProfileScreen")));
    }

    return widget.searchevents
        ? Expanded(
            child: EventListView(
              eventList: widget.eventres,
              onTap: eventnavigate,
              scrollable: true,
              leftpadding: 8.0,
              curruser: widget.curruser,
              interactfav: interactfav,
              screenheight: screenheight,
              screenwidth: screenwidth,
            ),
          )
        : Expanded(
            child: UserListView(
              userres: widget.userres,
              onTap: usernavigate,
              curruser: widget.curruser,
              screenwidth: screenwidth,
              showcloutscore: false,
              showrembutton: false,
              showsendbutton: false,
              showfriendbutton: false,
            ),
          );
  }
}
