import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/services/auth.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class HomeScreen extends StatefulWidget {
  String docid;
  List interests = [];
  List<Event> eventlist = [];
  List<Event> interestevents = [];
  bool updatehome;
  AppUser curruser;
  HomeScreen(
      {Key? key,
      required this.docid,
      required this.interests,
      required this.eventlist,
      required this.interestevents,
      required this.updatehome,
      required this.curruser})
      : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  db_conn db = db_conn();
  String userdocid = "";
  List<Event> generaleventlist = [];
  List<Event> interesteventlist = [];
  List userinterests = [];

  void getEventsList(interests) async {
    List<Event> events = await db.getEvents(interests);
    setState(() {
      generaleventlist = events;
    });
  }

  void getInterestEventsList(interests) async {
    List<Event> interestevents = await db.getInterestEvents(interests);
    setState(() {
      interesteventlist = interestevents;
    });
  }

  Future<void> refreshevents() async {
    print("refreshed");
    List<Event> events = await db.getEvents(userinterests);
    List<Event> interestevents = await db.getInterestEvents(userinterests);
    setState(() {
      generaleventlist = events;
      interesteventlist = interestevents;
    });
  }

  @override
  void initState() {
    generaleventlist = widget.eventlist;
    userdocid = widget.docid;
    userinterests = widget.interests;
    interesteventlist = widget.interestevents;
    if (generaleventlist.isEmpty) {
      getEventsList(userinterests);
    }
    if (interesteventlist.isEmpty) {
      getInterestEventsList(userinterests);
    }
    if (widget.updatehome) {
      refreshevents();
    }
    super.initState();
  }

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
                  userdocid: widget.docid,
                  curruser: widget.curruser)));
      try {
        int index1 = generaleventlist.indexWhere((element) => element == event);
        setState(() {
          generaleventlist[index1] = newevent;
        });
      } catch (e) {
        print("not general");
      }

      try {
        int index2 =
            interesteventlist.indexWhere((element) => element == event);
        setState(() {
          interesteventlist[index2] = newevent;
        });
      } catch (e) {
        print("not interest");
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Clout",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        color: Color.fromARGB(255, 255, 48, 117),
        backgroundColor: Colors.white,
        onRefresh: refreshevents,
        child: SizedBox(
          child: SingleChildScrollView(
            child: SizedBox(
              height: screenheight,
              width: screenwidth,
              child: Padding(
                padding: EdgeInsets.all(screenheight * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        await db.createevent(
                            "HIIT",
                            "Working out till we can",
                            "Sports",
                            "McFit",
                            widget.curruser.username,
                            DateTime(2022, 9, 7, 17, 30),
                            3,
                            [widget.curruser.username],
                            widget.curruser,
                            widget.docid);
                      },
                      child: Text(
                        "Suggested",
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(height: screenheight * 0.02),
                    EventListView(
                      eventList: interesteventlist,
                      onTap: _navigate,
                    ),
                    Text("Popular",
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600)),
                    EventListView(
                      isHorizontal: false,
                      eventList: generaleventlist,
                      onTap: _navigate,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
