import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:clout/components/chat.dart';
import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/authscreens/chatroomscreen.dart';
import 'package:clout/screens/authscreens/cloutscorescreen.dart';
import 'package:clout/screens/authscreens/createeventscreen.dart';
import 'package:clout/screens/authscreens/deeplinkeventdetailscreen.dart';
import 'package:clout/screens/authscreens/favscreen.dart';
import 'package:clout/screens/authscreens/homescreen.dart';
import 'package:clout/screens/authscreens/homescreenholder.dart';
import 'package:clout/screens/authscreens/profilescreen.dart';
import 'package:clout/screens/authscreens/searchscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MainScreen extends StatefulWidget {
  AppUser curruser;
  AppLocation curruserlocation;
  bool justloaded;
  FirebaseAnalytics analytics;
  MainScreen(
      {Key? key,
      required this.curruser,
      required this.curruserlocation,
      required this.justloaded,
      required this.analytics})
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
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  late bool canvibrate;

  Future<void> requestNotisPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      db.saveDeviceToken(widget.curruser);
    }
  }

  void parampasser() {
    page = [
      HomeScreenHolder(
        curruser: widget.curruser,
        curruserlocation: widget.curruserlocation,
        justloaded: widget.justloaded,
        analytics: widget.analytics,
      ),
      CloutScoreScreen(
        curruser: widget.curruser,
        curruserlocation: widget.curruserlocation,
        analytics: widget.analytics,
        showleading: false,
      ),
      CreateEventScreen(
        curruser: widget.curruser,
        allowbackarrow: false,
        startinterest: "Sports",
        analytics: widget.analytics,
      ),
      FavScreen(
          curruser: widget.curruser,
          curruserlocation: widget.curruserlocation,
          analytics: widget.analytics),
      ProfileScreen(
        user: widget.curruser,
        curruser: widget.curruser,
        visit: false,
        curruserlocation: widget.curruserlocation,
        analytics: widget.analytics,
      )
    ];
  }

  void displayErrorSnackBar(
    String error,
  ) {
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
                  curruserlocation: widget.curruserlocation,
                  analytics: widget.analytics,
                ),
            settings: RouteSettings(name: "DeepLinkEventDetailScreen")));
  }

  void gochatroomscreen(Chat chat) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
                  chatinfo: chat,
                  curruser: widget.curruser,
                  curruserlocation: widget.curruserlocation,
                  analytics: widget.analytics,
                ),
            settings: RouteSettings(name: "ChatRoomScreen")));
  }

  void gotoprofilescreen(AppUser user) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (_) => ProfileScreen(
                  user: user,
                  curruser: widget.curruser,
                  visit: true,
                  curruserlocation: widget.curruserlocation,
                  analytics: widget.analytics,
                ),
            settings: RouteSettings(name: "ProfileScreen")));
  }

  void openAppLink(Uri uri) async {
    try {
      List<String> splitlink = uri.toString().split("/");
      String id = splitlink.last;
      if (splitlink[splitlink.length - 2] == "event") {
        Event chosenEvent = await db.getEventfromDocId(id);
        List<AppUser> participants =
            await db.geteventparticipantslist(chosenEvent);
        godeeplinkeventdetailscreen(chosenEvent, participants);
      } else if (splitlink[splitlink.length - 2] == "user") {
        AppUser user = await db.getUserFromUID(id);
        gotoprofilescreen(user);
      } else if (splitlink[splitlink.length - 2] == "referral") {
        try {
          Duration signupdiff =
              DateTime.now().difference(widget.curruser.donesignuptime);
          if (signupdiff.inMinutes <= 15) {
            await db.referralcloutinc(widget.curruser.uid, id).catchError((e) {
              throw Exception();
            });
            displayErrorSnackBar(
                "Succesfully referred! Clout score has been increased!");
          }
        } catch (e) {}
      }
    } catch (e) {}
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async {
    if (message.data['type'] == "chat") {
      try {
        Chat chat = await db.getChatfromDocId(message.data['chatid']);
        gochatroomscreen(chat);
      } catch (e) {
        displayErrorSnackBar("Could not display chat");
      }
    } else if (message.data["type"] == "eventcreated") {
      try {
        Event event = await db.getEventfromDocId(message.data["eventid"]);
        List<AppUser> participants = await db.geteventparticipantslist(event);
        godeeplinkeventdetailscreen(event, participants);
      } catch (e) {
        displayErrorSnackBar("Could not display event");
      }
    } else if (message.data["type"] == "joined") {
      try {
        Event event = await db.getEventfromDocId(message.data["eventid"]);
        List<AppUser> participants = await db.geteventparticipantslist(event);
        await Future.delayed(const Duration(milliseconds: 50));
        godeeplinkeventdetailscreen(event, participants);
      } catch (e) {
        displayErrorSnackBar("Could not display event");
      }
    } else if (message.data["type"] == "modified") {
      try {
        Event event = await db.getEventfromDocId(message.data["eventid"]);
        List<AppUser> participants = await db.geteventparticipantslist(event);
        godeeplinkeventdetailscreen(event, participants);
      } catch (e) {
        displayErrorSnackBar("Could not display event");
      }
    } else if (message.data["type"] == "followed") {
      try {
        AppUser user = await db.getUserFromUID(message.data["userid"]);
        gotoprofilescreen(user);
      } catch (e) {
        displayErrorSnackBar("Could not display user");
      }
    } else if (message.data["type"] == "kicked") {
      try {
        Event event = await db.getEventfromDocId(message.data["eventid"]);
        List<AppUser> participants = await db.geteventparticipantslist(event);
        godeeplinkeventdetailscreen(event, participants);
      } catch (e) {
        displayErrorSnackBar("Could not display event");
      }
    } else if (message.data["type"] == "reminder") {
      try {
        Event event = await db.getEventfromDocId(message.data["eventid"]);
        List<AppUser> participants = await db.geteventparticipantslist(event);
        godeeplinkeventdetailscreen(event, participants);
      } catch (e) {
        displayErrorSnackBar("Could not display event");
      }
    }
  }

  void initMessaging() {
    var androiInit =
        const AndroidInitializationSettings('@mipmap/ic_launcher'); //for logo
    var iosInit = const DarwinInitializationSettings();
    var initSetting = InitializationSettings(android: androiInit, iOS: iosInit);
    var fltNotification = FlutterLocalNotificationsPlugin();
    fltNotification.initialize(initSetting);
    var androidDetails = const AndroidNotificationDetails('1', 'channelName',
        channelDescription: 'channel Description');
    var iosDetails = const DarwinNotificationDetails();
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        fltNotification.show(notification.hashCode, notification.title,
            notification.body, generalNotificationDetails);
      }
    });
  }

  Future<void> canVibrate() async {
    canvibrate = await Vibrate.canVibrate;
  }

  @override
  void initState() {
    requestNotisPermission();
    initMessaging();
    setupInteractedMessage();
    initDeepLinks();
    parampasser();
    canVibrate();
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
                Icons.people_outline_sharp,
              ),
              title: const Text(
                "Score",
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
                Icons.bookmark_outlined,
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
              setState(() {
                widget.justloaded = false;
              });
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
