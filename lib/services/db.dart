import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clout/components/chat.dart';
import 'package:clout/components/event.dart';
import 'package:clout/components/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

extension FirestoreDocumentExtension on DocumentReference {
  Future<DocumentSnapshot> getSavy() async {
    try {
      DocumentSnapshot ds = await this.get(GetOptions(source: Source.cache));
      if (ds == null) {
        //print("server");
        return this.get(GetOptions(source: Source.server));
      } else {
        //print("cache");
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
        //print("server");
        return this.get(GetOptions(source: Source.server));
      } else {
        //print("cache");
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
  CollectionReference updates =
      FirebaseFirestore.instance.collection('updates');
  CollectionReference report = FirebaseFirestore.instance.collection('report');
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  CollectionReference bugs = FirebaseFirestore.instance.collection('bugs');

  Future createuserinstance(String email, String uid) async {
    try {
      await users.doc(uid).set({
        'fullname': '',
        'email': email,
        'username': '',
        'uid': uid,
        'gender': '',
        'nationality': '',
        'pfp_url': '',
        'birthday': DateTime(1900, 1, 1, 0, 0),
        'interests': [],
        'hosted_events': [],
        'joined_events': [],
        'clout': 0,
        'searchfield': [],
        'followers': [],
        'following': [],
        'favorites': [],
        'bio': '',
        'blocked_users': [],
        'blocked_by': [],
        'chats': [],
        'visiblechats': [],
        'tokens': [],
        'notifications': [],
        'plan': 'free',
        'setnameandpfp': false,
        'setusername': false,
        'setmisc': false,
        'setinterests': false,
        'lastknownlat': 0.0,
        'lastknownlng': 0.0,
        'notificationcounter': 0,
        'chatnotificationcounter': 0
      });
    } catch (e) {
      throw Exception("Could not create user");
    }
  }

  Future cleartokens(AppUser curruser) async {
    try {
      final instance = FirebaseFirestore.instance;
      final batch = instance.batch();
      var collection =
          instance.collection('users').doc(curruser.uid).collection('tokens');
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      await users.doc(curruser.uid).update({"tokens": []});
    } catch (e) {
      print(e);
      throw Exception();
    }
  }

  Future deleteuser(AppUser curruser) async {
    try {
      DocumentSnapshot userSnapshot = await users.doc(curruser.uid).get();
      List joinedEvents = userSnapshot['joined_events'];
      List hostedEvents = userSnapshot['hosted_events'];
      List followers = userSnapshot['followers'];
      List following = userSnapshot['following'];
      for (String eventid in joinedEvents) {
        Event i = await getEventfromDocId(eventid);
        await leaveevent(curruser, i);
      }
      //print("left events");
      for (String eventid in hostedEvents) {
        Event i = await getEventfromDocId(eventid);
        await deleteevent(i, curruser);
      }
      //print("deleted events");
      for (String userid in following) {
        await unFollow(curruser.uid, userid);
      }
      //print("removed following");
      for (String userid in followers) {
        await unFollow(userid, curruser.uid);
      }
      //print("removed followers");
      await FirebaseStorage.instance
          .ref('/user_pfp/${curruser.uid}.jpg')
          .delete();
      //print("deleted pfp");
      try {
        final instance = FirebaseFirestore.instance;
        final batch = instance.batch();
        var collection =
            instance.collection('users').doc(curruser.uid).collection('tokens');
        var snapshots = await collection.get();
        for (var doc in snapshots.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (e) {
        //print("Nothing")
      }
      return users.doc(curruser.uid).delete();
    } catch (e) {
      throw Exception("Could not delete user");
    }
  }

  Future firstcancelsignup(String uid) async {
    try {
      return users.doc(uid).delete();
    } catch (e) {}
  }

  Future cancelsignup(String uid) async {
    try {
      await FirebaseStorage.instance.ref('/user_pfp/$uid.jpg').delete();
      return users.doc(uid).delete();
    } catch (e) {
      throw Exception();
    }
  }

  Future createevent(Event newevent, AppUser curruser, var imagepath) async {
    try {
      String bannerUrl = "";
      bool customimage = false;
      String eventid = "";
      bool unique = await eventUnique(
          newevent.title,
          newevent.description,
          newevent.interest,
          newevent.country,
          newevent.address,
          newevent.city,
          newevent.host,
          newevent.datetime);
      //print(unique);
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
          'address': newevent.address,
          'country': newevent.country,
          'city': newevent.city,
          'host': newevent.host,
          'hostdocid': newevent.hostdocid,
          'time': newevent.datetime,
          'maxparticipants': newevent.maxparticipants,
          'participants': [curruser.uid],
          'image': "",
          'custom_image': false,
          'lat': newevent.lat,
          'lng': newevent.lng,
          'searchfield': searchfield,
          'chatid': '',
          'isinviteonly': newevent.isinviteonly,
          'presentparticipants': newevent.presentparticipants
        }).then((value) {
          eventid = value.id;
        });

        if (imagepath == null) {
          bannerUrl = await downloadBannerUrl(newevent.interest);
        } else {
          customimage = true;
          bannerUrl = await uploadEventThumbnail(imagepath, eventid);
        }
        await events
            .doc(eventid)
            .update({'image': bannerUrl, 'custom_image': customimage});
        String chatid = "";
        await chats.add({
          "connectedid": [eventid],
          "participants": [curruser.uid],
          "chatname": [newevent.title],
          "iconurl": [bannerUrl],
          "mostrecentmessage": "${newevent.title} was just created!",
          "type": "event",
          "readby": [],
          "lastmessagetime": DateTime.now()
        }).then((value) => chatid = value.id);
        await chats.doc(chatid).collection('messages').add({
          'content': "${newevent.title} was just created!",
          'sender': 'server',
          'timestamp': DateTime.now()
        });
        await events.doc(eventid).update({"chatid": chatid});
        await users.doc(curruser.uid).set({
          'joined_events': FieldValue.arrayUnion([eventid]),
          'hosted_events': FieldValue.arrayUnion([eventid]),
          'chats': FieldValue.arrayUnion([chatid]),
          'visiblechats': FieldValue.arrayUnion([chatid]),
          'clout': FieldValue.increment(20)
        }, SetOptions(merge: true));
      }
    } catch (e) {
      return Future.error("Could not create event");
    }
  }

  Future<void> updateEvent(Event event, var imagepath) async {
    try {
      DocumentSnapshot oldEventSnapshot = await events.doc(event.docid).get();
      String bannerUrl = "";
      if (imagepath == null) {
        bannerUrl = event.image;
      } else {
        bannerUrl = await uploadEventThumbnail(imagepath, event.docid);
      }
      bool custompic = oldEventSnapshot['custom_image'];
      if (!custompic && imagepath != null) {
        custompic = true;
      }
      List searchfield = [];
      String temp = "";
      for (int i = 0; i < event.title.length; i++) {
        temp = temp + event.title[i];
        searchfield.add(temp.toLowerCase());
      }
      List participants = oldEventSnapshot['participants'];
      if (event.maxparticipants < participants.length) {
        throw Exception();
      }
      events.doc(event.docid).update({
        'title': event.title,
        'description': event.description,
        'interest': event.interest,
        'country': event.country,
        'address': event.address,
        'city': event.city,
        'time': event.datetime,
        'maxparticipants': event.maxparticipants,
        'custom_image': custompic,
        'image': bannerUrl,
        'lat': event.lat,
        'lng': event.lng,
        'searchfield': searchfield,
        'isinviteonly': event.isinviteonly
      });
      event.participants.removeWhere((element) => element == event.hostdocid);
      updates.add({
        'target': event.participants,
        'description': '${event.title} was modified. Check out the changes!',
        'notification': '${event.title} was modified. Check out the changes!',
        'eventid': event.docid,
        'userid': "",
        'type': 'modified'
      });
    } catch (e) {
      throw Exception();
    }
  }

  Future joinevent(Event event, AppUser curruser, String? eventid) async {
    try {
      DocumentSnapshot eventSnapshot = await events.doc(eventid).get();
      List participants = eventSnapshot['participants'];

      if (participants.length + 1 > event.maxparticipants) {
        throw Exception("Too many participants");
      } else {
        users.doc(curruser.uid).set({
          'joined_events': FieldValue.arrayUnion([eventid]),
        }, SetOptions(merge: true));
        events.doc(eventid).set({
          'participants': FieldValue.arrayUnion([curruser.uid])
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception("Could not join event");
    } finally {
      try {
        DocumentSnapshot eventSnapshot = await events.doc(eventid).get();
        List participants = eventSnapshot['participants'];

        if (participants.length > event.maxparticipants) {
          await leaveevent(curruser, event);
        } else {
          updates.add({
            'target': [event.hostdocid],
            'description':
                '${curruser.fullname} joined your your event: ${event.title}',
            'notification':
                '@${curruser.username} joined your your event: ${event.title}',
            'eventid': event.docid,
            'userid': curruser.uid,
            'type': 'joined'
          });
          users.doc(curruser.uid).set({
            'chats': FieldValue.arrayUnion([event.chatid]),
            'visiblechats': FieldValue.arrayUnion([event.chatid])
          }, SetOptions(merge: true));
          chats.doc(event.chatid).set({
            'participants': FieldValue.arrayUnion([curruser.uid])
          }, SetOptions(merge: true));
          chats.doc(event.chatid).collection('messages').add({
            'content': "${curruser.username} joined the event",
            'sender': 'server',
            'timestamp': DateTime.now()
          });
          chats.doc(event.chatid).update({
            'mostrecentmessage': "${curruser.username} joined the event",
            "lastmessagetime": DateTime.now()
          });
        }
      } catch (e) {
        throw Exception("Could not notify host that you joined");
      }
    }
  }

  Future leaveevent(AppUser curruser, Event event) async {
    try {
      DocumentSnapshot eventSnapshot = await events.doc(event.docid).get();
      DocumentSnapshot chatSnapshot = await chats.doc(event.chatid).get();
      List participants = eventSnapshot['participants'];
      List chatparticipants = chatSnapshot['participants'];
      if (participants.length == 1) {
        throw Exception("Cannot leave event");
      } else {
        chatparticipants.removeWhere((element) => element == curruser.uid);
        users.doc(curruser.uid).set({
          'joined_events': FieldValue.arrayRemove([event.docid]),
          'chats': FieldValue.arrayRemove([event.chatid]),
          'visiblechats': FieldValue.arrayRemove([event.chatid])
        }, SetOptions(merge: true));
        events.doc(event.docid).set({
          'participants': FieldValue.arrayRemove([curruser.uid])
        }, SetOptions(merge: true));
        chats.doc(event.chatid).set({
          'participants': FieldValue.arrayRemove([curruser.uid])
        }, SetOptions(merge: true));
        chats.doc(event.chatid).collection('messages').add({
          'content': "${curruser.username} left the event",
          'sender': 'server',
          'timestamp': DateTime.now()
        });
        chats.doc(event.chatid).update({
          'mostrecentmessage': "${curruser.username} left the event",
          "lastmessagetime": DateTime.now()
        });
      }
    } catch (e) {
      throw Exception("Could not leave event");
    }
  }

  Future removeparticipant(AppUser user, Event event) async {
    try {
      users.doc(user.uid).set({
        'joined_events': FieldValue.arrayRemove([event.docid]),
        'chats': FieldValue.arrayRemove([event.chatid]),
        'visiblechats': FieldValue.arrayRemove([event.chatid]),
      }, SetOptions(merge: true));
      events.doc(event.docid).set({
        'participants': FieldValue.arrayRemove([user.uid])
      }, SetOptions(merge: true));
      chats.doc(event.chatid).set({
        'participants': FieldValue.arrayRemove([user.uid])
      }, SetOptions(merge: true));
      chats.doc(event.chatid).collection('messages').add({
        'content': "${user.username} was removed from the event",
        'sender': 'server',
        'timestamp': DateTime.now()
      });
      chats.doc(event.chatid).update({
        'mostrecentmessage': "${user.username} was removed from the event",
        "lastmessagetime": DateTime.now()
      });
      updates.add({
        'target': [user.uid],
        'description': 'You were kicked out of the event: ${event.title}',
        'notification': 'You were kicked out of the event: ${event.title}',
        'eventid': event.docid,
        'userid': "",
        'type': 'kicked'
      });
    } catch (e) {
      throw Exception("Could not leave event");
    }
  }

  Future deleteevent(Event event, AppUser host) async {
    try {
      DocumentSnapshot eventSnapshot = await events.doc(event.docid).get();
      List participants = eventSnapshot['participants'];
      for (String x in participants) {
        if (x == host.uid) {
          users.doc(x).set({
            'hosted_events': FieldValue.arrayRemove([event.docid]),
            'chats': FieldValue.arrayRemove([event.chatid]),
            'visiblechats': FieldValue.arrayRemove([event.chatid]),
            'clout': FieldValue.increment(-20),
          }, SetOptions(merge: true));
        }
        users.doc(x).set({
          'joined_events': FieldValue.arrayRemove([event.docid])
        }, SetOptions(merge: true));
      }
      if (eventSnapshot['custom_image']) {
        await FirebaseStorage.instance
            .ref('/event_thumbnails/${event.docid}.jpg')
            .delete();
      } else {}
      final instance = FirebaseFirestore.instance;
      final batch = instance.batch();
      var collection =
          instance.collection('chats').doc(event.chatid).collection('messages');
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      await deletechat(event.chatid);
      await events.doc(event.docid).delete();
    } catch (e) {
      throw Exception("Could not delete event");
    }
  }

  Future<void> deletechat(String chatid) async {
    try {
      DocumentSnapshot chat = await chats.doc(chatid).get();
      List participants = chat['participants'];
      for (int i = 0; i < participants.length; i++) {
        await users.doc(participants[i]).set({
          'chats': FieldValue.arrayRemove([chatid])
        }, SetOptions(merge: true));
      }
      final instance = FirebaseFirestore.instance;
      final batch = instance.batch();
      var collection =
          instance.collection('chats').doc(chatid).collection('messages');
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      await chats.doc(chatid).delete();
    } catch (e) {
      throw Exception();
    }
  }

  Future changepfp(File filePath, String uid) async {
    try {
      await uploadUserPFP(filePath, uid);
      String photoUrl = await downloadUserPFPURL(uid);
      DocumentSnapshot documentSnapshot = await users.doc(uid).get();
      print("here");
      await users.doc(uid).update({'pfp_url': photoUrl});
      List chatlist = documentSnapshot['chats'];
      for (int i = 0; i < chatlist.length; i++) {
        DocumentSnapshot chatsnapshot = await chats.doc(chatlist[i]).get();
        List iconurls = chatsnapshot["iconurl"];
        iconurls
            .removeWhere((element) => element == documentSnapshot['pfp_url']);
        iconurls.add(photoUrl);
        await chats.doc(chatlist[i]).update({'iconurl': iconurls});
      }
    } catch (e) {
      throw Exception();
    }
  }

  Future<String> uploadEventThumbnail(File filePath, String eventid) async {
    try {
      await uploadEventThumb(filePath, eventid);
      String photoUrl = await downloadEventThumbURL(eventid);
      return photoUrl;
      //String id = "";
      //await getUserDocID(uid).then((value) => id = value);
      //return users.doc(id).update({'pfp_url': photoUrl}).catchError((error) {
      //  throw Exception("Could not upload pfp");
      //});
    } catch (e) {
      throw Exception();
    }
  }

  Future changeattribute(String attribute, String value, String uid) async {
    String id = "";
    await getUserDocID(uid).then((value) => id = value);
    return users.doc(id).update({attribute: value}).catchError((error) {
      throw Exception("Could not change $attribute");
    });
  }

  Future changeattributebool(String attribute, bool value, String uid) async {
    String id = "";
    await getUserDocID(uid).then((value) => id = value);
    return users.doc(id).update({attribute: value}).catchError((error) {
      throw Exception("Could not change $attribute");
    });
  }

  Future changebirthday(DateTime value, String uid) async {
    String id = "";
    await getUserDocID(uid).then((value) => id = value);
    return users.doc(id).update({'birthday': value}).catchError((error) {
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
    return users.doc(id).update(
        {'username': username, 'searchfield': searchfield}).catchError((error) {
      throw Exception("Could not change username");
    });
  }

  Future changeinterests(String attribute, List interests, String uid) async {
    String id = "";
    await getUserDocID(uid).then((value) => id = value);
    return users.doc(id).update({attribute: interests}).catchError((error) {
      throw Exception("Could not change $attribute");
    });
  }

  Future uploadUserPFP(File filePath, String uid) async {
    try {
      await FirebaseStorage.instance
          .ref('/user_pfp/$uid.jpg')
          .putFile(filePath);
    } catch (e) {
      throw Exception();
    }
  }

  Future uploadEventThumb(File filePath, String eventid) async {
    try {
      await FirebaseStorage.instance
          .ref('/event_thumbnails/$eventid.jpg')
          .putFile(filePath);
    } catch (e) {
      throw Exception();
    }
  }

  Future<String> downloadUserPFPURL(String uid) async {
    try {
      String downloadUrl = await FirebaseStorage.instance
          .ref('/user_pfp/$uid.jpg')
          .getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Could not get download url");
    }
  }

  Future<String> downloadEventThumbURL(String eventid) async {
    try {
      String downloadUrl = await FirebaseStorage.instance
          .ref('/event_thumbnails/$eventid.jpg')
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

  bool checkitemslistcontainedinothersamelengthlist(List list1, List list2) {
    for (int i = 0; i < list1.length; i++) {
      if (!list2.contains(list1[i])) {
        return false;
      }
    }
    return true;
  }

  bool checkeventparticipantsequality(
      List docparticipants, List eventparticipants) {
    if (docparticipants.length == eventparticipants.length) {
      if (checkitemslistcontainedinothersamelengthlist(
          docparticipants, eventparticipants)) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
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
                  doc['address'] == event.address &&
                  doc['city'] == event.city &&
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

  Future<String> getUserUIDfromUsername(String username) async {
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
    bool unique = true;
    try {
      await users.get().then((QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach((doc) {
              if (doc["username"] == username) {
                unique = false;
              }
            })
          });
      return unique;
    } catch (e) {
      throw Exception("Could not connect");
    }
  }

  Future<bool> emailUnique(String email) async {
    bool unique = true;
    try {
      await users.get().then((QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach((doc) {
              if (doc["email"] == email) {
                unique = false;
              }
            })
          });
      return unique;
    } catch (e) {
      throw Exception("Could not connect");
    }
  }

  Future<bool> eventUnique(
    String title,
    String description,
    String interest,
    String country,
    String address,
    List city,
    String host,
    DateTime time,
  ) async {
    int instances = 0;
    try {
      await events.get().then((QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach((doc) {
              if (doc["title"] == title &&
                  doc['description'] == description &&
                  doc['interest'] == interest &&
                  doc['address'] == address &&
                  doc['country'] == country &&
                  listEquals(doc['city'], city) &&
                  doc['host'] == host &&
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

  Future<List<Event>> getCurrCityEvents(String city) async {
    try {
      QuerySnapshot querySnapshot = await events
          .orderBy('time')
          .startAfter([DateTime.now()])
          .where('city', arrayContainsAny: city.toLowerCase().split(" "))
          .get();
      List<Event> eventlist = [];
      querySnapshot.docs.forEach((element) {
        eventlist.add(Event.fromJson(element.data(), element.id));
      });
      return eventlist;
    } catch (e) {
      throw Exception("Could not connect");
    }
  }

  Future<List<Event>> getCurrCityEventsByInterest(
      String city, String interest) async {
    try {
      QuerySnapshot querySnapshot = await events
          .orderBy('time')
          .startAfter([DateTime.now()])
          .where('city', arrayContainsAny: city.toLowerCase().split(" "))
          .where('interest', isEqualTo: interest)
          .get();
      List<Event> eventlist = [];
      querySnapshot.docs.forEach((element) {
        eventlist.add(Event.fromJson(element.data(), element.id));
      });
      return eventlist;
    } catch (e) {
      throw Exception("Could not connect");
    }
  }

  Future<List<Event>> getCurrCityEventsByDate(
      String city, DateTime date) async {
    try {
      QuerySnapshot querySnapshot = await events
          .orderBy('time')
          .startAfter([date])
          .endBefore([DateTime(date.year, date.month, date.day + 1)])
          .where('city', arrayContains: city.toLowerCase())
          .get();
      List<Event> eventlist = [];
      querySnapshot.docs.forEach((element) {
        eventlist.add(Event.fromJson(element.data(), element.id));
      });
      return eventlist;
    } catch (e) {
      throw Exception("Could not connect");
    }
  }

  Future<List<Event>> getLngLatEvents(
      double lng, double lat, String country, AppUser curruser) async {
    try {
      //print(country);
      QuerySnapshot querySnapshot = await events
          .orderBy('time')
          .startAfter([DateTime.now()])
          .where('country', isEqualTo: country.toLowerCase())
          .where('isinviteonly', isEqualTo: false)
          .get();
      List<Event> tempeventlist = [];
      List<Event> eventlist = [];
      querySnapshot.docs.forEach((element) {
        tempeventlist.add(Event.fromJson(element.data(), element.id));
      });

      for (int i = 0; i < tempeventlist.length; i++) {
        if (curruser.blockedusers.contains(tempeventlist[i].hostdocid)) {
          continue;
        }
        if ((tempeventlist[i].lat < lat + 0.06 &&
            tempeventlist[i].lat > lat - 0.06 &&
            tempeventlist[i].lng < lng + 0.06 &&
            tempeventlist[i].lng > lng - 0.06)) {
          eventlist.add(tempeventlist[i]);
        }
      }
      return eventlist;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Event>> getProfileScreenJoinedEvents(
      AppUser user, bool showinviteonly) async {
    try {
      List<Event> joinedEvents = [];
      late QuerySnapshot querySnapshot;
      if (showinviteonly) {
        querySnapshot = await events
            .where('participants', arrayContains: user.uid)
            .orderBy('time')
            .get();
      } else {
        querySnapshot = await events
            .where('participants', arrayContains: user.uid)
            .where('isinviteonly', isEqualTo: showinviteonly)
            .orderBy('time')
            .get();
      }
      querySnapshot.docs.forEach((element) {
        joinedEvents.add(Event.fromJson(element.data(), element.id));
      });
      return joinedEvents;
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  Future<List<Event>> getProfileScreenHostedEvents(
      AppUser user, bool showinviteonly) async {
    try {
      List<Event> hostedEvents = [];
      late QuerySnapshot querySnapshot;
      if (showinviteonly) {
        querySnapshot = await events
            .where('hostdocid', isEqualTo: user.uid)
            .orderBy('time')
            .get();
      } else {
        querySnapshot = await events
            .where('hostdocid', isEqualTo: user.uid)
            .where('isinviteonly', isEqualTo: showinviteonly)
            .orderBy('time')
            .get();
      }
      querySnapshot.docs.forEach((element) {
        hostedEvents.add(Event.fromJson(element.data(), element.id));
      });
      return hostedEvents;
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  Future<List<Event>> getLngLatEventsByInterest(double lng, double lat,
      String interest, String country, AppUser curruser) async {
    try {
      QuerySnapshot querySnapshot = await events
          .orderBy('time')
          .startAfter([DateTime.now()])
          .where('country', isEqualTo: country.toLowerCase())
          .where('interest', isEqualTo: interest)
          .where('isinviteonly', isEqualTo: false)
          .get();
      List<Event> tempeventlist = [];
      List<Event> eventlist = [];
      querySnapshot.docs.forEach((element) {
        tempeventlist.add(Event.fromJson(element.data(), element.id));
      });

      for (int i = 0; i < tempeventlist.length; i++) {
        if (curruser.blockedusers.contains(tempeventlist[i].hostdocid)) {
          continue;
        }
        if ((tempeventlist[i].lat < lat + 0.06 &&
            tempeventlist[i].lat > lat - 0.06 &&
            tempeventlist[i].lng < lng + 0.06 &&
            tempeventlist[i].lng > lng - 0.06)) {
          eventlist.add(tempeventlist[i]);
        }
      }
      return eventlist;
    } catch (e) {
      throw Exception(e);
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

  Future<Chat> getChatfromDocId(String chatid) async {
    try {
      DocumentSnapshot documentSnapshot = await chats.doc(chatid).get();
      Chat chat = Chat.fromJson(documentSnapshot.data(), chatid);
      return chat;
    } catch (e) {
      throw Exception("Could not get chat");
    }
  }

  Future<List<Chat>> getChatsfromUserUID(String uid) async {
    try {
      QuerySnapshot querySnapshot = await chats
          .orderBy('lastmessagetime')
          .where('participants', arrayContains: uid)
          .get();
      List<Chat> chatlist = [];
      querySnapshot.docs.forEach((element) {
        chatlist.add(Chat.fromJson(element.data(), element.id));
      });
      return chatlist;
    } catch (e) {
      throw Exception();
    }
  }

  Future<List<Event>> searchEvents(String searchquery, AppUser curruser) async {
    try {
      QuerySnapshot querySnapshot = await events
          .orderBy('time')
          .startAfter([DateTime.now()])
          .where('searchfield', arrayContains: searchquery.toLowerCase())
          .where('isinviteonly', isEqualTo: false)
          .get();
      List<Event> eventsearchres = [];
      querySnapshot.docs.forEach((element) {
        Event event = Event.fromJson(element.data(), element.id);
        if (!curruser.blockedusers.contains(event.hostdocid)) {
          eventsearchres.add(event);
        }
      });
      return eventsearchres;
    } catch (e) {
      throw Exception("Could not search for events");
    }
  }

  Future<List<Event>> getLngLatEventsFilteredByDate(double lng, double lat,
      DateTime date, String country, AppUser curruser) async {
    try {
      QuerySnapshot querySnapshot = await events
          .orderBy('time')
          .startAfter([date])
          .endBefore([DateTime(date.year, date.month, date.day + 1)])
          .where('country', isEqualTo: country.toLowerCase())
          .where('isinviteonly', isEqualTo: false)
          .get();
      List<Event> tempeventlist = [];
      List<Event> eventlist = [];
      querySnapshot.docs.forEach((element) {
        tempeventlist.add(Event.fromJson(element.data(), element.id));
      });

      for (int i = 0; i < tempeventlist.length; i++) {
        if (curruser.blockedusers.contains(tempeventlist[i].hostdocid)) {
          continue;
        }
        if ((tempeventlist[i].lat < lat + 0.06 &&
            tempeventlist[i].lat > lat - 0.06 &&
            tempeventlist[i].lng < lng + 0.06 &&
            tempeventlist[i].lng > lng - 0.06)) {
          eventlist.add(tempeventlist[i]);
        }
      }
      return eventlist;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<AppUser>> searchUsers(
      String searchquery, AppUser curruser) async {
    try {
      QuerySnapshot querySnapshot = await users
          .where('searchfield', arrayContains: searchquery.toLowerCase())
          .getSavy();
      List<AppUser> usersearches = [];
      querySnapshot.docs.forEach((element) {
        if (!curruser.blockedusers.contains(element.id)) {
          usersearches.add(AppUser.fromJson(element.data(), element.id));
        }
      });

      return usersearches;
    } catch (e) {
      throw Exception("Could not search for users");
    }
  }

  Future<List<AppUser>> getAllUsersRankedByCloutScore() async {
    try {
      QuerySnapshot querySnapshot =
          await users.orderBy('clout', descending: true).get();
      List<AppUser> usersearches = [];
      querySnapshot.docs.forEach((element) {
        print(element.id);
        usersearches.add(AppUser.fromJson(element.data(), element.id));
      });

      return usersearches;
    } catch (e) {
      print(e);
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

  Future<AppUser> getUserFromUID(String docid) async {
    try {
      DocumentSnapshot documentSnapshot = await users.doc(docid).get();
      return AppUser.fromJson(documentSnapshot.data(), docid);
    } catch (e) {
      throw Exception("Could not retrieve user");
    }
  }

  Future<AppUser> getUserFromUIDSavy(String docid) async {
    try {
      DocumentSnapshot documentSnapshot = await users.doc(docid).getSavy();
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
      try {
        updates.add({
          'target': [userdocid],
          'description': "${curruserdoc['fullname']} started following you",
          'notification': "@${curruserdoc['username']} started following you",
          'eventid': "",
          'userid': curruserdocid,
          'type': 'followed'
        });
      } catch (e) {
        throw Exception();
      }
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

  saveDeviceToken(AppUser curruser) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      var tokenRef = users.doc(curruser.uid).collection('tokens').doc(fcmToken);
      await tokenRef.set({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem
      });
      await users.doc(curruser.uid).set({
        "tokens": FieldValue.arrayUnion([fcmToken])
      }, SetOptions(merge: true));
    }
  }

  Future<void> reportUser(AppUser user) async {
    bool unique = true;
    String? docid;
    int? instances;
    try {
      await report.get().then((QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach((doc) {
              if (doc["docid"] == user.uid && doc["type"] == "user") {
                unique = false;
                docid = doc.id;
                instances = doc["instances"];
              }
            })
          });
      if (unique) {
        report.add({"docid": user.uid, "type": "user", "instances": 1});
      } else {
        report.doc(docid!).update({"instances": instances! + 1});
      }
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> reportEvent(Event event) async {
    bool unique = true;
    String? docid;
    int? instances;
    try {
      await report.get().then((QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach((doc) {
              if (doc["docid"] == event.docid && doc["type"] == "event") {
                unique = false;
                docid = doc.id;
                instances = doc["instances"];
              }
            })
          });
      if (unique) {
        report.add({"docid": event.docid, "type": "event", "instances": 1});
      } else {
        report.doc(docid!).update({"instances": instances! + 1});
      }
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> blockUser(String curruserdocid, String userdocid) async {
    try {
      DocumentSnapshot curruserdoc = await users.doc(curruserdocid).get();
      DocumentSnapshot userdoc = await users.doc(userdocid).get();
      List blockedusers = curruserdoc['blocked_users'];
      List blockedby = userdoc['blocked_by'];
      List curruserfollowers = curruserdoc['followers'];
      List curruserfollowing = curruserdoc['following'];
      List userfollowers = userdoc['followers'];
      List userfollowing = userdoc['following'];
      List curruserjoinedevents = curruserdoc['joined_events'];
      List curruserhostedevents = curruserdoc['hosted_events'];
      List userjoinedevents = userdoc['joined_events'];
      List userhostedevents = userdoc['hosted_events'];
      blockedusers.add(userdocid);
      blockedby.add(curruserdocid);
      curruserfollowers.removeWhere((element) => element == userdocid);
      curruserfollowing.removeWhere((element) => element == userdocid);
      userfollowers.removeWhere((element) => element == curruserdocid);
      userfollowing.removeWhere((element) => element == curruserdocid);
      AppUser user = AppUser.fromJson(userdoc, userdocid);
      for (int i = 0; i < curruserhostedevents.length; i++) {
        if (userjoinedevents.contains(curruserhostedevents[i])) {
          DocumentSnapshot eventdoc =
              await events.doc(curruserhostedevents[i]).get();
          Event event = Event.fromJson(eventdoc, curruserhostedevents[i]);
          removeparticipant(user, event);
        }
      }
      AppUser curruser = AppUser.fromJson(curruserdoc, userdocid);
      for (int i = 0; i < curruserjoinedevents.length; i++) {
        if (userhostedevents.contains(curruserjoinedevents[i])) {
          DocumentSnapshot eventdoc =
              await events.doc(curruserjoinedevents[i]).get();
          Event event = Event.fromJson(eventdoc, curruserhostedevents[i]);
          leaveevent(curruser, event);
        }
      }
      users.doc(curruserdocid).update({
        'blocked_users': blockedusers,
        'followers': curruserfollowers,
        'following': curruserfollowing
      });
      users.doc(userdocid).update({
        'blocked_by': blockedby,
        'followers': userfollowers,
        'following': userfollowing
      });
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> unblockUser(String curruserdocid, String userdocid) async {
    try {
      DocumentSnapshot curruserdoc = await users.doc(curruserdocid).get();
      DocumentSnapshot userdoc = await users.doc(userdocid).get();
      List blockedusers = curruserdoc['blocked_users'];
      List blockedby = userdoc['blocked_by'];
      blockedusers.removeWhere((element) => element == userdocid);
      blockedby.removeWhere((element) => element == curruserdocid);
      users.doc(curruserdocid).update({'blocked_users': blockedusers});
      users.doc(userdocid).update({'blocked_by': blockedby});
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> addAttributetoAllDocuments() async {
    await chats.get().then(
          (value) => value.docs.forEach(
            (element) async {
              var docRef = FirebaseFirestore.instance
                  .collection('chats')
                  .doc(element.id);

              chats.doc(element.id).set(
                  {'lastmessagetime': DateTime.now()}, SetOptions(merge: true));
            },
          ),
        );
  }

  Future<void> editalldocids() async {
    await users.get().then(
          (value) => value.docs.forEach(
            (element) async {
              DocumentSnapshot doc = await users.doc(element.id).get();
              AppUser user = AppUser.fromJson(doc.data(), doc.id);
              List searchfield = [];
              String temp = "";
              for (int i = 0; i < user.username.length; i++) {
                temp = temp + user.username[i];
                searchfield.add(temp.toLowerCase());
              }
              QuerySnapshot query =
                  await users.doc(element.id).collection("tokens").get();
              List tokens = [];
              query.docs.forEach((element) {
                tokens.add(element.id);
              });
              users.doc(user.uid).set({
                'fullname': user.fullname,
                'email': user.email,
                'username': user.username,
                'uid': user.uid,
                'gender': user.gender,
                'nationality': user.nationality,
                'pfp_url': user.pfpurl,
                'birthday': user.birthday,
                'interests': user.interests,
                'hosted_events': user.hostedEvents,
                'joined_events': user.joinedEvents,
                'clout': user.clout,
                'searchfield': searchfield,
                'followers': user.followers,
                'following': user.following,
                'favorites': user.favorites,
                'bio': user.bio,
                'blocked_users': user.blockedusers,
                'blocked_by': user.blockedby,
                'chats': user.chats,
                'tokens': tokens
              });
              query.docs.forEach((token) async {
                dynamic data = token.data();
                var tokenRef =
                    users.doc(element.id).collection('tokens').doc(token.id);
                await tokenRef.set({
                  'token': token.id,
                  'createdAt': data['createdAt'],
                  'platform': data['platform']
                });
              });
            },
          ),
        );
  }

  Future sendmessage(String content, AppUser sender, String docid,
      String notititle, String type) async {
    try {
      String notification = "";
      if (type == "event") {
        notification = '${sender.username}: $content';
      } else {
        notification = content;
      }
      await chats.doc(docid).collection('messages').add({
        'content': content,
        'sender': sender.username,
        'senderuid': sender.uid,
        'timestamp': DateTime.now(),
        'notification': notification,
        'notititle': notititle,
      });
      return chats.doc(docid).set({
        'readby': [sender.uid],
        "lastmessagetime": DateTime.now()
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception();
    }
  }

  Stream<QuerySnapshot> retrievemessages(String docid) {
    return chats
        .doc(docid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> setReadReceipt(String chatid, String readerid) {
    return chats.doc(chatid).set({
      'readby': FieldValue.arrayUnion([readerid])
    }, SetOptions(merge: true));
  }

  Future<void> clearnotis(String docid) async {
    return users.doc(docid).update({"notifications": []}).catchError((error) {
      throw Exception();
    });
  }

  Future<void> createuserchat(AppUser curruser, String otheruserdocid) async {
    AppUser otheruser = await getUserFromUID(otheruserdocid);
    String chatid = "";
    await chats.add({
      "connectedid": [curruser.uid, otheruser.uid],
      "participants": [curruser.uid, otheruser.uid],
      "chatname": [curruser.username, otheruser.username],
      "iconurl": [curruser.pfpurl, otheruser.pfpurl],
      "mostrecentmessage": "",
      "type": "user",
      "readby": [],
      "lastmessagetime": DateTime.now()
    }).then((value) => chatid = value.id);
    await users.doc(curruser.uid).set({
      "chats": FieldValue.arrayUnion([chatid])
    }, SetOptions(merge: true));
    await users.doc(otheruser.uid).set({
      "chats": FieldValue.arrayUnion([chatid])
    }, SetOptions(merge: true));
  }

  Future<void> reportbug(String bug, String curruserid) async {
    try {
      await bugs.add({
        "bug": bug,
        "reported_by": curruserid,
        "time": FieldValue.serverTimestamp()
      });
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> setuserchatvisibility(
      AppUser curruser, String otheruserdocid, String chatid) async {
    try {
      AppUser otheruser = await getUserFromUID(otheruserdocid);
      QuerySnapshot querySnapshot =
          await chats.doc(chatid).collection("messages").get();
      if (querySnapshot.size > 0) {
        await users.doc(curruser.uid).set({
          "visiblechats": FieldValue.arrayUnion([chatid])
        }, SetOptions(merge: true));
        await users.doc(otheruser.uid).set({
          "visiblechats": FieldValue.arrayUnion([chatid])
        }, SetOptions(merge: true));
      } else {
        await deletechat(chatid);
      }
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> removeuserchatvisibility(AppUser curruser, String chatid) async {
    try {
      DocumentSnapshot chat = await chats.doc(chatid).get();
      await users.doc(curruser.uid).set({
        'visiblechats': FieldValue.arrayRemove([chatid])
      }, SetOptions(merge: true));
      List participants = chat['participants'];
      participants.removeWhere((element) => element == curruser.uid);
      String otheruserdocid = participants[0];
      DocumentSnapshot userdoc = await users.doc(otheruserdocid).get();
      List otheruserchatlist = userdoc['visiblechats'];
      if (!otheruserchatlist.contains(chatid)) {
        await deletechat(chatid);
      }
    } catch (e) {
      throw Exception();
    }
  }

  bool userchatparticipantsequality(
      List<dynamic> participants, String otheruserdocid, String curruserdocid) {
    return (participants.contains(otheruserdocid) &&
        participants.contains(curruserdocid));
  }

  Future<bool> checkuserchatexists(
      AppUser curruser, String otheruserdocid) async {
    int instances = 0;
    try {
      for (int i = 0; i < curruser.chats.length; i++) {
        DocumentSnapshot chatsnapshot =
            await chats.doc(curruser.chats[i]).get();
        if ((chatsnapshot['type'] == 'user') &&
            userchatparticipantsequality(
                chatsnapshot['participants'], otheruserdocid, curruser.uid)) {
          instances = instances + 1;
        }
      }
      return (instances == 1);
    } catch (e) {
      throw Exception();
    }
  }

  Future<Chat> getUserChatFromParticipants(
      AppUser curruser, String otheruserdocid) async {
    try {
      late Chat userchat;
      await chats.get().then((QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach((doc) {
              if ((doc['type'] == 'user') &&
                  userchatparticipantsequality(
                      doc['participants'], otheruserdocid, curruser.uid) &&
                  doc['participants'].length == 2) {
                userchat = Chat.fromJson(doc.data(), doc.id);
              }
            })
          });
      return userchat;
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> updatelastuserloc(String uid, double lat, double lng) async {
    try {
      await users.doc(uid).set(
          {'lastknownlat': lat, 'lastknownlng': lng}, SetOptions(merge: true));
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> resetnotificationcounter(String uid) async {
    try {
      await users.doc(uid).update({'notificationcounter': 0});
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> resetchatnotificationcounter(String uid) async {
    try {
      await users.doc(uid).update({'chatnotificationcounter': 0});
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> setpresence(
      String eventid, String useruid, String curruserid) async {
    try {
      await events.doc(eventid).set({
        "presentparticipants": FieldValue.arrayUnion([useruid])
      }, SetOptions(merge: true));
      await users
          .doc(useruid)
          .set({"clout": FieldValue.increment(10)}, SetOptions(merge: true));
      await users
          .doc(curruserid)
          .set({"clout": FieldValue.increment(5)}, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Could not validate, please try again");
    }
  }
}
