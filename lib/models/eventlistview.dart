import 'package:cached_network_image/cached_network_image.dart';
import 'package:clout/defs/event.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventListView extends StatelessWidget {
  final Function(Event event, int index)? onTap;
  final List<Event> eventList;
  bool scrollable;
  double leftpadding;
  AppUser curruser;
  final Function(Event event) interactfav;
  double screenwidth;
  double screenheight;
  EventListView({
    Key? key,
    this.onTap,
    required this.eventList,
    required this.scrollable,
    required this.leftpadding,
    required this.curruser,
    required this.interactfav,
    required this.screenwidth,
    required this.screenheight,
  }) : super(key: key);

  db_conn db = db_conn();
  Widget _eventImage(String image, Event event) {
    return SizedBox(
      height: 200,
      width: screenwidth * 0.9,
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: CachedNetworkImage(
            imageUrl: image,
            fit: BoxFit.cover,
            height: 200,
            width: screenwidth * 0.9,
            fadeInDuration: const Duration(milliseconds: 10),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () async {
              await interactfav(event);
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(curruser.favorites.contains(event.docid)
                  ? Icons.bookmark
                  : Icons.bookmark_border),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              height: screenheight * 0.02,
              width: event.participants.length != event.maxparticipants
                  ? screenwidth * 0.27
                  : screenwidth * 0.42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                  child: Text(
                    event.participants.length != event.maxparticipants
                        ? (event.showparticipants ||
                                curruser.uid == event.hostdocid)
                            ? "${event.participants.length}/${event.maxparticipants} participants"
                            : "?/${event.maxparticipants} participants"
                        : "Participant number reached",
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                    textScaleFactor: 1.0,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }

  Widget _listViewItem(
    Event event,
    int index,
  ) {
    Widget widget;
    widget = SizedBox(
      width: screenwidth * 0.8,
      height: screenheight * 0.1 + 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eventImage(event.image, event),
          SizedBox(
            height: screenheight * 0.02,
          ),
          SizedBox(
            width: screenwidth * 0.85,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenwidth * 0.6,
                  child: Text(
                    event.title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(event.interest,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 48, 117))),
              ],
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: screenwidth * 0.9,
            child: Text(
              event.showlocation
                  ? "${event.address}, ${DateFormat.MMMd().format(event.datetime)} @ ${DateFormat('hh:mm a').format(event.datetime)}"
                  : "Secret location, ${DateFormat.MMMd().format(event.datetime)} @ ${DateFormat('hh:mm a').format(event.datetime)}",
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => onTap?.call(event, index),
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: eventList.length,
      itemBuilder: (_, index) {
        Event event = eventList.reversed.toList()[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 0, top: 10, left: leftpadding),
          child: _listViewItem(event, index),
        );
      },
    );
  }
}
