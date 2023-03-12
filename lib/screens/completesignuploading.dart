import 'dart:async';

import 'package:clout/components/user.dart';
import 'package:clout/screens/authscreen.dart';
import 'package:clout/screens/emailverificationscreen.dart';
import 'package:clout/screens/preauthscreen.dart';
import 'package:clout/screens/signupscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CompleteSignUpLoading extends StatefulWidget {
  CompleteSignUpLoading({Key? key, required this.uid, required this.analytics})
      : super(key: key);
  String uid;
  FirebaseAnalytics analytics;
  @override
  State<CompleteSignUpLoading> createState() => _CompleteSignUpLoadingState();
}

class _CompleteSignUpLoadingState extends State<CompleteSignUpLoading> {
  AppUser curruser = AppUser(
      username: "",
      uid: "",
      pfpurl: "",
      nationality: "",
      joinedEvents: [],
      hostedEvents: [],
      interests: [],
      gender: "",
      fullname: "",
      email: "",
      birthday: DateTime(0, 0, 0, 0),
      followers: [],
      following: [],
      clout: 0,
      favorites: [],
      bio: "",
      blockedusers: [],
      blockedby: [],
      chats: [],
      visiblechats: [],
      notifications: [],
      setnameandpfp: false,
      setusername: false,
      setmisc: false,
      setinterests: false,
      lastknownlat: 0.0,
      lastknownlng: 0.0,
      notificationcounter: 0,
      chatnotificationcounter: 0,
      referred: [],
      donesignuptime: DateTime(0, 0, 0, 0),
      plan: "free");

  db_conn db = db_conn();

  bool error = false;

  bool showrefresh = false;

  Future<void> getUser() async {
    try {
      AppUser user = await db.getUserFromUID(widget.uid);
      setState(() {
        curruser = user;
      });
    } catch (e) {
      setState(() {
        error = true;
      });
      String email = FirebaseAuth.instance.currentUser!.email ?? "";
      List<String> res =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (res.isEmpty) {
        throw Exception();
      } else {
        setState(() {
          showrefresh = true;
        });
      }
    }
  }

  logic() {
    if (curruser.setnameandpfp == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => PicandNameScreen(
                  analytics: widget.analytics,
                ),
            settings: RouteSettings(name: "PicandNameScreen"),
            fullscreenDialog: true),
      );
    } else if (curruser.setusername == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => UsernameScreen(
                  analytics: widget.analytics,
                ),
            settings: RouteSettings(name: "UsernameScreen"),
            fullscreenDialog: true),
      );
    } else if (curruser.setmisc == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => MiscScreen(
                  analytics: widget.analytics,
                ),
            settings: RouteSettings(name: "MiscScreen"),
            fullscreenDialog: true),
      );
    } else if (curruser.setinterests == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => InterestScreen(
                  analytics: widget.analytics,
                ),
            settings: RouteSettings(name: "InterestScreen"),
            fullscreenDialog: true),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => EmailVerificationScreen(
                  analytics: widget.analytics,
                ),
            settings: RouteSettings(name: "EmailVerificationScreen"),
            fullscreenDialog: true),
      );
    }
  }

  refresh() async {
    try {
      Stopwatch stopwatch = Stopwatch()..start();
      await getUser();
      int diff = stopwatch.elapsed.inSeconds.ceil() > 3
          ? stopwatch.elapsed.inSeconds.ceil()
          : 3 - stopwatch.elapsed.inSeconds.ceil();
      Timer(Duration(seconds: diff), () => logic());
    } catch (e) {
      FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => PreAuthScreen(
                  analytics: widget.analytics,
                ),
            settings: RouteSettings(name: "PreAuthScreen"),
            fullscreenDialog: true),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    showrefresh = false;
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
          child: error
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Check your internet connection",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: screenheight * 0.02,
                      ),
                      showrefresh
                          ? InkWell(
                              onTap: () {
                                refresh();
                              },
                              child: SizedBox(
                                  height: 50,
                                  width: screenwidth * 0.6,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20))),
                                    child: const Center(
                                        child: Text(
                                      "Refresh",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    )),
                                  )),
                            )
                          : Container(),
                    ],
                  ),
                )
              : Center(
                  child: Image.asset("assets/images/logos/cloutlogo.gif"))),
    );
  }
}
