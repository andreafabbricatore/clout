import 'package:clout/defs/notification.dart';
import 'package:clout/defs/user.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NotificationsListView extends StatelessWidget {
  NotificationsListView(
      {Key? key,
      required this.notificationlist,
      required this.screenwidth,
      required this.onTapUsername,
      required this.gotoRequestScreen,
      required this.onTapEvent,
      required this.curruser})
      : super(key: key);
  List<NotificationElement> notificationlist;
  double screenwidth;
  AppUser curruser;
  final Function(String uid, int index) onTapUsername;
  final Function(String eventid, int index) onTapEvent;
  final Function() gotoRequestScreen;

  Widget friendrequestitem() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              gotoRequestScreen.call();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.person_add,
                  size: 30,
                ),
                SizedBox(
                  width: screenwidth * 0.03,
                ),
                const Text(
                  "Friend Requests",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  textScaleFactor: 1.0,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 1,
            width: screenwidth * 0.9,
            color: Colors.black,
          )
        ],
      ),
    );
  }

  Widget _listviewitem(
    NotificationElement notification,
    int index,
  ) {
    late InlineSpan finaltext;
    if (notification.type == "followed") {
      List<String> text = notification.notification.split(" ");
      String username = text[0];
      finaltext = TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 19),
          children: [
            TextSpan(
                text: username,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    onTapUsername.call(notification.userid, index);
                  }),
            const TextSpan(text: " started following you"),
          ]);
    } else if (notification.type == "modified") {
      List<String> text = notification.notification.split("was");
      String eventitle = text[0].toString().trim();
      finaltext = TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 19),
          children: [
            TextSpan(
                text: eventitle,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    onTapEvent.call(notification.eventid, index);
                  }),
            const TextSpan(text: " was modified. Check out the changes!"),
          ]);
    } else if (notification.type == "kicked") {
      List<String> text = notification.notification.split(":");
      String eventtitle = text.last.toString().trim();
      finaltext = TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 19),
          children: [
            const TextSpan(text: "You were kicked out of the event: "),
            TextSpan(
                text: eventtitle,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    onTapEvent.call(notification.eventid, index);
                  }),
          ]);
    } else if (notification.type == "joined") {
      List<String> text = notification.notification.split(" ");
      String username = text[0];
      text = notification.notification.split(":");
      String eventtitle = text.last.toString().trim();
      finaltext = TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 19),
          children: [
            TextSpan(
                text: username,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    onTapUsername.call(notification.userid, index);
                  }),
            const TextSpan(text: " joined your event: "),
            TextSpan(
                text: eventtitle,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    onTapEvent.call(notification.eventid, index);
                  }),
          ]);
    } else {}

    Duration diff = DateTime.now().difference(notification.time);
    String timediff = "";
    if (diff.inDays >= 1) {
      timediff = "${diff.inDays}d";
    } else if (diff.inHours >= 1) {
      timediff = "${diff.inHours}h";
    } else if (diff.inMinutes >= 1) {
      timediff = "${diff.inMinutes}m";
    } else {
      timediff = "1s";
    }

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
          child: SizedBox(
            width: screenwidth * 0.9,
            child: Row(
              children: [
                SizedBox(
                  width: screenwidth * 0.8,
                  child: RichText(
                      textAlign: TextAlign.start,
                      textScaleFactor: 1.0,
                      text: finaltext),
                ),
                SizedBox(
                  width: screenwidth * 0.1,
                  child: Text(
                    timediff,
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 16, 0, 0),
          shrinkWrap: true,
          itemCount: notificationlist.length + 1,
          itemBuilder: (_, index) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                child: index == 0
                    ? curruser.plan == "business"
                        ? Container()
                        : friendrequestitem()
                    : _listviewitem(notificationlist[index - 1], index - 1));
          }),
    );
  }
}
