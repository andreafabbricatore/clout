import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/authscreens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FollowerFollowingScreen extends StatefulWidget {
  FollowerFollowingScreen(
      {Key? key,
      required this.user,
      required this.iscurruser,
      required this.curruser,
      required this.onfollowers,
      required this.curruserlocation,
      required this.analytics,
      required this.followers,
      required this.following})
      : super(key: key);
  AppUser user;
  AppUser curruser;
  bool iscurruser;
  bool onfollowers;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  List<AppUser> followers;
  List<AppUser> following;
  @override
  State<FollowerFollowingScreen> createState() =>
      _FollowerFollowingScreenState();
}

class _FollowerFollowingScreenState extends State<FollowerFollowingScreen> {
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> usernavigate(AppUser user) async {
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.user.username,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  widget.onfollowers = true;
                });
              },
              child: Container(
                height: screenheight * 0.045,
                width: screenwidth * 0.5,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: widget.onfollowers
                                ? Colors.black
                                : const Color.fromARGB(55, 158, 158, 158)),
                        right: const BorderSide(
                            color: Color.fromARGB(55, 158, 158, 158)))),
                child: Center(
                    child: Text(
                  "Followers",
                  style: TextStyle(
                      fontWeight: widget.onfollowers
                          ? FontWeight.bold
                          : FontWeight.normal),
                )),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  widget.onfollowers = false;
                });
              },
              child: Container(
                height: screenheight * 0.045,
                width: screenwidth * 0.5,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: widget.onfollowers
                                ? const Color.fromARGB(55, 158, 158, 158)
                                : Colors.black),
                        left: const BorderSide(color: Colors.white))),
                child: Center(
                    child: Text(
                  "Following",
                  style: TextStyle(
                      fontWeight: widget.onfollowers
                          ? FontWeight.normal
                          : FontWeight.bold),
                )),
              ),
            )
          ],
        ),
        UserListView(
          userres: widget.onfollowers ? widget.followers : widget.following,
          onTap: usernavigate,
          curruser: widget.curruser,
          screenwidth: screenwidth,
          showcloutscore: false,
        )
      ]),
    );
  }
}
