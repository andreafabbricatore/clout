import 'package:clout/screens/unauthscreens/unauthcreateeventscreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class UnAuthnoEventsBox extends StatelessWidget {
  UnAuthnoEventsBox(
      {super.key,
      required this.screenheight,
      required this.screenwidth,
      required this.interest,
      required this.allcolor,
      required this.analytics});
  String interest;
  final double screenheight;
  final double screenwidth;
  Color allcolor;
  FirebaseAnalytics analytics;

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
          textScaler: TextScaler.linear(1.0),
        ),
        SizedBox(
          height: screenheight * 0.03,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => UnAuthCreateEventScreen(
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

class UnAuthdelayedNoEventsBox extends StatelessWidget {
  UnAuthdelayedNoEventsBox(
      {super.key,
      required this.screenheight,
      required this.screenwidth,
      required this.interest,
      required this.allcolor,
      required this.analytics,
      required this.blank});
  String interest;
  final double screenheight;
  final double screenwidth;
  Color allcolor;
  FirebaseAnalytics analytics;
  bool blank;

  @override
  Widget build(BuildContext context) {
    return blank
        ? Container()
        : Column(
            children: [
              SizedBox(
                height: screenheight * 0.1,
              ),
              Text(
                "No Events Nearby :(",
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 20, color: allcolor),
                textScaler: TextScaler.linear(1.0),
              ),
              SizedBox(
                height: screenheight * 0.03,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            UnAuthCreateEventScreen(
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
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Create Event",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: allcolor),
                        ),
                      ]),
                ),
              ),
            ],
          );
  }
}
