import 'package:clout/components/event.dart';
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
  void appinit() async {
    try {
      docid = await db.getUserDocID(widget.uid);
      interests = await db.getUserInterests(docid);
      eventlist = await db.getEvents();
      interesteventlist = await db.getInterestEvents(interests);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => MainScreen(
            docid: docid,
            interests: interests,
            eventlist: eventlist,
            interesteventlist: interesteventlist,
          ),
        ),
      );
    } catch (e) {
      print("error");
      appinit();
    }
  }

  @override
  void initState() {
    appinit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: SpinKitFadingFour(
        color: Color.fromARGB(255, 255, 48, 117),
      )),
    );
  }
}
