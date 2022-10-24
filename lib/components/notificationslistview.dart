import 'package:clout/components/chat.dart';
import 'package:clout/components/notification.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NotificationsListView extends StatelessWidget {
  NotificationsListView({
    Key? key,
    required this.notificationlist,
    required this.screenwidth,
    required this.onTapUsername,
  }) : super(key: key);
  List<NotificationElement> notificationlist;
  double screenwidth;
  final Function(String username, int index) onTapUsername;

  Widget _listviewitem(
    NotificationElement notification,
    int index,
  ) {
    List<String> text = notification.notification.split(" ");
    String username = text[0];
    text.removeAt(0);
    String action = text.join(" ");
    Duration diff = DateTime.now().difference(notification.time);
    String timediff = "";
    if (diff.inDays > 1) {
      timediff = "${diff.inDays}d";
    } else if (diff.inHours > 1) {
      timediff = "${diff.inHours}h";
    } else if (diff.inMinutes > 1) {
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
                    textAlign: TextAlign.justify,
                    textScaleFactor: 1.0,
                    text: TextSpan(
                        style:
                            const TextStyle(color: Colors.black, fontSize: 19),
                        children: [
                          TextSpan(
                              text: username,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  onTapUsername(notification.userdocid, index);
                                }),
                          const TextSpan(text: " "),
                          TextSpan(text: action),
                        ]),
                  ),
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
          itemCount: notificationlist.length,
          itemBuilder: (_, index) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                child: _listviewitem(notificationlist[index], index));
          }),
    );
  }
}
