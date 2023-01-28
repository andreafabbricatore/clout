import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/services/db.dart';
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
      displayErrorSnackBar("Could not get user rankings");
    }
  }

  Future<void> updatecurruser() async {
    try {
      AppUser updateduser = await db.getUserFromUID(widget.curruser.uid);
      setState(() {
        widget.curruser = updateduser;
      });
    } catch (e) {
      displayErrorSnackBar("Could not refresh blocked users list");
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
        refresh();
      } catch (e) {
        displayErrorSnackBar("Could not remove participant, please try again");
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
