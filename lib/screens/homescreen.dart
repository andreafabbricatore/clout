import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/services/auth.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  String docid;
  List interests = [];
  List<Event> eventlist = [];
  List<Event> interestevents = [];
  HomeScreen(
      {Key? key,
      required this.docid,
      required this.interests,
      required this.eventlist,
      required this.interestevents})
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

  void getEventsList() async {
    List<Event> events = await db.getEvents();
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

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: const Icon(Icons.menu, color: Colors.grey),
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            )),
      ),
    );
  }

  @override
  void initState() {
    generaleventlist = widget.eventlist;
    userdocid = widget.docid;
    userinterests = widget.interests;
    interesteventlist = widget.interestevents;
    if (generaleventlist.isEmpty) {
      getEventsList();
    }
    if (interesteventlist.isEmpty) {
      getInterestEventsList(userinterests);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    Future<Widget?> _navigate(Event event, int index) {
      return Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(seconds: 1),
          pageBuilder: (_, __, ___) => EventDetailScreen(),
        ),
      );
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
      body: Padding(
        padding: EdgeInsets.all(screenheight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(),
            InkWell(
              onTap: () async {
                db.createevent(
                    "Baking",
                    "Felt hungry and wanted to make cakes with people",
                    "Food",
                    "Duomo Milano",
                    "andreafabb11",
                    DateTime.now(),
                    5,
                    ["andreafabb11"]);
              },
              child: Text(
                "Suggested",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: screenheight * 0.02),
            EventListView(
              eventList: generaleventlist,
              onTap: _navigate,
            ),
            Text("Popular",
                style: TextStyle(
                    fontSize: 22,
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
    );
  }
}
