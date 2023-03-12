import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/notificationslistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/notification.dart';
import 'package:clout/screens/authscreens/eventdetailscreen.dart';
import 'package:clout/screens/authscreens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen(
      {Key? key,
      required this.curruser,
      required this.curruserlocation,
      required this.analytics})
      : super(key: key);
  AppUser curruser;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  db_conn db = db_conn();
  List<NotificationElement> notis = [];

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

  void setup() {
    notis = [];
    for (int i = 0; i < widget.curruser.notifications.length; i++) {
      notis.insert(
          0, NotificationElement.fromJson(widget.curruser.notifications[i]));
    }
    try {
      db.resetnotificationcounter(widget.curruser.uid);
    } catch (e) {
      displayErrorSnackBar("Could not clear notifications");
    }
  }

  Future<void> refresh() async {
    await updatecurruser();
    setup();
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

  Future<void> updatecurruser() async {
    try {
      AppUser updateduser = await db.getUserFromUID(widget.curruser.uid);
      setState(() {
        widget.curruser = updateduser;
      });
    } catch (e) {
      displayErrorSnackBar("Could not refresh user");
    }
  }

  Future interactfav(Event event) async {
    try {
      if (widget.curruser.favorites.contains(event.docid)) {
        await db.remFromFav(widget.curruser.uid, event.docid);
        await widget.analytics.logEvent(name: "rem_from_fav", parameters: {
          "interest": event.interest,
          "inviteonly": event.isinviteonly.toString(),
          "maxparticipants": event.maxparticipants,
          "currentparticipants": event.participants.length
        });
      } else {
        await db.addToFav(widget.curruser.uid, event.docid);
        await widget.analytics.logEvent(name: "add_to_fav", parameters: {
          "interest": event.interest,
          "inviteonly": event.isinviteonly.toString(),
          "maxparticipants": event.maxparticipants,
          "currentparticipants": event.participants.length
        });
      }
    } catch (e) {
      displayErrorSnackBar("Could not update favorites");
    } finally {
      updatecurruser();
    }
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    Future<void> usernavigate(String uid, int index) async {
      try {
        AppUser user = await db.getUserFromUID(uid);
        gotoprofilescreen(user);
      } catch (e) {
        displayErrorSnackBar("Could not display user");
      }
    }

    Future<void> eventnavigate(String eventid, int index) async {
      try {
        Event event = await db.getEventfromDocId(eventid);
        List<AppUser> participants = await db.geteventparticipantslist(event);
        await Future.delayed(const Duration(milliseconds: 50));
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EventDetailScreen(
                      event: event,
                      curruser: widget.curruser,
                      participants: participants,
                      interactfav: interactfav,
                      curruserlocation: widget.curruserlocation,
                      analytics: widget.analytics,
                    ),
                settings: RouteSettings(name: "EventDetailScreen")));
      } catch (e) {
        displayErrorSnackBar("Could not display event");
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Notifications",
          textScaleFactor: 1.0,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Theme.of(context).primaryColor,
        child: Column(children: [
          NotificationsListView(
            notificationlist: notis,
            screenwidth: screenwidth,
            onTapUsername: usernavigate,
            onTapEvent: eventnavigate,
          )
        ]),
      ),
    );
  }
}
