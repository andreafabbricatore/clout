import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clout/components/event.dart';
import 'package:clout/components/user.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

extension FirestoreDocumentExtension on DocumentReference {
  Future<DocumentSnapshot> getSavy() async {
    try {
      DocumentSnapshot ds = await this.get(GetOptions(source: Source.cache));
      if (ds == null) {
        print("server");
        return this.get(GetOptions(source: Source.server));
      } else {
        print("cache");
      }
      return ds;
    } catch (_) {
      return this.get(GetOptions(source: Source.server));
    }
  }
}

// https://github.com/furkansarihan/firestore_collection/blob/master/lib/firestore_query.dart
extension FirestoreQueryExtension on Query {
  Future<QuerySnapshot> getSavy() async {
    try {
      QuerySnapshot qs = await this.get(GetOptions(source: Source.cache));

      if (qs.docs.isEmpty) {
        print("server");
        return this.get(GetOptions(source: Source.server));
      } else {
        print("cache");
      }
      return qs;
    } catch (_) {
      return this.get(GetOptions(source: Source.server));
    }
  }
}

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
        'following': [],
        'favorites': []
      });
    } catch (e) {
      throw Exception("Could not create user");
    }
  }

  Future deleteuser(AppUser curruser) async {
    try {
      DocumentSnapshot userSnapshot = await users.doc(curruser.docid).get();
      List joinedEvents = userSnapshot['joined_events'];
      List hostedEvents = userSnapshot['hosted_events'];
      List followers = userSnapshot['followers'];
      List following = userSnapshot['following'];
      for (String eventid in joinedEvents) {
        await leaveevent(curruser, eventid);
      }
      print("left events");
      for (String eventid in hostedEvents) {
        await deleteevent(eventid, curruser.username);
      }
      print("deleted events");
      for (String userid in following) {
        await unFollow(curruser.docid, userid);
      }
      print("removed following");
      for (String userid in followers) {
        await unFollow(userid, curruser.docid);
      }
      print("removed followers");
      await FirebaseStorage.instance
          .ref('/user_pfp/${curruser.uid}.jpg')
          .delete();
      print("deleted pfp");
      return users.doc(curruser.docid).delete();
    } catch (e) {
      throw Exception("Could not delete user");
    }
  }

  Future createevent(Event newevent, AppUser curruser) async {
    try {
      String bannerUrl = await downloadBannerUrl(newevent.interest);
      List joinedEvents = curruser.joinedEvents;
      List hostedEvents = curruser.hostedEvents;
      String eventid = "";
      bool unique = await eventUnique(
          newevent.title,
          newevent.description,
          newevent.interest,
          newevent.location,
          newevent.host,
          newevent.datetime,
          newevent.maxparticipants,
          [curruser.docid]);
      print(unique);
      List searchfield = [];
      String temp = "";
      for (int i = 0; i < newevent.title.length; i++) {
        temp = temp + newevent.title[i];
        searchfield.add(temp.toLowerCase());
      }
      if (!unique) {
        throw Exception("Event already exists");
      } else {
        await events.add({
          'title': newevent.title,
          'description': newevent.description,
          'interest': newevent.interest,
          'location': newevent.location,
          'host': newevent.host,
          'time': newevent.datetime,
          'maxparticipants': newevent.maxparticipants,
          'participants': [curruser.docid],
          'image': bannerUrl,
          'lat': newevent.lat,
          'lng': newevent.lng,
          'searchfield': searchfield
        }).then((value) {
          eventid = value.id;
        });
        joinedEvents.add(eventid);
        hostedEvents.add(eventid);
        return users.doc(curruser.docid).update({
          'joined_events': joinedEvents,
          'hosted_events': hostedEvents
        }).catchError((error) {
          throw Exception("Could not host event");
        });
      }
    } catch (e) {
      return Future.error("Could not create event");
    }
  }

  Future joinevent(Event event, AppUser curruser, String? eventid) async {
    try {
      DocumentSnapshot eventSnapshot = await events.doc(eventid).get();
      List participants = eventSnapshot['participants'];
      List joinedEvents = curruser.joinedEvents;
      if (participants.length + 1 > event.maxparticipants) {
        throw Exception("Too many participants");
      } else {
        joinedEvents.add(eventid);
        participants.add(curruser.docid);
        users.doc(curruser.docid).update({'joined_events': joinedEvents});
        events.doc(eventid).update({'participants': participants});
      }
    } catch (e) {
      throw Exception("Could not join event");
    }
  }

  Future leaveevent(AppUser curruser, String? eventid) async {
    try {
      DocumentSnapshot eventSnapshot = await events.doc(eventid).get();
      List participants = eventSnapshot['participants'];
      List joinedEvents = curruser.joinedEvents;
      if (participants.length == 1) {
        throw Exception("Cannot leave event");
      } else {
        joinedEvents.removeWhere((element) => element == eventid);
        participants.removeWhere((element) => element == curruser.docid);
        users.doc(curruser.docid).update({'joined_events': joinedEvents});
        events.doc(eventid).update({'participants': participants});
      }
    } catch (e) {
      throw Exception("Could not leave event");
    }
  }

  Future deleteevent(String? eventid, String host) async {
    try {
      DocumentSnapshot eventSnapshot = await events.doc(eventid).get();
      List participants = eventSnapshot['participants'];
      String hostdocid = await getUserDocIDfromUsername(host);
      for (String x in participants) {
        DocumentSnapshot documentSnapshot = await users.doc(x).get();
        List joinedEvents = documentSnapshot['joined_events'];
        if (x == hostdocid) {
          List hostedEvents = documentSnapshot['hosted_events'];
          hostedEvents.removeWhere((element) => element == eventid);
          users.doc(x).update({'hosted_events': hostedEvents});
        }
        joinedEvents.removeWhere((element) => element == eventid);
        users.doc(x).update({'joined_events': joinedEvents});
      }
      await events.doc(eventid).delete();
    } catch (e) {
      throw Exception("Could not delete event");
    }
  }

  Future changepfp(File filePath, String uid) async {
    try {
      await uploadFile(filePath, uid);
      String photoUrl = await downloadURL(uid);
      String id = "";
      await getUserDocID(uid).then((value) => id = value);
      return users
          .doc(id)
          .update({'pfp_url': photoUrl})
          .then((value) => print("changed pfp"))
          .catchError((error) {
            throw Exception("Could not upload pfp");
          });
    } catch (e) {
      throw Exception();
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

  Future changebirthday(DateTime value, String uid) async {
    String id = "";
    await getUserDocID(uid).then((value) => id = value);
    return users
        .doc(id)
        .update({'birthday': value})
        .then((value) => print("changed birthday"))
        .catchError((error) {
          throw Exception("Could not change birthday");
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
      throw Exception();
    }
  }

  Future<String> downloadURL(String uid) async {
    try {
      String downloadUrl = await FirebaseStorage.instance
          .ref('/user_pfp/$uid.jpg')
          .getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Could not get download url");
    }
  }

  Future<String> getUserDocID(String uid) async {
    String docID = "";
    try {
      await users.get().then((QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach((doc) {
              if (doc["uid"] == uid) {
                docID = doc.id;
              }
            })
          });
    } catch (e) {
      throw Exception("Error with userdocid");
    }
    if (docID != "") {
      return docID;
    } else {
      throw Exception("Error with userdocid");
    }
  }

  Future<String> getEventDocID(Event event) async {
    String docID = "";
    try {
      await events.get().then((QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach((doc) {
              if (doc["title"] == event.title &&
                  doc['description'] == event.description &&
                  doc['interest'] == event.interest &&
                  doc['location'] == event.location &&
                  doc['host'] == event.host &&
                  doc['maxparticipants'] == event.maxparticipants &&
                  listEquals(doc['participants'], event.participants) &&
                  doc['time'].toDate() == event.datetime) {
                docID = doc.id;
              }
            })
          });
    } catch (e) {
      throw Exception("Error with eventdocid");
    }
    if (docID != "") {
      return docID;
    } else {
      throw Exception("Error with eventdocid");
    }
  }

  Future<String> getUserDocIDfromUsername(String username) async {
    String docID = "";
    try {
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
    } catch (e) {
      throw Exception("Error with userdocid");
    }
    if (docID != "") {
      return docID;
    } else {
      throw Exception("Error with userdocid");
    }
  }

  Future<String> getUserPFPfromUsername(String username) async {
    String pfpUrl = "";
    try {
      await users.getSavy().then((QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach((doc) {
              if (doc["username"] == username) {
                pfpUrl = doc["pfp_url"];
              }
            })
          });
    } catch (e) {
      throw Exception("Error with user pfp");
    }
    if (pfpUrl != "") {
      return pfpUrl;
    } else {
      throw Exception("Error with user pfp");
    }
  }

  Future<bool> usernameUnique(String username) async {
    int instances = 0;
    try {
      await users.get().then((QuerySnapshot querySnapshot) => {
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
    } catch (e) {
      throw Exception("Could not connect");
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
    try {
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
    } catch (e) {
      throw Exception("Could not connect");
    }
  }

  Future<List> getUserInterests(String id) async {
    try {
      DocumentSnapshot documentSnapshot = await users.doc(id).get();
      List interests = documentSnapshot['interests'];
      return interests;
    } catch (e) {
      throw Exception("Could not retrieve user interests");
    }
  }

  Future<List<Event>> getEvents(List interests) async {
    try {
      QuerySnapshot querySnapshot =
          await events.where('interest', whereNotIn: interests).get();
      List<Event> eventlist = [];
      querySnapshot.docs.forEach((element) {
        eventlist.add(Event.fromJson(element.data(), element.id));
      });
      return eventlist;
    } catch (e) {
      throw Exception("Could not connect");
    }
  }

  Future<List<Event>> getFavEvents(AppUser user) async {
    try {
      List<Event> favEvents = [
        for (String x in user.favorites) await getEventfromDocId(x)
      ];
      return favEvents;
    } catch (e) {
      throw Exception("Could not retrieve fav events");
    }
  }

  Future<Event> getEventfromDocId(String eventid) async {
    try {
      DocumentSnapshot documentSnapshot = await events.doc(eventid).get();
      Event event = Event.fromJson(documentSnapshot.data(), eventid);
      return event;
    } catch (e) {
      throw Exception("Could not get event");
    }
  }

  Future<List<Event>> getInterestEvents(List interests) async {
    try {
      QuerySnapshot querySnapshot =
          await events.where('interest', whereIn: interests).get();
      List<Event> interesteventlist = [];
      querySnapshot.docs.forEach((element) {
        interesteventlist.add(Event.fromJson(element.data(), element.id));
      });
      return interesteventlist;
    } catch (e) {
      throw Exception("Could not retreive events");
    }
  }

  Future<List<Event>> searchEvents(String searchquery) async {
    try {
      QuerySnapshot querySnapshot = await events
          .where('searchfield', arrayContains: searchquery.toLowerCase())
          .getSavy();
      List<Event> eventsearchres = [];
      querySnapshot.docs.forEach((element) {
        eventsearchres.add(Event.fromJson(element.data(), element.id));
      });
      return eventsearchres;
    } catch (e) {
      throw Exception("Could not search for events");
    }
  }

  Future<List<AppUser>> searchUsers(String searchquery) async {
    try {
      QuerySnapshot querySnapshot = await users
          .where('searchfield', arrayContains: searchquery.toLowerCase())
          .getSavy();
      List<AppUser> usersearches = [];
      querySnapshot.docs.forEach((element) {
        usersearches.add(AppUser.fromJson(element.data(), element.id));
      });

      return usersearches;
    } catch (e) {
      throw Exception("Could not search for users");
    }
  }

  Future<String> downloadBannerUrl(String interest) async {
    try {
      String downloadBannerUrl = await FirebaseStorage.instance
          .ref('/interest_banners/${interest.toLowerCase()}.jpeg')
          .getDownloadURL();
      return downloadBannerUrl;
    } catch (e) {
      throw Exception("Could not retreive banner url");
    }
  }

  Future<AppUser> getUserFromDocID(String docid) async {
    try {
      DocumentSnapshot documentSnapshot = await users.doc(docid).get();
      return AppUser.fromJson(documentSnapshot.data(), docid);
    } catch (e) {
      throw Exception("Could not retrieve user");
    }
  }

  Future<void> follow(String curruserdocid, String userdocid) async {
    try {
      DocumentSnapshot curruserdoc = await users.doc(curruserdocid).get();
      DocumentSnapshot userdoc = await users.doc(userdocid).get();
      List following = curruserdoc['following'];
      List followers = userdoc['followers'];
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
      List followers = userdoc['followers'];
      following.removeWhere((element) => element == userdocid);
      followers.removeWhere((element) => element == curruserdocid);
      users.doc(curruserdocid).update({'following': following});
      users.doc(userdocid).update({'followers': followers});
    } catch (e) {
      throw Exception("Could not unfollow");
    }
  }

  Future<void> addToFav(String curruserdocid, String eventid) async {
    try {
      DocumentSnapshot curruserdoc = await users.doc(curruserdocid).get();
      List favorites = curruserdoc['favorites'];
      favorites.add(eventid);
      users.doc(curruserdocid).update({'favorites': favorites});
    } catch (e) {
      throw Exception("Could not add to favorites");
    }
  }

  Future<void> remFromFav(String curruserdocid, String eventid) async {
    try {
      DocumentSnapshot curruserdoc = await users.doc(curruserdocid).get();
      List favorites = curruserdoc['favorites'];
      favorites.removeWhere((element) => element == eventid);
      users.doc(curruserdocid).update({'favorites': favorites});
    } catch (e) {
      throw Exception("Could not remove from favorites");
    }
  }
}
