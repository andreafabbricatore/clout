import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clout/components/event.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/loading.dart';
import 'package:clout/screens/profilescreen.dart';
import 'package:clout/services/auth.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventDetailScreen extends StatefulWidget {
  EventDetailScreen(
      {super.key,
      required this.event,
      required this.pfp_urls,
      required this.userdocid,
      required this.curruser,
      required this.usernames});
  Event event;
  List pfp_urls;
  String userdocid;
  AppUser curruser;
  List usernames;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  db_conn db = db_conn();
  bool joined = false;
  String? eventid;
  String error = "Error";
  String joinedval = "Join";
  void checkifjoined() async {
    if (widget.event.participants.contains(widget.curruser.username)) {
      if (widget.curruser.username == widget.event.host) {
        setState(() {
          joined = true;
          joinedval = "Delete event";
        });
      } else {
        setState(() {
          joined = true;
          joinedval = "Leave";
        });
      }
    } else {
      if (widget.event.participants.length == widget.event.maxparticipants) {
        setState(() {
          joined = false;
          joinedval = "Full";
        });
      } else {
        setState(() {
          joined = false;
          joinedval = "Join";
        });
      }
    }
  }

  void datagetter() async {
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

  void interactevent(context) async {
    final snackBar = SnackBar(
      content: Text(error),
      duration: Duration(seconds: 2),
    );
    if (!joined && joinedval == "Join") {
      try {
        await db.joinevent(
            widget.event, widget.curruser, widget.userdocid, eventid);
      } catch (e) {
        setState(() {
          error = e.toString();
        });
        await Future.delayed(Duration(milliseconds: 400));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } finally {
        updatescreen(eventid);
      }
    } else if (!joined && joinedval == "Full") {
      print("full");
    } else if (joined && joinedval == "Delete event") {
      try {
        await db.deleteevent(widget.userdocid, eventid, widget.event.host);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => LoadingScreen(
                      uid: context
                          .read<AuthenticationService>()
                          .getuid()
                          .toString(),
                    )),
            (Route<dynamic> route) => false);
      } catch (e) {
        setState(() {
          error = e.toString();
        });
        await Future.delayed(Duration(milliseconds: 400));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        updatescreen(eventid);
      }
    } else {
      try {
        await db.leaveevent(
            widget.event, widget.curruser, widget.userdocid, eventid);
      } catch (e) {
        setState(() {
          error = e.toString();
        });
        await Future.delayed(Duration(seconds: 1));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } finally {
        updatescreen(eventid);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    datagetter();
    checkifjoined();
    super.initState();
  }

  Widget _listviewitem(String username, String pfp_url, String docid) {
    return InkWell(
      onTap: () async {
        AppUser user = await db.getUserFromDocID(docid);
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
      },
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
            style: TextStyle(
                fontSize: 18,
                color: widget.curruser.username == username
                    ? Color.fromARGB(255, 255, 48, 117)
                    : Colors.black),
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
                  child: _listviewitem(widget.usernames[index],
                      widget.pfp_urls[index], widget.event.participants[index]),
                );
              }),
          SizedBox(
            height: screenheight * 0.02,
          ),
          InkWell(
            onTap: () async {
              interactevent(context);
            },
            child: SizedBox(
                height: 50,
                width: screenwidth * 0.5,
                child: Container(
                  child: Center(
                      child: Text(
                    joinedval,
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
