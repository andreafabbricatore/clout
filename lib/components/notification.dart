class NotificationElement {
  String notification;
  DateTime time;
  String userdocid;
  String eventid;
  NotificationElement(
      {required this.notification,
      required this.time,
      required this.userdocid,
      required this.eventid});

  factory NotificationElement.fromJson(dynamic json) {
    return NotificationElement(
        notification: json['notification'],
        time: json['time'].toDate(),
        userdocid: json['userdocid'],
        eventid: json['eventdocid']);
  }
}
