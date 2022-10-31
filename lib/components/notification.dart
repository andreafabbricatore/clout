class NotificationElement {
  String notification;
  DateTime time;
  String type;
  NotificationElement(
      {required this.notification, required this.time, required this.type});

  factory NotificationElement.fromJson(dynamic json) {
    return NotificationElement(
        notification: json['notification'],
        time: json['time'].toDate(),
        type: json['type']);
  }
}

// types: join, modified, followed, kicked