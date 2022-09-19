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
  String docid;
  String bio;

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
      required this.docid,
      required this.bio});

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
        docid: docid,
        bio: json['bio']);
  }
}
