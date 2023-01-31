import 'dart:async';

import 'package:clout/components/user.dart';
import 'package:clout/screens/emailverificationscreen.dart';
import 'package:clout/screens/signupscreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';

class CompleteSignUpLoading extends StatefulWidget {
  CompleteSignUpLoading({Key? key, required this.uid}) : super(key: key);
  String uid;
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
      lastknownlng: 0.0);

  db_conn db = db_conn();

  bool error = false;

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
    }
  }

  logic() {
    if (curruser.setnameandpfp == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => PicandNameScreen(),
            fullscreenDialog: true),
      );
    } else if (curruser.setusername == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => UsernameScreen(),
            fullscreenDialog: true),
      );
    } else if (curruser.setmisc == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => MiscScreen(),
            fullscreenDialog: true),
      );
    } else if (curruser.setinterests == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => InterestScreen(),
            fullscreenDialog: true),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const EmailVerificationScreen(),
            fullscreenDialog: true),
      );
    }
  }

  refresh() async {
    Stopwatch stopwatch = Stopwatch()..start();
    await getUser();
    int diff = stopwatch.elapsed.inSeconds.ceil() > 2
        ? stopwatch.elapsed.inSeconds.ceil()
        : 2 - stopwatch.elapsed.inSeconds.ceil();
    Timer(Duration(seconds: diff), () => logic());
  }

  @override
  void initState() {
    super.initState();
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
                      InkWell(
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
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Image.asset("assets/images/logos/cloutlogo.gif"))),
    );
  }
}
