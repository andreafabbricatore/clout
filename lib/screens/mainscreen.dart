import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/createeventscreen.dart';
import 'package:clout/screens/deeplinkeventdetailscreen.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/screens/favscreen.dart';
import 'package:clout/screens/homescreen.dart';
import 'package:clout/screens/profilescreen.dart';
import 'package:clout/screens/searchscreen.dart';
import 'package:clout/services/db.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';

class MainScreen extends StatefulWidget {
  List interests;
  List<Event> eventlist;
  List<Event> interesteventlist;
  AppUser curruser;
  AppLocation userlocation;
  MainScreen(
      {Key? key,
      required this.interests,
      required this.eventlist,
      required this.interesteventlist,
      required this.curruser,
      required this.userlocation})
      : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  List page = [];
  PendingDynamicLinkData? initialLink;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  String deeplink = "";
  db_conn db = db_conn();

  void parampasser(bool firstsetup) {
    page = [
      HomeScreen(
          curruser: widget.curruser,
          interests: widget.interests,
          eventlist: widget.eventlist,
          interestevents: widget.interesteventlist,
          firstsetup: firstsetup,
          userlocation: widget.userlocation),
      SearchScreen(
          curruser: widget.curruser, userlocation: widget.userlocation),
      CreateEventScreen(
        curruser: widget.curruser,
      ),
      FavScreen(
        curruser: widget.curruser,
      ),
      ProfileScreen(
        user: widget.curruser,
        curruser: widget.curruser,
        visit: false,
        interests: widget.interests,
      )
    ];
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    // Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null) {
      print('getInitialAppLink: $appLink');
      openAppLink(appLink);
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) async {
    print(uri.toString().split("/").last);
    //print(uri.queryParameters['link']);
    try {
      Event chosenEvent =
          await db.getEventfromDocId(uri.toString().split("/").last);
      List<AppUser> participants = [
        for (String x in chosenEvent.participants) await db.getUserFromDocID(x)
      ];
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DeepLinkEventDetailScreen(
                    event: chosenEvent,
                    curruser: widget.curruser,
                    participants: participants,
                  )));
    } catch (e) {
      print("error with link");
    }
  }

  @override
  void initState() {
    initDeepLinks();
    parampasser(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: page[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (newIndex) {
          if (newIndex == 0) {
            parampasser(false);
          }
          setState(() => _index = newIndex);
        },
        currentIndex: _index,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        unselectedItemColor: Colors.grey,
        selectedItemColor: const Color.fromARGB(255, 255, 48, 117),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
              ),
              label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add,
              ),
              label: "Create"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.bookmark,
              ),
              label: "Favorites"),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_crop_circle),
            label: "Profile",
          )
        ],
        backgroundColor: Colors.white,
      ),
    );
  }
}
