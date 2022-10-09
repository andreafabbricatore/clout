class Chat {
  List participants;
  String chatname;
  String iconurl;
  String mostrecentmessage;
  String eventid;
  Chat(
      {required this.participants,
      required this.chatname,
      required this.iconurl,
      required this.mostrecentmessage,
      required this.eventid});

  factory Chat.fromJson(dynamic json, String docid) {
    return Chat(
        participants: json['participants'],
        chatname: json['chatname'],
        iconurl: json['iconurl'],
        mostrecentmessage: json['mostrecentmessage'],
        eventid: json['eventid']);
  }
}
