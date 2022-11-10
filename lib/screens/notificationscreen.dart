import 'package:clout/components/notificationslistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/notification.dart';
import 'package:clout/screens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  NotificationScreen({Key? key, required this.curruser}) : super(key: key);
  AppUser curruser;
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  db_conn db = db_conn();
  List<NotificationElement> notis = [];

  void setup() {
    notis = [];
    for (int i = 0; i < widget.curruser.notifications.length; i++) {
      notis.add(NotificationElement.fromJson(widget.curruser.notifications[i]));
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
    Future<void> usernavigate(String docid, int index) async {
      AppUser user = await db.getUserFromDocID(docid);
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => ProfileScreen(
                    user: user,
                    curruser: widget.curruser,
                    visit: true,
                  )));
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
      body: Column(children: [
        NotificationsListView(
          notificationlist: notis,
          screenwidth: screenwidth,
          onTapUsername: usernavigate,
        )
      ]),
    );
  }
}
