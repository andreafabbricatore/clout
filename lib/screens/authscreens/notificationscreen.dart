import 'package:clout/defs/event.dart';
import 'package:clout/components/loadingwidget.dart';
import 'package:clout/defs/location.dart';
import 'package:clout/models/notificationslistview.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/defs/notification.dart';
import 'package:clout/screens/authscreens/eventdetailscreen.dart';
import 'package:clout/screens/authscreens/profilescreen.dart';
import 'package:clout/screens/authscreens/requestscreen.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
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
  applogic logic = applogic();

  void setup() {
    notis = [];
    for (int i = 0; i < widget.curruser.notifications.length; i++) {
      notis.insert(
          0, NotificationElement.fromJson(widget.curruser.notifications[i]));
    }
    try {
      db.resetnotificationcounter(widget.curruser.uid);
    } catch (e) {
      logic.displayErrorSnackBar("Could not clear notifications", context);
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

  Future<void> gotorequestscreen() async {
    try {
      await updatecurruser();
      List<AppUser> requestedby = await db.getrequestbylist(widget.curruser);
      await Future.delayed(const Duration(milliseconds: 50));
      await Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => RequestScreen(
                    curruser: widget.curruser,
                    analytics: widget.analytics,
                    requestedby: requestedby,
                    curruserlocation: widget.curruserlocation,
                  ),
              settings: const RouteSettings(name: "RequestScreen")));
    } catch (e) {
      logic.displayErrorSnackBar(
          "Could not see friend requests. Please try again.", context);
    }
  }

  Future<void> updatecurruser() async {
    try {
      AppUser updateduser = await db.getUserFromUID(widget.curruser.uid);
      setState(() {
        widget.curruser = updateduser;
      });
    } catch (e) {
      logic.displayErrorSnackBar("Could not refresh user", context);
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
      logic.displayErrorSnackBar("Could not update favorites", context);
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
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> usernavigate(String uid, int index) async {
      try {
        AppUser user = await db.getUserFromUID(uid);
        gotoprofilescreen(user);
      } catch (e) {
        logic.displayErrorSnackBar("Could not display user", context);
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
                      curruserlocation: widget.curruserlocation,
                      analytics: widget.analytics,
                    ),
                settings: RouteSettings(name: "EventDetailScreen")));
      } catch (e) {
        logic.displayErrorSnackBar("Could not display event", context);
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
      body: CustomRefreshIndicator(
        onRefresh: refresh,
        builder: (context, child, controller) {
          return LoadingWidget(
            screenheight: screenheight,
            screenwidth: screenwidth,
            controller: controller,
            child: child,
          );
        },
        child: Column(children: [
          NotificationsListView(
            notificationlist: notis,
            screenwidth: screenwidth,
            onTapUsername: usernavigate,
            onTapEvent: eventnavigate,
            gotoRequestScreen: gotorequestscreen,
          )
        ]),
      ),
    );
  }
}
