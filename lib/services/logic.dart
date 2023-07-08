import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/authscreens/eventdetailscreen.dart';
import 'package:clout/screens/authscreens/profilescreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class applogic {
  void displayErrorSnackBar(String error, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(
        error,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color.fromARGB(230, 255, 48, 117),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: false,
      closeIconColor: Colors.white,
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void usernavigate(FirebaseAnalytics analytics, AppLocation curruserlocation,
      AppUser curruser, AppUser user, BuildContext context) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (_) => ProfileScreen(
                  user: user,
                  curruser: curruser,
                  visit: true,
                  curruserlocation: curruserlocation,
                  analytics: analytics,
                ),
            settings: RouteSettings(name: "ProfileScreen")));
  }

  void goeventdetailscreen(
      FirebaseAnalytics analytics,
      AppLocation curruserlocation,
      AppUser curruser,
      Event chosenEvent,
      List<AppUser> participants,
      BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EventDetailScreen(
                  event: chosenEvent,
                  curruser: curruser,
                  participants: participants,
                  curruserlocation: curruserlocation,
                  analytics: analytics,
                ),
            settings: RouteSettings(name: "EventDetailScreen")));
  }
}
