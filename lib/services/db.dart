import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clout/components/event.dart';
import 'package:clout/components/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class db_conn {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference events = FirebaseFirestore.instance.collection('events');

  Future createuserinstance(String email, String uid) {
    try {
      return users.add({
        'fullname': '',
        'email': email,
        'username': '',
        'uid': uid,
        'gender': '',
        'nationality': '',
        'pfp_url': '',
        'birthday': '',
        'interests': [],
        'hosted_events': [],
        'joined_events': [],
        'clout': 0,
        'searchfield': [],
        'followers': [],
        'following': []
      });
    } catch (e) {
      return Future.error("Could not Sign Up");
    }
  }

  Future createevent(
      String title,
      String description,
      String interest,
      String location,
      String host,
      DateTime time,
      int maxparticipants,
      AppUser curruser,
      String id) async {
    try {
      String banner_url = await downloadBannerUrl(interest);
      List joined_events = curruser.joined_events;
      List hosted_events = curruser.hosted_events;
      String eventid = "";
      String userdocid = await getUserDocID(curruser.uid);
      bool unique = await eventUnique(title, description, interest, location,
          host, time, maxparticipants, [userdocid]);
      print(unique);
      List searchfield = [];
      String temp = "";
      for (int i = 0; i < title.length; i++) {
        temp = temp + title[i];
        searchfield.add(temp.toLowerCase());
      }
      if (!unique) {
        throw Exception("Event already exists");
      } else {
        await events.add({
          'title': title,
          'description': description,
          'interest': interest,
          'location': location,
          'host': host,
          'time': time,
          'maxparticipants': maxparticipants,
          'participants': [userdocid],
          'image': banner_url,
          'searchfield': searchfield
        }).then((value) {
          eventid = value.id;
        });
        joined_events.add(eventid);
        hosted_events.add(eventid);
        return users.doc(id).update({
          'joined_events': joined_events,
          'hosted_events': hosted_events
        }).catchError((error) {
          throw Exception("Could not host event");
        });
      }
    } catch (e) {
      return Future.error("Could not create event");
    }
  }

  Future joinevent(
      Event event, AppUser curruser, String userdocid, String? eventid) async {
    try {
      DocumentSnapshot eventSnapshot = await events.doc(eventid).get();
      List participants = eventSnapshot['participants'];
      List joined_events = curruser.joined_events;
      if (participants.length + 1 > event.maxparticipants) {
        throw Exception("Too many participants");
      } else {
        joined_events.add(eventid);
        participants.add(userdocid);
        users.doc(userdocid).update({'joined_events': joined_events});
        events.doc(eventid).update({'participants': participants});
      }
    } catch (e) {
      throw Exception("Could not join event");
    }
  }

  Future leaveevent(
      Event event, AppUser curruser, String userdocid, String? eventid) async {
    try {
      DocumentSnapshot eventSnapshot = await events.doc(eventid).get();
      List participants = eventSnapshot['participants'];
      List joined_events = curruser.joined_events;
      if (participants.length == 1) {
        throw Exception("Cannot leave event");
      } else {
        joined_events.removeWhere((element) => element == eventid);
        participants.removeWhere((element) => element == userdocid);
        users.doc(userdocid).update({'joined_events': joined_events});
        events.doc(eventid).update({'participants': participants});
      }
    } catch (e) {
      throw Exception("Could not leave event");
    }
  }

  Future deleteevent(String userdocid, String? eventid, String host) async {
    try {
      DocumentSnapshot eventSnapshot = await events.doc(eventid).get();
      List participants = eventSnapshot['participants'];
      String hostdocid = await getUserDocIDfromUsername(host);
      for (String x in participants) {
        DocumentSnapshot documentSnapshot = await users.doc(x).get();
        List joined_events = documentSnapshot['joined_events'];
        if (x == hostdocid) {
          List hosted_events = documentSnapshot['hosted_events'];
          hosted_events.removeWhere((element) => element == eventid);
          users.doc(x).update({'hosted_events': hosted_events});
        }
        joined_events.removeWhere((element) => element == eventid);
        users.doc(x).update({'joined_events': joined_events});
      }
      await events.doc(eventid).delete();
    } catch (e) {
      throw Exception("Could not delete event");
    }
  }

  Future geteventdocid(Event event) async {
    String docID = "";
    await events.get().then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((doc) {
            if (doc["title"] == event.title &&
                doc['description'] == event.description &&
                doc['interest'] == event.interest &&
                doc['location'] == event.location &&
                doc['host'] == event.host &&
                doc['maxparticipants'] == event.maxparticipants &&
                listEquals(doc['participants'], event.participants)) {
              docID = doc.id;
            }
          })
        });
    if (docID != "") {
      return docID;
    } else {
      return "error";
    }
  }

  Future changepfp(File filePath, String uid) async {
    try {
      await uploadFile(filePath, uid);
      String photo_url = await downloadURL(uid);
      String id = "";
      await getUserDocID(uid).then((value) => id = value);
      return users
          .doc(id)
          .update({'pfp_url': photo_url})
          .then((value) => print("changed pfp"))
          .catchError((error) {
            throw Exception("Could not upload pfp");
          });
    } catch (e) {
      return e;
    }
  }

  Future changeattribute(String attribute, String value, String uid) async {
    String id = "";
    await getUserDocID(uid).then((value) => id = value);
    return users
        .doc(id)
        .update({attribute: value})
        .then((value) => print("changed $attribute"))
        .catchError((error) {
          throw Exception("Could not change $attribute");
        });
  }

  Future changeusername(String username, String uid) async {
    List searchfield = [];
    String temp = "";
    for (int i = 0; i < username.length; i++) {
      temp = temp + username[i];
      searchfield.add(temp.toLowerCase());
    }
    String id = "";
    await getUserDocID(uid).then((value) => id = value);
    return users
        .doc(id)
        .update({'username': username, 'searchfield': searchfield})
        .then((value) => print("changed username"))
        .catchError((error) {
          throw Exception("Could not change username");
        });
  }

  Future changeinterests(String attribute, List interests, String uid) async {
    String id = "";
    await getUserDocID(uid).then((value) => id = value);
    return users
        .doc(id)
        .update({attribute: interests})
        .then((value) => print("changed $attribute"))
        .catchError((error) {
          throw Exception("Could not change $attribute");
        });
  }

  Future uploadFile(File filePath, String uid) async {
    try {
      await FirebaseStorage.instance
          .ref('/user_pfp/$uid.jpg')
          .putFile(filePath);
    } catch (e) {
      return e;
    }
  }

  Future<String> downloadURL(String uid) async {
    String downloadUrl = await FirebaseStorage.instance
        .ref('/user_pfp/$uid.jpg')
        .getDownloadURL();
    return downloadUrl;
  }

  Future<String> getUserDocID(String uid) async {
    String docID = "";
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc["uid"] == uid) {
                  docID = doc.id;
                }
              })
            });
    if (docID != "") {
      return docID;
    } else {
      return "error";
    }
  }

  Future<String> getUserDocIDfromUsername(String username) async {
    String docID = "";
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc["username"] == username) {
                  docID = doc.id;
                }
              })
            });
    if (docID != "") {
      return docID;
    } else {
      return "error";
    }
  }

  Future<String> getUserPFPfromUsername(String username) async {
    String pfp_url = "";
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc["username"] == username) {
                  pfp_url = doc["pfp_url"];
                }
              })
            });
    if (pfp_url != "") {
      return pfp_url;
    } else {
      return "error";
    }
  }

  Future<bool> usernameUnique(String username) async {
    int instances = 0;
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                if (doc["username"] == username) {
                  instances = instances + 1;
                }
              })
            });
    if (instances == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> eventUnique(
      String title,
      String description,
      String interest,
      String location,
      String host,
      DateTime time,
      int maxparticipants,
      List participants) async {
    int instances = 0;
    await events.get().then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((doc) {
            if (doc["title"] == title &&
                doc['description'] == description &&
                doc['interest'] == interest &&
                doc['location'] == location &&
                doc['host'] == host &&
                doc['maxparticipants'] == maxparticipants &&
                listEquals(doc['participants'], participants) &&
                doc['time'].toDate() == time) {
              instances = instances + 1;
            }
          })
        });
    if (instances == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<List> getUserInterests(String id) async {
    DocumentSnapshot documentSnapshot = await users.doc(id).get();
    List interests = documentSnapshot['interests'];
    return interests;
  }

  Future<List<Event>> getEvents(List interests) async {
    QuerySnapshot querySnapshot =
        await events.where('interest', whereNotIn: interests).get();
    List<Event> eventlist = [];
    querySnapshot.docs.forEach((element) {
      eventlist.add(Event.fromJson(element.data()));
    });
    return eventlist;
  }

  Future<Event> getEventfromDocId(String eventid) async {
    DocumentSnapshot documentSnapshot = await events.doc(eventid).get();
    Event event = Event.fromJson(documentSnapshot.data());
    return event;
  }

  Future<List<Event>> getInterestEvents(List interests) async {
    QuerySnapshot querySnapshot =
        await events.where('interest', whereIn: interests).get();
    List<Event> interesteventlist = [];
    querySnapshot.docs.forEach((element) {
      interesteventlist.add(Event.fromJson(element.data()));
    });
    return interesteventlist;
  }

  Future<List<Event>> searchEvents(String searchquery) async {
    QuerySnapshot querySnapshot = await events
        .where('searchfield', arrayContains: searchquery.toLowerCase())
        .get();
    List<Event> eventsearchres = [];
    querySnapshot.docs.forEach((element) {
      eventsearchres.add(Event.fromJson(element.data()));
    });
    return eventsearchres;
  }

  Future<List<AppUser>> searchUsers(String searchquery) async {
    QuerySnapshot querySnapshot = await users
        .where('searchfield', arrayContains: searchquery.toLowerCase())
        .get();
    List<AppUser> usersearches = [];
    querySnapshot.docs.forEach((element) {
      usersearches.add(AppUser.fromJson(element.data()));
    });

    return usersearches;
  }

  Future<String> downloadBannerUrl(String interest) async {
    String downloadBannerUrl = await FirebaseStorage.instance
        .ref('/interest_banners/${interest.toLowerCase()}.jpeg')
        .getDownloadURL();
    return downloadBannerUrl;
  }

  Future<AppUser> getUserFromDocID(String docid) async {
    DocumentSnapshot documentSnapshot = await users.doc(docid).get();
    return AppUser.fromJson(documentSnapshot.data());
  }

  Future<void> Follow(String curruserdocid, String userdocid) async {
    try {
      DocumentSnapshot curruserdoc = await users.doc(curruserdocid).get();
      DocumentSnapshot userdoc = await users.doc(userdocid).get();
      List following = curruserdoc['following'];
      List followers = userdoc['following'];
      following.add(userdocid);
      followers.add(curruserdocid);
      users.doc(curruserdocid).update({'following': following});
      users.doc(userdocid).update({'followers': followers});
    } catch (e) {
      throw Exception("Could not follow");
    }
  }

  Future<void> unFollow(String curruserdocid, String userdocid) async {
    try {
      DocumentSnapshot curruserdoc = await users.doc(curruserdocid).get();
      DocumentSnapshot userdoc = await users.doc(userdocid).get();
      List following = curruserdoc['following'];
      List followers = userdoc['following'];
      following.removeWhere((element) => element == userdocid);
      followers.removeWhere((element) => element == curruserdocid);
      users.doc(curruserdocid).update({'following': following});
      users.doc(userdocid).update({'followers': followers});
    } catch (e) {
      throw Exception("Could not follow");
    }
  }
}
