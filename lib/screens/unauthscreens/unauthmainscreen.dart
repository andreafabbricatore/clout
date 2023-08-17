import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:clout/defs/event.dart';
import 'package:clout/defs/location.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/screens/unauthscreens/unauthcreateeventscreen.dart';
import 'package:clout/screens/unauthscreens/unauthfavscreen.dart';
import 'package:clout/screens/unauthscreens/unauthhomescreen.dart';
import 'package:clout/screens/unauthscreens/unauthprofilescreen.dart';
import 'package:clout/screens/unauthscreens/unauthsearchscreen.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
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
  applogic logic = applogic();

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
        Event event = await db.getEventfromDocId(id);
        List<AppUser> participants = await db.geteventparticipantslist(event);
        logic.gounautheventdetailscreen(widget.analytics,
            widget.curruserlocation, event, participants, context);
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
        body: page[_index], bottomNavigationBar: CustomBottomBar(context));
  }

  Padding CustomBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 8.0, 40.0, 20.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(500),
          color: const Color.fromARGB(245, 255, 48, 117),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          GestureDetector(
            onTap: () {
              setState(() {
                widget.justloaded = false;
              });
              parampasser();
              setState(() => _index = 0);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                _index == 0
                    ? Center(
                        child: Container(
                          width: 15,
                          height: 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              parampasser();
              setState(() => _index = 1);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                ),
                _index == 1
                    ? Center(
                        child: Container(
                          width: 15,
                          height: 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              parampasser();
              setState(() => _index = 2);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                _index == 2
                    ? Center(
                        child: Container(
                          width: 15,
                          height: 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              parampasser();
              setState(() => _index = 3);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bookmark_outlined,
                  color: Colors.white,
                ),
                _index == 3
                    ? Center(
                        child: Container(
                          width: 15,
                          height: 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              parampasser();
              setState(() => _index = 4);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.person_crop_circle,
                  color: Colors.white,
                ),
                _index == 4
                    ? Center(
                        child: Container(
                          width: 15,
                          height: 2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
