import 'package:clout/defs/location.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/models/userlistview.dart';
import 'package:clout/screens/authscreens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  FriendsScreen(
      {Key? key,
      required this.user,
      required this.iscurruser,
      required this.curruser,
      required this.curruserlocation,
      required this.analytics,
      required this.friends})
      : super(key: key);
  AppUser user;
  AppUser curruser;
  bool iscurruser;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  List<AppUser> friends;
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  db_conn db = db_conn();

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
      backgroundColor: Colors.white,
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
      body: SingleChildScrollView(
        child: SizedBox(
          height: widget.friends.length * 60.0 + 16.0 + screenheight * 0.1,
          child: UserListView(
            userres: widget.friends,
            onTap: usernavigate,
            curruser: widget.curruser,
            screenwidth: screenwidth,
            showcloutscore: false,
            showrembutton: false,
            showsendbutton: false,
            physics: NeverScrollableScrollPhysics(),
            showfriendbutton: false,
          ),
        ),
      ),
    );
  }
}
