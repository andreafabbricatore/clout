import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/screens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBarListView extends StatefulWidget {
  SearchBarListView(
      {super.key,
      required this.searchevents,
      required this.eventres,
      required this.userres,
      required this.curruser,
      required this.query});
  bool searchevents;
  List<Event> eventres;
  List<AppUser> userres;
  AppUser curruser;
  String query;
  @override
  State<SearchBarListView> createState() => _SearchBarListViewState();
}

class _SearchBarListViewState extends State<SearchBarListView> {
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
    AppUser updateduser = await db.getUserFromDocID(widget.curruser.docid);
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
    } catch (e) {
      displayErrorSnackBar("Could not refresh events");
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> eventnavigate(Event event, int index) async {
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
        displayErrorSnackBar("Could not refresh");
      }
      refresh();
    }

    Future<void> usernavigate(AppUser user, int index) async {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => ProfileScreen(
                    user: user,
                    curruser: widget.curruser,
                    visit: true,
                  )));
    }

    return widget.searchevents
        ? EventListView(
            eventList: widget.eventres,
            onTap: eventnavigate,
            isHorizontal: false,
            scrollable: true,
            leftpadding: false,
            curruser: widget.curruser,
            interactfav: interactfav,
            screenheight: screenheight,
            screenwidth: screenwidth,
          )
        : UserListView(
            userres: widget.userres,
            onTap: usernavigate,
            curruser: widget.curruser,
            screenwidth: screenwidth,
            showcloutscore: false,
            showrembutton: false,
          );
  }
}
