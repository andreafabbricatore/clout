class Chat {
  List participants;
  List chatname;
  List iconurl;
  String mostrecentmessage;
  List connectedid;
  String chatid;
  String type;

  Chat(
      {required this.participants,
      required this.chatname,
      required this.iconurl,
      required this.mostrecentmessage,
      required this.connectedid,
      required this.chatid,
      required this.type});

  factory Chat.fromJson(dynamic json, String docid) {
    return Chat(
        participants: json['participants'] as List,
        chatname: json['chatname'] as List,
        iconurl: json['iconurl'] as List,
        mostrecentmessage: json['mostrecentmessage'],
        connectedid: json['connectedid'] as List,
        type: json['type'],
        chatid: docid);
  }
}
