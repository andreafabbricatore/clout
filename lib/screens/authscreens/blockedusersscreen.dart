import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:flutter/material.dart';

class BlockedUsersScreen extends StatefulWidget {
  BlockedUsersScreen({Key? key, required this.curruser}) : super(key: key);
  AppUser curruser;
  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  db_conn db = db_conn();
  List<AppUser> blockedusers = [];
  applogic logic = applogic();

  Future<void> getUserList() async {
    try {
      List<AppUser> temp = [];
      for (int i = 0; i < widget.curruser.blockedusers.length; i++) {
        AppUser user = await db.getUserFromUID(widget.curruser.blockedusers[i]);
        temp.add(user);
      }
      setState(() {
        blockedusers = temp;
      });
    } catch (e) {
      logic.displayErrorSnackBar("Could not get user rankings", context);
    }
  }

  Future<void> updatecurruser() async {
    try {
      AppUser updateduser = await db.getUserFromUID(widget.curruser.uid);
      setState(() {
        widget.curruser = updateduser;
      });
    } catch (e) {
      logic.displayErrorSnackBar(
          "Could not refresh blocked users list", context);
    }
  }

  void refresh() async {
    await updatecurruser();
    getUserList();
  }

  @override
  void initState() {
    super.initState();
    getUserList();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    Future<void> unblockUser(AppUser user, int index) async {
      try {
        await db.unblockUser(widget.curruser.uid, user.uid);
        logic.displayErrorSnackBar(
            "Unblocked user! We love friendship :)", context);
        refresh();
      } catch (e) {
        logic.displayErrorSnackBar(
            "Could not remove participant, please try again", context);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Blocked Users",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
          textScaleFactor: 1.0,
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenheight,
            width: screenwidth,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              UserListView(
                userres: blockedusers,
                onTap: null,
                curruser: widget.curruser,
                screenwidth: screenwidth,
                showcloutscore: false,
                showrembutton: true,
                removeUser: unblockUser,
                removebuttonblack: true,
                showsendbutton: false,
                showfriendbutton: false,
              ),
              SizedBox(
                height: screenheight * 0.02,
              )
            ]),
          ),
        ),
      ),
    );
  }
}
