import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBarListView extends StatefulWidget {
  SearchBarListView(
      {super.key,
      required this.searchevents,
      required this.eventres,
      required this.userres,
      required this.userdocid,
      required this.curruser});
  bool searchevents;
  List<Event> eventres;
  List<AppUser> userres;
  String userdocid;
  AppUser curruser;
  @override
  State<SearchBarListView> createState() => _SearchBarListViewState();
}

class _SearchBarListViewState extends State<SearchBarListView> {
  db_conn db = db_conn();

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> _eventnavigate(Event event, int index) async {
      List pfpurls = [
        for (String x in event.participants) await db.getUserPFPfromUsername(x)
      ];
      Event newevent = await Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => EventDetailScreen(
                    event: event,
                    pfp_urls: pfpurls,
                    userdocid: widget.userdocid,
                    curruser: widget.curruser,
                  )));

      try {
        int index = widget.eventres.indexWhere((element) => element == event);
        setState(() {
          widget.eventres[index] = newevent;
        });
      } catch (e) {
        print("error");
      }
    }

    Future<void> _usernavigate(AppUser user, int index) async {}
    return widget.searchevents
        ? EventListView(
            eventList: widget.eventres,
            onTap: _eventnavigate,
            isHorizontal: false,
          )
        : UserListView(
            userres: widget.userres,
            onTap: _usernavigate,
          );
  }
}
