import 'package:clout/components/event.dart';
import 'package:clout/components/user.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventListView extends StatelessWidget {
  final bool isHorizontal;
  final Function(Event event, int index)? onTap;
  final List<Event> eventList;
  bool scrollable;
  bool leftpadding;
  AppUser curruser;
  final Function(Event event) interactfav;
  EventListView(
      {Key? key,
      this.isHorizontal = true,
      this.onTap,
      required this.eventList,
      required this.scrollable,
      required this.leftpadding,
      required this.curruser,
      required this.interactfav})
      : super(key: key);

  db_conn db = db_conn();
  Widget _eventImage(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.network(
        image,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _listViewItem(
    Event event,
    int index,
  ) {
    Widget widget;
    widget = isHorizontal == true
        ? Column(
            children: [
              Hero(tag: index, child: _eventImage(event.image)),
              const SizedBox(height: 10),
              Text(event.title,
                  style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              Text(event.interest,
                  style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 48, 117))),
              Text(
                "${event.address}",
                style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "${DateFormat.MMMd().format(event.datetime)} @ ${DateFormat('hh:mm a').format(event.datetime)}",
                style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        : Row(
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
                          Text(event.title,
                              style: const TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          InkWell(
                            onTap: () async {
                              await interactfav(event);
                              print("Done");
                            },
                            child: Icon(curruser.favorites.contains(event.docid)
                                ? Icons.bookmark
                                : Icons.bookmark_border),
                          ),
                        ],
                      ),
                      Text(event.interest,
                          style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 48, 117))),
                      const SizedBox(height: 5),
                      Text(
                        "${event.address}",
                        style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${DateFormat.MMMd().format(event.datetime)} @ ${DateFormat('hh:mm a').format(event.datetime)}",
                        style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        event.description,
                        style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        event.participants.length != event.maxparticipants
                            ? "${event.participants.length}/${event.maxparticipants} participants"
                            : "Participant number reached",
                        style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
            ],
          );

    return GestureDetector(
      onTap: () => onTap?.call(event, index),
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    return isHorizontal == true
        ? SizedBox(
            height: screenheight * 0.28,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: eventList.length,
              itemBuilder: (_, index) {
                Event event = eventList[index];
                return _listViewItem(event, index);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Padding(
                  padding: EdgeInsets.only(left: 10),
                );
              },
            ),
          )
        : Expanded(
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
