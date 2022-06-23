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
      required this.curruser});
  bool searchevents;
  List<Event> eventres;
  List<AppUser> userres;
  AppUser curruser;
  @override
  State<SearchBarListView> createState() => _SearchBarListViewState();
}

class _SearchBarListViewState extends State<SearchBarListView> {
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
      displayErrorSnackBar("Could not update favorites");
    } finally {
      updatecurruser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> _eventnavigate(Event event, int index) async {
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

      try {
        int index = widget.eventres.indexWhere((element) => element == event);
        setState(() {
          widget.eventres[index] = newevent;
        });
      } catch (e) {
        displayErrorSnackBar("Could not refresh");
      }
    }

    Future<void> _usernavigate(AppUser user, int index) async {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => ProfileScreen(
                    user: user,
                    curruser: widget.curruser,
                    visit: true,
                    interestpics: [],
                    interests: [],
                  )));
    }

    return widget.searchevents
        ? EventListView(
            eventList: widget.eventres,
            onTap: _eventnavigate,
            isHorizontal: false,
            scrollable: true,
            leftpadding: false,
            curruser: widget.curruser,
            interactfav: interactfav,
          )
        : UserListView(
            userres: widget.userres,
            onTap: _usernavigate,
            curruser: widget.curruser,
          );
  }
}
