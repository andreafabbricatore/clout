import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FollowerFollowingScreen extends StatefulWidget {
  FollowerFollowingScreen(
      {Key? key,
      required this.user,
      required this.iscurruser,
      required this.curruser,
      required this.onfollowers})
      : super(key: key);
  AppUser user;
  AppUser curruser;
  bool iscurruser;
  bool onfollowers;

  @override
  State<FollowerFollowingScreen> createState() =>
      _FollowerFollowingScreenState();
}

class _FollowerFollowingScreenState extends State<FollowerFollowingScreen> {
  List<AppUser> followers = [];
  List<AppUser> following = [];
  db_conn db = db_conn();

  void displayErrorSnackBar(String error) async {
    final snackBar = SnackBar(
      content: Text(error),
      duration: Duration(seconds: 2),
    );
    await Future.delayed(Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> getfollowerslist() async {
    followers = [];
    try {
      for (int i = 0; i < widget.user.followers.length; i++) {
        AppUser temp = await db.getUserFromDocID(widget.user.followers[i]);
        setState(() {
          followers.add(temp);
        });
      }
    } catch (e) {
      displayErrorSnackBar("Could not retrieve followers");
    }
  }

  Future<void> getfollowinglist() async {
    following = [];
    try {
      for (int i = 0; i < widget.user.following.length; i++) {
        AppUser temp = await db.getUserFromDocID(widget.user.following[i]);
        setState(() {
          following.add(temp);
        });
      }
    } catch (e) {
      displayErrorSnackBar("Could not retrieve following");
    }
  }

  Future<void> refresh() async {
    await getfollowerslist();
    await getfollowinglist();
  }

  @override
  void initState() {
    // TODO: implement initState
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> _usernavigate(AppUser user, int index) async {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => ProfileScreen(
                    user: user,
                    curruser: widget.curruser,
                    visit: true,
                    interests: [],
                  )));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.user.username,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
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
                child: Center(
                    child: Text(
                  "Followers",
                  style: TextStyle(
                      fontWeight: widget.onfollowers
                          ? FontWeight.bold
                          : FontWeight.normal),
                )),
                height: screenheight * 0.045,
                width: screenwidth * 0.5,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: widget.onfollowers
                                ? Colors.black
                                : Color.fromARGB(55, 158, 158, 158)),
                        right: BorderSide(
                            color: Color.fromARGB(55, 158, 158, 158)))),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  widget.onfollowers = false;
                });
              },
              child: Container(
                child: Center(
                    child: Text(
                  "Following",
                  style: TextStyle(
                      fontWeight: widget.onfollowers
                          ? FontWeight.normal
                          : FontWeight.bold),
                )),
                height: screenheight * 0.045,
                width: screenwidth * 0.5,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: widget.onfollowers
                                ? Color.fromARGB(55, 158, 158, 158)
                                : Colors.black),
                        left: BorderSide(color: Colors.white))),
              ),
            )
          ],
        ),
        UserListView(
          userres: widget.onfollowers ? followers : following,
          onTap: _usernavigate,
          curruser: widget.curruser,
        )
      ]),
    );
  }
}
