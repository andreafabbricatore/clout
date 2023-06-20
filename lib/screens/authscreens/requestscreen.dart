import 'package:clout/components/loadingwidget.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/authscreens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RequestScreen extends StatefulWidget {
  RequestScreen(
      {super.key,
      required this.curruser,
      required this.analytics,
      required this.requestedby,
      required this.curruserlocation});
  AppUser curruser;
  FirebaseAnalytics analytics;
  List<AppUser> requestedby;
  AppLocation curruserlocation;
  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  db_conn db = db_conn();

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

  Future<void> refresh() async {
    try {
      AppUser updateduser = await db.getUserFromUID(widget.curruser.uid);
      List<AppUser> requestedby = await db.getrequestbylist(widget.curruser);
      setState(() {
        widget.curruser = updateduser;
        widget.requestedby = requestedby;
      });
    } catch (e) {
      displayErrorSnackBar("Could not refresh.");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    Future<void> usernavigate(AppUser user, int index) async {
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

    Future<void> acceptfriendrequest(AppUser user, int index) async {
      try {
        await db.acceptfriendrequest(widget.curruser.uid, user.uid);
        refresh();
      } catch (e) {
        displayErrorSnackBar("Could not accept request, please try again.");
      }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Friend Requests",
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
          child: UserListView(
            userres: widget.requestedby,
            onTap: usernavigate,
            curruser: widget.curruser,
            screenwidth: screenwidth,
            showcloutscore: false,
            showrembutton: false,
            showsendbutton: false,
            showfriendbutton: true,
            acceptRequest: acceptfriendrequest,
          ),
        ));
  }
}
