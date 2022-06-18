import 'package:clout/components/event.dart';

class AppUser {
  String username;
  String uid;
  String pfp_url;
  String nationality;
  List joined_events;
  List hosted_events;
  List interests;
  String gender;
  String fullname;
  String email;
  String birthday;

  AppUser(
      {required this.username,
      required this.uid,
      required this.pfp_url,
      required this.nationality,
      required this.joined_events,
      required this.hosted_events,
      required this.interests,
      required this.gender,
      required this.fullname,
      required this.email,
      required this.birthday});

  factory AppUser.fromJson(dynamic json) {
    return AppUser(
      username: json['username'],
      uid: json['uid'],
      pfp_url: json['pfp_url'],
      nationality: json['nationality'],
      joined_events: json['joined_events'] as List,
      hosted_events: json['hosted_events'] as List,
      interests: json['interests'] as List,
      gender: json['gender'],
      fullname: json['fullname'],
      email: json['email'],
      birthday: json['birthday'],
    );
  }
}
