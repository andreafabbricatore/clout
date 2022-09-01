import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/createeventscreen.dart';
import 'package:clout/screens/deeplinkeventdetailscreen.dart';
import 'package:clout/screens/favscreen.dart';
import 'package:clout/screens/homescreen.dart';
import 'package:clout/screens/profilescreen.dart';
import 'package:clout/screens/searchscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        allowbackarrow: false,
        startinterest: "Sports",
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

  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  void godeeplinkeventdetailscreen(
      Event chosenEvent, List<AppUser> participants) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DeepLinkEventDetailScreen(
                  event: chosenEvent,
                  curruser: widget.curruser,
                  participants: participants,
                )));
  }

  void openAppLink(Uri uri) async {
    //print(uri.toString().split("/").last);
    //print(uri.queryParameters['link']);
    //String docid =
    //uri.toString().replaceAll("https://outwithclout.com/?link=", "");
    //docid.replaceAll("&amv=0&efr=0", "");
    try {
      Event chosenEvent =
          await db.getEventfromDocId(uri.toString().split("/").last);
      List<AppUser> participants = [
        for (String x in chosenEvent.participants) await db.getUserFromDocID(x)
      ];
      godeeplinkeventdetailscreen(chosenEvent, participants);
    } catch (e) {
      //nothing
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
        bottomNavigationBar: BottomNavyBar(
          items: [
            BottomNavyBarItem(
              icon: const Icon(
                Icons.home,
              ),
              title: const Text("Home"),
              activeColor: const Color.fromARGB(255, 255, 48, 117),
              inactiveColor: Colors.grey,
            ),
            BottomNavyBarItem(
              icon: const Icon(
                Icons.search,
              ),
              title: const Text("Search"),
              activeColor: const Color.fromARGB(255, 255, 48, 117),
              inactiveColor: Colors.grey,
            ),
            BottomNavyBarItem(
              icon: const Icon(
                Icons.add,
              ),
              title: const Text("Create"),
              activeColor: const Color.fromARGB(255, 255, 48, 117),
              inactiveColor: Colors.grey,
            ),
            BottomNavyBarItem(
              icon: const Icon(
                Icons.bookmark,
              ),
              title: const Text("Favorites"),
              activeColor: const Color.fromARGB(255, 255, 48, 117),
              inactiveColor: Colors.grey,
            ),
            BottomNavyBarItem(
              icon: const Icon(CupertinoIcons.person_crop_circle),
              title: const Text("Profile"),
              activeColor: const Color.fromARGB(255, 255, 48, 117),
              inactiveColor: Colors.grey,
            )
          ],
          onItemSelected: (newIndex) {
            if (newIndex == 0) {
              parampasser(false);
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
