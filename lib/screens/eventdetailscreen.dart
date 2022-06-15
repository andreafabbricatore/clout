import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clout/components/event.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  EventDetailScreen(
      {super.key,
      required this.event,
      required this.pfp_urls,
      required this.userdocid});
  Event event;
  List pfp_urls;
  String userdocid;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  db_conn db = db_conn();
  bool joined = false;
  late DocumentSnapshot documentSnapshot;
  late String eventid;

  void checkifjoined() async {
    DocumentSnapshot documentSnapshot =
        await db.users.doc(widget.userdocid).get();
    if (widget.event.participants.contains(documentSnapshot['username'])) {
      setState(() {
        joined = true;
      });
    } else {
      setState(() {
        joined = false;
      });
    }
  }

  void datagetter() async {
    documentSnapshot = await db.users.doc(widget.userdocid).get();
    eventid = await db.geteventdocid(widget.event);
  }

  void updatescreen(eventid) async {
    Event updatedevent = await db.getEventfromDocId(eventid);
    List urls = [
      for (String x in updatedevent.participants)
        await db.getUserPFPfromUsername(x)
    ];
    setState(() {
      widget.event = updatedevent;
      widget.pfp_urls = urls;
    });
    checkifjoined();
  }

  @override
  void initState() {
    // TODO: implement initState
    datagetter();
    checkifjoined();
    super.initState();
  }

  Widget _listviewitem(String username, String pfp_url) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
            child: SizedBox(
              height: 30,
              width: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Image.network(
                  pfp_url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Text(
            "@$username",
            style: TextStyle(fontSize: 18),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    print(joined);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context, widget.event);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 255, 48, 117),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(children: [
          SizedBox(
            height: screenheight * 0.3,
            width: screenwidth * 0.7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  widget.event.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Text(
            widget.event.title,
            style: TextStyle(
                fontSize: 40,
                color: Colors.black,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: screenheight * 0.005,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.event.interest,
                style: TextStyle(
                    fontSize: 25,
                    color: Color.fromARGB(255, 255, 48, 117),
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  "@${widget.event.host}",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 255, 48, 117),
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Text(
            "At ${widget.event.location}, ${DateFormat.MMMd().format(widget.event.datetime)} @ ${DateFormat('hh:mm a').format(widget.event.datetime)}",
            style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Text(
            widget.event.description,
            style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Text(
            widget.event.participants.length != widget.event.maxparticipants
                ? "${widget.event.participants.length}/${widget.event.maxparticipants} participants"
                : "Participant number reached",
            style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: screenheight * 0.01,
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: widget.event.participants.length,
              itemBuilder: (_, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                  child: _listviewitem(
                      widget.event.participants[index], widget.pfp_urls[index]),
                );
              }),
          SizedBox(
            height: screenheight * 0.02,
          ),
          InkWell(
            onTap: () async {
              if (!joined) {
                await db.joinevent(
                    widget.event, documentSnapshot, widget.userdocid, eventid);
                updatescreen(eventid);
              } else {
                await db.leaveevent(
                    widget.event, documentSnapshot, widget.userdocid, eventid);
                updatescreen(eventid);
              }
            },
            child: SizedBox(
                height: 50,
                width: screenwidth * 0.5,
                child: Container(
                  child: Center(
                      child: Text(
                    joined ? "Leave" : "Join",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 48, 117),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                )),
          )
        ]),
      ),
    );
  }
}
