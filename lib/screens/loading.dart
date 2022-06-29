import 'package:clout/components/event.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/authscreen.dart';
import 'package:clout/screens/mainscreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key? key, required this.uid}) : super(key: key);
  final String uid;
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  db_conn db = db_conn();
  String docid = "";
  List interests = [];
  List<Event> eventlist = [];
  List<Event> interesteventlist = [];
  List allinterests = [
    "Sports",
    "Nature",
    "Music",
    "Dance",
    "Movies",
    "Acting",
    "Singing",
    "Drinking",
    "Food",
    "Art"
  ];
  void appinit() async {
    docid = await db.getUserDocID(widget.uid);
    AppUser curruser = await db.getUserFromDocID(docid);
    interests = curruser.interests;
    eventlist = await db.getEvents(interests);
    interesteventlist = await db.getInterestEvents(interests);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => MainScreen(
            interests: interests,
            eventlist: eventlist,
            interesteventlist: interesteventlist,
            curruser: curruser),
      ),
    );
  }

  @override
  void initState() {
    appinit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Clout",
              style: TextStyle(
                  color: Color.fromARGB(255, 255, 48, 117),
                  fontWeight: FontWeight.bold,
                  fontSize: 60),
            ),
            Text(
              "Go Out",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 40),
            ),
            SizedBox(
              height: screenheight * 0.1,
            ),
            SpinKitFadingFour(
              color: Color.fromARGB(255, 255, 48, 117),
            ),
          ],
        ),
      ),
    );
  }
}
