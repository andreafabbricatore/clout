import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:clout/defs/location.dart';
import 'package:clout/screens/unauthscreens/unauthcreateeventscreen.dart';
import 'package:clout/screens/unauthscreens/unauthfavscreen.dart';
import 'package:clout/screens/unauthscreens/unauthhomescreen.dart';
import 'package:clout/screens/unauthscreens/unauthprofilescreen.dart';
import 'package:clout/screens/unauthscreens/unauthsearchscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnAuthMainScreen extends StatefulWidget {
  AppLocation curruserlocation;
  bool justloaded;
  FirebaseAnalytics analytics;
  UnAuthMainScreen(
      {Key? key,
      required this.curruserlocation,
      required this.justloaded,
      required this.analytics})
      : super(key: key);
  @override
  State<UnAuthMainScreen> createState() => _UnAuthMainScreenState();
}

class _UnAuthMainScreenState extends State<UnAuthMainScreen> {
  int _index = 0;
  List page = [];
  PendingDynamicLinkData? initialLink;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  db_conn db = db_conn();

  void parampasser() {
    page = [
      UnAuthHomeScreen(
        curruserlocation: widget.curruserlocation,
        analytics: widget.analytics,
      ),
      UnAuthSearchScreen(
        curruserlocation: widget.curruserlocation,
        analytics: widget.analytics,
      ),
      UnAuthCreateEventScreen(
        allowbackarrow: false,
        startinterest: "Sports",
        analytics: widget.analytics,
      ),
      UnAuthFavScreen(analytics: widget.analytics),
      UnAuthProfileScreen(analytics: widget.analytics, visit: false)
    ];
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    // Check initial link if app was in cold state (terminated)
    try {
      final appLink = await _appLinks.getInitialAppLink();
      if (appLink != null) {
        //print('getInitialAppLink: $appLink');
        openAppLink(appLink);
      }

      // Handle link when app is in warm state (front or background)
      _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
        //print('onAppLink: $uri');
        openAppLink(uri);
      });
    } catch (e) {
      //nothing
    }
  }

  void openAppLink(Uri uri) async {
    try {
      List<String> splitlink = uri.toString().split("/");
      String id = splitlink.last;
      if (splitlink[splitlink.length - 2] == "event") {
      } else if (splitlink[splitlink.length - 2] == "user") {}
    } catch (e) {}
  }

  @override
  void initState() {
    initDeepLinks();
    parampasser();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: page[_index],
        bottomNavigationBar: BottomNavyBar(
          items: [
            BottomNavyBarItem(
              icon: const Icon(
                Icons.home,
              ),
              title: const Text(
                "Home",
                textScaleFactor: 1.0,
              ),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey,
            ),
            BottomNavyBarItem(
              icon: const Icon(
                Icons.search,
              ),
              title: const Text(
                "Search",
                textScaleFactor: 1.0,
              ),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey,
            ),
            BottomNavyBarItem(
              icon: const Icon(
                Icons.add,
              ),
              title: const Text(
                "Create",
                textScaleFactor: 1.0,
              ),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey,
            ),
            BottomNavyBarItem(
              icon: const Icon(
                Icons.bookmark,
              ),
              title: const Text(
                "Favorites",
                textScaleFactor: 1.0,
              ),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey,
            ),
            BottomNavyBarItem(
              icon: const Icon(CupertinoIcons.person_crop_circle),
              title: const Text(
                "Profile",
                textScaleFactor: 1.0,
              ),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey,
            )
          ],
          onItemSelected: (newIndex) {
            if (newIndex == 0) {
              parampasser();
            }
            setState(() => _index = newIndex);
          },
          selectedIndex: _index,
          showElevation: false,
          iconSize: 33,
          containerHeight: 60,
        ));
  }
}
