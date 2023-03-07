class AppUser {
  String username;
  String uid;
  String pfpurl;
  String nationality;
  List joinedEvents;
  List hostedEvents;
  List interests;
  String gender;
  String fullname;
  String email;
  DateTime birthday;
  List followers;
  List following;
  List favorites;
  int clout;
  String bio;
  List blockedusers;
  List blockedby;
  List chats;
  List visiblechats;
  List notifications;
  bool setnameandpfp;
  bool setusername;
  bool setmisc;
  bool setinterests;
  double lastknownlat;
  double lastknownlng;
  int notificationcounter;
  int chatnotificationcounter;
  List referred;

  AppUser(
      {required this.username,
      required this.uid,
      required this.pfpurl,
      required this.nationality,
      required this.joinedEvents,
      required this.hostedEvents,
      required this.interests,
      required this.gender,
      required this.fullname,
      required this.email,
      required this.birthday,
      required this.followers,
      required this.following,
      required this.clout,
      required this.favorites,
      required this.bio,
      required this.blockedusers,
      required this.blockedby,
      required this.chats,
      required this.visiblechats,
      required this.notifications,
      required this.setnameandpfp,
      required this.setusername,
      required this.setmisc,
      required this.setinterests,
      required this.lastknownlat,
      required this.lastknownlng,
      required this.notificationcounter,
      required this.chatnotificationcounter,
      required this.referred});

  factory AppUser.fromJson(dynamic json, String docid) {
    return AppUser(
        username: json['username'],
        uid: json['uid'],
        pfpurl: json['pfp_url'],
        nationality: json['nationality'],
        joinedEvents: json['joined_events'] as List,
        hostedEvents: json['hosted_events'] as List,
        interests: json['interests'] as List,
        gender: json['gender'],
        fullname: json['fullname'],
        email: json['email'],
        birthday: json['birthday'].toDate(),
        followers: json['followers'] as List,
        following: json['following'] as List,
        clout: json['clout'] as int,
        favorites: json['favorites'] as List,
        bio: json['bio'],
        blockedusers: json['blocked_users'],
        blockedby: json['blocked_by'],
        chats: json['chats'] as List,
        visiblechats: json['visiblechats'] as List,
        notifications: json['notifications'] as List,
        setnameandpfp: json['setnameandpfp'] as bool,
        setusername: json['setusername'] as bool,
        setmisc: json['setmisc'] as bool,
        setinterests: json['setinterests'] as bool,
        lastknownlat: json['lastknownlat'],
        lastknownlng: json['lastknownlng'],
        notificationcounter: json['notificationcounter'],
        chatnotificationcounter: json['chatnotificationcounter'],
        referred: json['referred'] as List);
  }
}
