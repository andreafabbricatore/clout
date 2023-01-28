import 'dart:math';

import 'package:clout/components/user.dart';
import 'package:clout/screens/emailverificationscreen.dart';
import 'package:clout/screens/signupscreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/foundation.dart';
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
      print(user);
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
          builder: (BuildContext context) =>
              PicandNameScreen(curruser: curruser),
        ),
      );
    } else if (curruser.setusername == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => UsernameScreen(curruser: curruser),
        ),
      );
    } else if (curruser.setmisc == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => MiscScreen(curruser: curruser),
        ),
      );
    } else if (curruser.setinterests == false) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => InterestScreen(curruser: curruser),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const EmailVerificationScreen(),
        ),
      );
    }
  }

  refresh() async {
    await getUser();
    logic();
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
      backgroundColor: Colors.white,
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
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 255, 48, 117),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: const Center(
                                child: Text(
                              "Refresh",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            )),
                          )),
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Clout",
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 48, 117),
                          fontFamily: "Kristi",
                          fontWeight: FontWeight.w500,
                          fontSize: 80),
                      textScaleFactor: 1.0,
                    ),
                    const Text(
                      "Go Out",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    ),
                    SizedBox(
                      height: screenheight * 0.1,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
