class NotificationElement {
  String notification;
  DateTime time;
  String type;
  String eventid;
  String userid;

  NotificationElement(
      {required this.notification,
      required this.time,
      required this.type,
      required this.eventid,
      required this.userid});

  factory NotificationElement.fromJson(dynamic json) {
    return NotificationElement(
        notification: json['notification'],
        time: json['time'].toDate(),
        type: json['type'],
        eventid: json['eventid'],
        userid: json['userid']);
  }
}

// types: join, modified, followed, kicked