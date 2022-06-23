import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String title;
  String description;
  String interest;
  String image;
  String location;
  DateTime datetime;
  int maxparticipants;
  List participants;
  String host;
  String docid;

  Event(
      {required this.title,
      required this.description,
      required this.interest,
      required this.image,
      required this.location,
      required this.host,
      required this.maxparticipants,
      required this.participants,
      required this.datetime,
      required this.docid});

  factory Event.fromJson(dynamic json, String docid) {
    return Event(
      title: json['title'],
      description: json['description'],
      interest: json['interest'],
      image: json['image'],
      location: json['location'],
      host: json['host'],
      maxparticipants: json['maxparticipants'] as int,
      participants: json['participants'] as List,
      datetime: json['time'].toDate(),
      docid: docid,
    );
  }
}
