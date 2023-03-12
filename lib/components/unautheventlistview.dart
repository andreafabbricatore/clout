import 'package:clout/components/event.dart';
import 'package:clout/components/user.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UnAuthEventListView extends StatelessWidget {
  final bool isHorizontal;
  final Function(Event event, int index)? onTap;
  final List<Event> eventList;
  bool scrollable;
  bool leftpadding;
  double screenwidth;
  double screenheight;
  UnAuthEventListView({
    Key? key,
    this.isHorizontal = true,
    this.onTap,
    required this.eventList,
    required this.scrollable,
    required this.leftpadding,
    required this.screenwidth,
    required this.screenheight,
  }) : super(key: key);

  db_conn db = db_conn();
  Widget _eventImage(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.network(
        image,
        fit: BoxFit.cover,
        height: 150,
        width: 150,
      ),
    );
  }

  Widget _listViewItem(
    Event event,
    int index,
  ) {
    Widget widget;
    widget = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _eventImage(event.image),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        event.title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(event.interest,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 48, 117))),
                const SizedBox(height: 5),
                Text(
                  event.address,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${DateFormat.MMMd().format(event.datetime)} @ ${DateFormat('hh:mm a').format(event.datetime)}",
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  event.description,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  event.participants.length != event.maxparticipants
                      ? "${event.participants.length}/${event.maxparticipants} participants"
                      : "Participant number reached",
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () => onTap?.call(event, index),
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;

    return Expanded(
      child: ListView.builder(
        physics: scrollable
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: eventList.length,
        itemBuilder: (_, index) {
          Event event = eventList.reversed.toList()[index];
          return Padding(
            padding: EdgeInsets.only(
                bottom: 15, top: 10, left: leftpadding ? 16 : 0),
            child: _listViewItem(event, index),
          );
        },
      ),
    );
  }
}
