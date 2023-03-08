import 'package:clout/components/user.dart';
import 'package:clout/screens/createeventscreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class noEventsBox extends StatelessWidget {
  noEventsBox(
      {super.key,
      required this.screenheight,
      required this.curruser,
      required this.screenwidth,
      required this.interest,
      required this.analytics,
      required this.allcolor});
  String interest;
  AppUser curruser;
  FirebaseAnalytics analytics;
  final double screenheight;
  final double screenwidth;
  Color allcolor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: screenheight * 0.1,
        ),
        Text(
          "No Events Nearby :(",
          style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 20, color: allcolor),
          textScaleFactor: 1.0,
        ),
        SizedBox(
          height: screenheight * 0.03,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => CreateEventScreen(
                        curruser: curruser,
                        allowbackarrow: true,
                        startinterest: interest,
                        analytics: analytics,
                      ),
                  settings: RouteSettings(name: "CreateEventScreen")),
            );
          },
          child: Container(
            height: screenwidth * 0.13,
            width: screenwidth * 0.6,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: allcolor),
                borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                "Create Event",
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: allcolor),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
