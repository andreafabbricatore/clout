import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBarListView extends StatefulWidget {
  SearchBarListView(
      {super.key, required this.eventres, required this.userdocid});
  List<Event> eventres;
  String userdocid;
  @override
  State<SearchBarListView> createState() => _SearchBarListViewState();
}

class _SearchBarListViewState extends State<SearchBarListView> {
  db_conn db = db_conn();

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> _navigate(Event event, int index) async {
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

    return EventListView(
      eventList: widget.eventres,
      onTap: _navigate,
      isHorizontal: false,
    );
  }
}
