import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clout/defs/chat.dart';
import 'package:clout/defs/event.dart';
import 'package:clout/defs/location.dart';
import 'package:clout/defs/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  CollectionReference maintenance =
      FirebaseFirestore.instance.collection('maintenance');
  CollectionReference appupdate =
      FirebaseFirestore.instance.collection('appupdate');
  CollectionReference emailverification =
      FirebaseFirestore.instance.collection('email_verification');
  final geo = GeoFlutterFire();

  Future createuserinstance(String uid) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      GeoFirePoint loc = geo.point(latitude: 0, longitude: 0);
      await users.doc(uid).set({
        'fullname': '',
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
        'friends': [],
        'requested': [],
        'requestedby': [],
        'favorites': [],
        'bio': '',
        'blocked_users': [],
        'blocked_by': [],
        'chats': [],
        'visiblechats': [],
        'tokens': [],
        'notifications': [],
        'referred': [],
        'referredby': [],
        'plan': 'userfree',
        'setnameandpfp': false,
        'setusername': false,
        'setmisc': false,
        'setinterests': false,
        'incompletewebsignup': false,
        'lastknownloc': loc.data,
        'lastknownlat': 0.1,
        'lastknownlng': 0.1,
        'notificationcounter': 0,
        'chatnotificationcounter': 0,
        'appversion': packageInfo.version,
        'donesignuptime': DateTime(1900, 1, 1, 0, 0),
        'lastusagetime': FieldValue.serverTimestamp(),
        'followed_businesses': [],
        'email': ''
      });
    } catch (e) {
      throw Exception("Could not create user");
    }
  }

  Future createbusinessinstance(String uid, String email) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      GeoFirePoint loc = geo.point(latitude: 0, longitude: 0);
      await users.doc(uid).set({
        'fullname': '',
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
        'friends': [],
        'requested': [],
        'requestedby': [],
        'favorites': [],
        'bio': '',
        'blocked_users': [],
        'blocked_by': [],
        'chats': [],
        'visiblechats': [],
        'tokens': [],
        'notifications': [],
        'referred': [],
        'referredby': [],
        'plan': 'business',
        'setnameandpfp': false,
        'setusername': false,
        'setmisc': false,
        'setinterests': false,
        'incompletewebsignup': false,
        'lastknownloc': loc.data,
        'lastknownlat': 0.1,
        'lastknownlng': 0.1,
        'notificationcounter': 0,
        'chatnotificationcounter': 0,
        'appversion': packageInfo.version,
        'donesignuptime': DateTime(1900, 1, 1, 0, 0),
        'lastusagetime': FieldValue.serverTimestamp(),
        'email': email
      });
    } catch (e) {
      throw Exception("Could not create user");
    }
  }

  Future<void> setdonesignuptime(String curruseruid) async {
    try {
      await users.doc(curruseruid).set(
          {"donesignuptime": FieldValue.serverTimestamp()},
          SetOptions(merge: true));
    } catch (e) {
      throw Exception();
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
      throw Exception();
    }
  }

  Future deleteuser(AppUser curruser) async {
    try {
      DocumentSnapshot userSnapshot = await users.doc(curruser.uid).get();
      List joinedEvents = userSnapshot['joined_events'];
      List hostedEvents = userSnapshot['hosted_events'];
      List friends = userSnapshot['friends'];
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
      for (String userid in friends) {
        await removefriend(curruser.uid, userid);
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
        GeoFirePoint loc =
            geo.point(latitude: newevent.lat, longitude: newevent.lng);
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
          'presentparticipants': newevent.presentparticipants,
          'favoritedby': [],
          'showparticipants': newevent.showparticipants,
          'showlocation': newevent.showlocation,
          'loc': loc.data,
          'paid': newevent.paid,
          'fee': newevent.fee,
          'currency': newevent.currency,
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
          'timestamp': DateTime.now(),
          "type": "text"
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
        if (!event.customimage) {
          bannerUrl = await downloadBannerUrl(event.interest);
        } else {
          bannerUrl = oldEventSnapshot['image'];
        }
      } else {
        bannerUrl = await uploadEventThumbnail(imagepath, event.docid);
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
      GeoFirePoint loc = geo.point(latitude: event.lat, longitude: event.lng);
      events.doc(event.docid).update({
        'title': event.title,
        'description': event.description,
        'interest': event.interest,
        'country': event.country,
        'address': event.address,
        'city': event.city,
        'time': event.datetime,
        'maxparticipants': event.maxparticipants,
        'custom_image': event.customimage,
        'image': bannerUrl,
        'lat': event.lat,
        'lng': event.lng,
        'searchfield': searchfield,
        'isinviteonly': event.isinviteonly,
        'showparticipants': event.showparticipants,
        'showlocation': event.showlocation,
        'loc': loc.data,
      });
      chats.doc(event.chatid).update({
        "chatname": [event.title]
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
          if (event.showparticipants) {
            chats.doc(event.chatid).collection('messages').add({
              'content': "${curruser.username} joined the event",
              'sender': 'server',
              'timestamp': DateTime.now(),
              "type": "text"
            });
            chats.doc(event.chatid).update({
              'mostrecentmessage': "${curruser.username} joined the event",
              "lastmessagetime": DateTime.now()
            });
          }
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
        if (event.showparticipants) {
          chats.doc(event.chatid).collection('messages').add({
            'content': "${curruser.username} left the event",
            'sender': 'server',
            'timestamp': DateTime.now(),
            "type": "text"
          });
          chats.doc(event.chatid).update({
            'mostrecentmessage': "${curruser.username} left the event",
            "lastmessagetime": DateTime.now()
          });
        }
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
      if (event.showparticipants) {
        chats.doc(event.chatid).collection('messages').add({
          'content': "${user.username} was removed from the event",
          'sender': 'server',
          'timestamp': DateTime.now(),
          "type": "text"
        });
        chats.doc(event.chatid).update({
          'mostrecentmessage': "${user.username} was removed from the event",
          "lastmessagetime": DateTime.now()
        });
      }
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
          'joined_events': FieldValue.arrayRemove([event.docid]),
        }, SetOptions(merge: true));
      }
      List favoritedby = eventSnapshot['favoritedby'];
      for (String x in favoritedby) {
        users.doc(x).set({
          'favorites': FieldValue.arrayRemove([event.docid]),
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
      participants.removeWhere((element) => element == event.hostdocid);
      await updates.add({
        'target': participants,
        'description': '${event.title} was deleted.',
        'notification': '${event.title} was deleted.',
        'eventid': event.docid,
        'userid': host.uid,
        'cronjobid': eventSnapshot['cronjobid'],
        'type': 'deleted'
      });
    } catch (e) {
      throw Exception("Could not delete event");
    }
  }

  Future deletefutureevent(Event event, AppUser host) async {
    try {
      DocumentSnapshot eventSnapshot = await events.doc(event.docid).get();
      List participants = eventSnapshot['participants'];
      for (String x in participants) {
        if (x == host.uid) {
          int decrease = 5 * (event.presentparticipants.length - 1) + 20;
          users.doc(x).set({
            'hosted_events': FieldValue.arrayRemove([event.docid]),
            'chats': FieldValue.arrayRemove([event.chatid]),
            'visiblechats': FieldValue.arrayRemove([event.chatid]),
            'clout': FieldValue.increment(-decrease),
          }, SetOptions(merge: true));
        } else {
          if (event.presentparticipants.contains(x)) {
            users.doc(x).set(
                {'clout': FieldValue.increment(-10)}, SetOptions(merge: true));
          }
        }
        users.doc(x).set({
          'joined_events': FieldValue.arrayRemove(
            [event.docid],
          )
        }, SetOptions(merge: true));
      }
      List favoritedby = eventSnapshot['favoritedby'];
      for (String x in favoritedby) {
        users.doc(x).set({
          'favorites': FieldValue.arrayRemove([event.docid]),
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
      participants.removeWhere((element) => element == event.hostdocid);
      await updates.add({
        'target': participants,
        'description': '${event.title} was deleted.',
        'notification': '${event.title} was deleted.',
        'eventid': event.docid,
        'userid': host.uid,
        'cronjobid': eventSnapshot['cronjobid'],
        'type': 'deleted'
      });
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
          'chats': FieldValue.arrayRemove([chatid]),
          'visiblechats': FieldValue.arrayRemove([chatid]),
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
    return users.doc(uid).update({attribute: value}).catchError((error) {
      throw Exception("Could not change $attribute");
    });
  }

  Future changeattributebool(String attribute, bool value, String uid) async {
    return users.doc(uid).update({attribute: value}).catchError((error) {
      throw Exception("Could not change $attribute");
    });
  }

  Future changebirthday(DateTime value, String uid) async {
    return users.doc(uid).update({'birthday': value}).catchError((error) {
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
    return users.doc(uid).update(
        {'username': username, 'searchfield': searchfield}).catchError((error) {
      throw Exception("Could not change username");
    });
  }

  Future changeinterests(String attribute, List interests, String uid) async {
    return users.doc(uid).update({attribute: interests}).catchError((error) {
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

  Future<bool> usernameUnique(String username) async {
    try {
      QuerySnapshot querySnapshot =
          await users.where("username", isEqualTo: username).get();

      return querySnapshot.docs.length == 0;
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

  Future<List<Event>> getLngLatEvents(
      double lng, double lat, AppUser curruser) async {
    try {
      GeoFirePoint center = GeoFirePoint(lat, lng);
      Stream<List<DocumentSnapshot>> stream = geo
          .collection(
              collectionRef: events.where('isinviteonly', isEqualTo: false))
          .within(center: center, radius: 10, field: 'loc');
      List<Event> res = [];
      stream.listen((List<DocumentSnapshot> documentList) {
        for (int i = 0; i < documentList.length; i++) {
          if (DateTime.now().isBefore(documentList[i]['time'].toDate())) {
            if (!curruser.blockedusers.contains(documentList[i]['hostdocid'])) {
              res.add(Event.fromJson(documentList[i], documentList[i].id));
            }
          }
        }
      });
      await Future.delayed(const Duration(milliseconds: 50));
      return res;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Event>> getLngLatEventsold(
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
        if ((tempeventlist[i].lat < lat + 0.14 &&
            tempeventlist[i].lat > lat - 0.14 &&
            tempeventlist[i].lng < lng + 0.14 &&
            tempeventlist[i].lng > lng - 0.14)) {
          eventlist.add(tempeventlist[i]);
        }
      }
      return eventlist;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Event>> UnAuthgetLngLatEvents(double lng, double lat) async {
    try {
      GeoFirePoint center = GeoFirePoint(lat, lng);
      Stream<List<DocumentSnapshot>> stream = geo
          .collection(
              collectionRef: events.where('isinviteonly', isEqualTo: false))
          .within(center: center, radius: 10, field: 'loc');
      List<Event> res = [];
      stream.listen((List<DocumentSnapshot> documentList) {
        for (int i = 0; i < documentList.length; i++) {
          if (DateTime.now().isBefore(documentList[i]['time'].toDate())) {
            res.add(Event.fromJson(documentList[i], documentList[i].id));
          }
        }
      });
      await Future.delayed(const Duration(milliseconds: 50));
      return res;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Event>> UnAuthgetLngLatEventsold(
      double lng, double lat, String country) async {
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
        if ((tempeventlist[i].lat < lat + 0.14 &&
            tempeventlist[i].lat > lat - 0.14 &&
            tempeventlist[i].lng < lng + 0.14 &&
            tempeventlist[i].lng > lng - 0.14)) {
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
      throw Exception(e);
    }
  }

  Future<List<AppUser>> getfriendslist(AppUser user) async {
    try {
      List<AppUser> friends = [];
      List<List<dynamic>> subList = [];
      for (var i = 0; i < user.friends.length; i += 10) {
        subList.add(user.friends.sublist(
            i, i + 10 > user.friends.length ? user.friends.length : i + 10));
      }

      for (int i = 0; i < subList.length; i++) {
        QuerySnapshot temp =
            await users.where("uid", whereIn: subList[i]).get();
        for (int j = 0; j < temp.docs.length; j++) {
          friends.add(AppUser.fromJson(temp.docs[j].data(), temp.docs[j].id));
        }
      }

      await Future.delayed(Duration(milliseconds: 50));
      return friends;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<AppUser>> getrequestbylist(AppUser user) async {
    try {
      List<AppUser> requestedby = [];
      List<List<dynamic>> subList = [];
      for (var i = 0; i < user.requestedby.length; i += 10) {
        subList.add(user.requestedby.sublist(
            i,
            i + 10 > user.requestedby.length
                ? user.requestedby.length
                : i + 10));
      }

      for (int i = 0; i < subList.length; i++) {
        QuerySnapshot temp =
            await users.where("uid", whereIn: subList[i]).get();
        for (int j = 0; j < temp.docs.length; j++) {
          requestedby
              .add(AppUser.fromJson(temp.docs[j].data(), temp.docs[j].id));
        }
      }

      await Future.delayed(Duration(milliseconds: 50));
      return requestedby;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<AppUser>> geteventparticipantslist(Event event) async {
    try {
      List<AppUser> participants = [];
      List<List<dynamic>> subList = [];
      for (var i = 0; i < event.participants.length; i += 10) {
        subList.add(event.participants.sublist(
            i,
            i + 10 > event.participants.length
                ? event.participants.length
                : i + 10));
      }
      for (int i = 0; i < subList.length; i++) {
        QuerySnapshot temp =
            await users.where("uid", whereIn: subList[i]).get();
        for (int j = 0; j < temp.docs.length; j++) {
          participants
              .add(AppUser.fromJson(temp.docs[j].data(), temp.docs[j].id));
        }
      }
      await Future.delayed(Duration(milliseconds: 50));
      return participants;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Event>> getLngLatEventsByInterest(
      double lng, double lat, String interest, AppUser curruser) async {
    try {
      GeoFirePoint center = GeoFirePoint(lat, lng);
      Stream<List<DocumentSnapshot>> stream = geo
          .collection(
              collectionRef: events
                  .where('isinviteonly', isEqualTo: false)
                  .where('interest', isEqualTo: interest))
          .within(center: center, radius: 10, field: 'loc');
      List<Event> res = [];
      stream.listen((List<DocumentSnapshot> documentList) {
        for (int i = 0; i < documentList.length; i++) {
          if (DateTime.now().isBefore(documentList[i]['time'].toDate())) {
            if (!curruser.blockedusers.contains(documentList[i]['hostdocid'])) {
              res.add(Event.fromJson(documentList[i], documentList[i].id));
            }
          }
        }
      });
      await Future.delayed(const Duration(milliseconds: 50));
      return res;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Event>> getLngLatEventsByInterestold(double lng, double lat,
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
        if ((tempeventlist[i].lat < lat + 0.14 &&
            tempeventlist[i].lat > lat - 0.14 &&
            tempeventlist[i].lng < lng + 0.14 &&
            tempeventlist[i].lng > lng - 0.14)) {
          eventlist.add(tempeventlist[i]);
        }
      }
      return eventlist;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Event>> UnAuthgetLngLatEventsByInterest(
      double lng, double lat, String interest) async {
    try {
      GeoFirePoint center = GeoFirePoint(lat, lng);
      Stream<List<DocumentSnapshot>> stream = geo
          .collection(
              collectionRef: events
                  .where('isinviteonly', isEqualTo: false)
                  .where('interest', isEqualTo: interest))
          .within(center: center, radius: 10, field: 'loc');
      List<Event> res = [];
      stream.listen((List<DocumentSnapshot> documentList) {
        for (int i = 0; i < documentList.length; i++) {
          if (DateTime.now().isBefore(documentList[i]['time'].toDate())) {
            res.add(Event.fromJson(documentList[i], documentList[i].id));
          }
        }
      });
      await Future.delayed(const Duration(milliseconds: 50));
      return res;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Event>> UnAuthgetLngLatEventsByInterestold(
      double lng, double lat, String interest, String country) async {
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
        if ((tempeventlist[i].lat < lat + 0.14 &&
            tempeventlist[i].lat > lat - 0.14 &&
            tempeventlist[i].lng < lng + 0.14 &&
            tempeventlist[i].lng > lng - 0.14)) {
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

  Future<List<Event>> UnAuthsearchEvents(String searchquery) async {
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
        eventsearchres.add(event);
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
        if ((tempeventlist[i].lat < lat + 0.14 &&
            tempeventlist[i].lat > lat - 0.14 &&
            tempeventlist[i].lng < lng + 0.14 &&
            tempeventlist[i].lng > lng - 0.14)) {
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
          .get();
      List<AppUser> usersearches = [];
      querySnapshot.docs.forEach((element) {
        if (!curruser.blockedusers.contains(element.id)) {
          usersearches.add(AppUser.fromJson(element.data(), element.id));
        }
      });

      return usersearches;
    } catch (e) {
      print(e);
      throw Exception("Could not search for users");
    }
  }

  Future<List<AppUser>> UnAuthsearchUsers(String searchquery) async {
    try {
      QuerySnapshot querySnapshot = await users
          .where('searchfield', arrayContains: searchquery.toLowerCase())
          .get();
      List<AppUser> usersearches = [];
      querySnapshot.docs.forEach((element) {
        usersearches.add(AppUser.fromJson(element.data(), element.id));
      });

      return usersearches;
    } catch (e) {
      throw Exception("Could not search for users");
    }
  }

  Future<List<AppUser>> getAllUsersRankedByCloutScore() async {
    try {
      QuerySnapshot querySnapshot = await users
          .where("setinterests", isNotEqualTo: false)
          .orderBy("setinterests")
          .orderBy('clout', descending: true)
          .limit(30)
          .get();
      List<AppUser> usersearches = [];
      querySnapshot.docs.forEach((element) {
        if (element['plan'] != "business") {
          usersearches.add(AppUser.fromJson(element.data(), element.id));
        }
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

  Future<AppUser> getUserFromUID(String docid) async {
    try {
      DocumentSnapshot documentSnapshot = await users.doc(docid).get();
      await Future.delayed(const Duration(milliseconds: 50));
      return AppUser.fromJson(documentSnapshot.data(), docid);
    } catch (e) {
      throw Exception("Could not retrieve user");
    }
  }

  Future<void> sendfriendrequest(String curruserdocid, String userdocid) async {
    try {
      DocumentSnapshot curruserdoc = await users.doc(curruserdocid).get();
      users.doc(curruserdocid).set({
        'requested': FieldValue.arrayUnion([userdocid])
      }, SetOptions(merge: true));
      users.doc(userdocid).set({
        'requestedby': FieldValue.arrayUnion([curruserdocid])
      }, SetOptions(merge: true));
      try {
        updates.add({
          'target': [userdocid],
          'description':
              "${curruserdoc['fullname']} sent you a friend request.",
          'notification':
              "@${curruserdoc['username']} sent you a friend request.",
          'eventid': "",
          'userid': curruserdocid,
          'type': 'friend_request'
        });
      } catch (e) {
        throw Exception();
      }
    } catch (e) {
      throw Exception("Could not send friend request.");
    }
  }

  Future<void> removefriendrequest(
      String curruserdocid, String userdocid) async {
    try {
      users.doc(curruserdocid).set({
        'requested': FieldValue.arrayRemove([userdocid])
      }, SetOptions(merge: true));
      users.doc(userdocid).set({
        'requestedby': FieldValue.arrayRemove([curruserdocid])
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Could not remove friend request.");
    }
  }

  Future<void> acceptfriendrequest(
      String curruserdocid, String userdocid) async {
    try {
      DocumentSnapshot curruserdoc = await users.doc(curruserdocid).get();
      users.doc(curruserdocid).set({
        'friends': FieldValue.arrayUnion([userdocid]),
        'requestedby': FieldValue.arrayRemove([userdocid])
      }, SetOptions(merge: true));
      users.doc(userdocid).set({
        'friends': FieldValue.arrayUnion([curruserdocid]),
        'requested': FieldValue.arrayRemove([curruserdocid])
      }, SetOptions(merge: true));
      try {
        updates.add({
          'target': [userdocid],
          'description':
              "${curruserdoc['fullname']} accepted your friend request.",
          'notification':
              "@${curruserdoc['username']} accepted your friend request.",
          'eventid': "",
          'userid': curruserdocid,
          'type': 'accept_friend_request'
        });
      } catch (e) {
        throw Exception();
      }
    } catch (e) {
      throw Exception("Could not follow");
    }
  }

  Future<void> denyfriendrequest(String curruserdocid, String userdocid) async {
    try {
      users.doc(curruserdocid).set({
        'requestedby': FieldValue.arrayRemove([userdocid])
      }, SetOptions(merge: true));
      users.doc(userdocid).set({
        'requested': FieldValue.arrayRemove([curruserdocid])
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Could not deny friend request.");
    }
  }

  Future<void> removefriend(String curruserdocid, String userdocid) async {
    try {
      users.doc(curruserdocid).set({
        'friends': FieldValue.arrayRemove([userdocid])
      }, SetOptions(merge: true));
      users.doc(userdocid).set({
        'friends': FieldValue.arrayRemove([curruserdocid])
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Could not remove friend.");
    }
  }

  Future<void> unfollowbusiness(String curruserdocid, String userdocid) async {
    try {
      users.doc(curruserdocid).set({
        'followed_businesses': FieldValue.arrayRemove([userdocid])
      }, SetOptions(merge: true));
      users.doc(userdocid).set({
        'friends': FieldValue.arrayRemove([curruserdocid])
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Could not unfollow.");
    }
  }

  Future<void> followbusiness(String curruserdocid, String userdocid) async {
    try {
      users.doc(curruserdocid).set({
        'followed_businesses': FieldValue.arrayUnion([userdocid])
      }, SetOptions(merge: true));
      users.doc(userdocid).set({
        'friends': FieldValue.arrayUnion([curruserdocid])
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Could not follow.");
    }
  }

  Future<void> addToFav(String curruserdocid, String eventid) async {
    try {
      DocumentSnapshot curruserdoc = await users.doc(curruserdocid).get();
      List favorites = curruserdoc['favorites'];
      favorites.add(eventid);
      users.doc(curruserdocid).update({'favorites': favorites});
      events.doc(eventid).set({
        'favoritedby': FieldValue.arrayUnion([curruserdocid])
      }, SetOptions(merge: true));
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
      events.doc(eventid).set({
        'favoritedby': FieldValue.arrayRemove([curruserdocid])
      }, SetOptions(merge: true));
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
      List curruserjoinedevents = curruserdoc['joined_events'];
      List curruserhostedevents = curruserdoc['hosted_events'];
      List userjoinedevents = userdoc['joined_events'];
      List userhostedevents = userdoc['hosted_events'];
      AppUser user = AppUser.fromJson(userdoc, userdocid);
      for (int i = 0; i < curruserhostedevents.length; i++) {
        if (userjoinedevents.contains(curruserhostedevents[i])) {
          DocumentSnapshot eventdoc =
              await events.doc(curruserhostedevents[i]).get();
          Event event =
              Event.fromJson(eventdoc.data(), curruserhostedevents[i]);
          removeparticipant(user, event);
        }
      }
      AppUser curruser = AppUser.fromJson(curruserdoc, userdocid);
      for (int i = 0; i < curruserjoinedevents.length; i++) {
        if (userhostedevents.contains(curruserjoinedevents[i])) {
          DocumentSnapshot eventdoc =
              await events.doc(curruserjoinedevents[i]).get();

          Event event =
              Event.fromJson(eventdoc.data(), curruserhostedevents[i]);
          leaveevent(curruser, event);
        }
      }
      users.doc(curruserdocid).set({
        'blocked_users': FieldValue.arrayUnion([userdocid]),
        'friends': FieldValue.arrayRemove([userdocid]),
      }, SetOptions(merge: true));
      users.doc(userdocid).set({
        'blocked_by': FieldValue.arrayUnion([curruserdocid]),
        'friends': FieldValue.arrayRemove([curruserdocid]),
      }, SetOptions(merge: true));
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
    await users.get().then(
          (value) => value.docs.forEach(
            (element) async {
              await users
                  .doc(element.id)
                  .set({'incompletewebsignup': false}, SetOptions(merge: true));
            },
          ),
        );
  }

  Future<void> addeventAttributetoAllDocuments() async {
    await events.get().then(
          (value) => value.docs.forEach(
            (element) async {
              await events.doc(element.id).set(
                  {'paid': false, 'currency': '', 'fee': 0},
                  SetOptions(merge: true));
            },
          ),
        );
  }

  Future<void> addstripeAttributetoAllDocuments() async {
    await users.get().then(
          (value) => value.docs.forEach(
            (element) async {
              await users.doc(element.id).set({
                'stripe_account_id': '',
                'stripe_seller_country': '',
              }, SetOptions(merge: true));
            },
          ),
        );
  }

  Future<void> addlocAttributetoAllDocuments() async {
    await users.get().then(
          (value) => value.docs.forEach(
            (element) async {
              GeoFirePoint lastknownloc = geo.point(
                  latitude: element['lastknownlat'],
                  longitude: element['lastknownlng']);
              await users.doc(element.id).set({
                'lastknownloc': lastknownloc.data,
              }, SetOptions(merge: true));
            },
          ),
        );
  }

  Future sendmessage(
      String content,
      AppUser sender,
      String docid,
      String notititle,
      String type,
      String messagetype,
      String bannerurl,
      String eventtitle,
      DateTime date) async {
    try {
      String notification = "";
      if (type == "event") {
        notification = '${sender.username}: $content';
      } else {
        if (messagetype == "event") {
          notification = "shared an event.";
        } else {
          notification = content;
        }
      }
      if (messagetype != "event") {
        await chats.doc(docid).collection('messages').add({
          'content': content,
          'sender': sender.username,
          'senderuid': sender.uid,
          'timestamp': DateTime.now(),
          'notification': notification,
          'notititle': notititle,
          'type': messagetype
        });
      } else {
        await chats.doc(docid).collection('messages').add({
          'content': content,
          'sender': sender.username,
          'senderuid': sender.uid,
          'timestamp': DateTime.now(),
          'notification': notification,
          'notititle': notititle,
          'banner_url': bannerurl,
          'event_title': eventtitle,
          'date': date,
          'type': messagetype
        });
      }
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

  Future<List<AppUser>> retrievefriendsformap(
      AppUser curruser, double lat, double lng) async {
    GeoFirePoint center = GeoFirePoint(lat, lng);
    try {
      if (curruser.friends.isEmpty) {
        return <AppUser>[];
      } else {
        List<AppUser> res = [];
        List<List<dynamic>> subList = [];
        for (var i = 0; i < curruser.friends.length; i += 10) {
          subList.add(curruser.friends.sublist(
              i,
              i + 10 > curruser.friends.length
                  ? curruser.friends.length
                  : i + 10));
        }

        for (int i = 0; i < subList.length; i++) {
          Stream<List<DocumentSnapshot>> stream = geo
              .collection(
                  collectionRef: users.where('uid', whereIn: subList[i]))
              .within(center: center, radius: 10, field: 'lastknownloc');

          stream.listen((List<DocumentSnapshot> documentList) {
            for (int i = 0; i < documentList.length; i++) {
              res.add(AppUser.fromJson(documentList[i], documentList[i].id));
            }
          });
        }
        await Future.delayed(const Duration(milliseconds: 50));
        return res;
      }
    } catch (e) {
      throw Exception();
    }
  }

  Future<List<Event>> retrieveeventsformap(double lat, double lng) async {
    try {
      GeoFirePoint center = GeoFirePoint(lat, lng);
      Stream<List<DocumentSnapshot>> stream = geo
          .collection(
              collectionRef: events.where('isinviteonly', isEqualTo: false))
          .within(center: center, radius: 10, field: 'loc');
      List<Event> res = [];
      stream.listen((List<DocumentSnapshot> documentList) {
        for (int i = 0; i < documentList.length; i++) {
          if (DateTime.now().isBefore(documentList[i]['time'].toDate())) {
            res.add(Event.fromJson(documentList[i], documentList[i].id));
          }
        }
      });
      await Future.delayed(const Duration(milliseconds: 50));
      return res;
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> setReadReceipt(String chatid, String readerid) {
    return chats.doc(chatid).set({
      'readby': FieldValue.arrayUnion([readerid])
    }, SetOptions(merge: true));
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
      String curruserid, String otheruserdocid) async {
    int instances = 0;
    try {
      DocumentSnapshot currusersnapshot = await users.doc(curruserid).get();
      List chatlist = currusersnapshot['chats'];
      for (int i = 0; i < chatlist.length; i++) {
        DocumentSnapshot chatsnapshot = await chats.doc(chatlist[i]).get();
        if ((chatsnapshot['type'] == 'user') &&
            userchatparticipantsequality(
                chatsnapshot['participants'], otheruserdocid, curruserid)) {
          instances = instances + 1;
        }
      }
      return (instances == 1);
    } catch (e) {
      throw Exception();
    }
  }

  Future<Chat> getUserChatFromParticipants(
      String curruserid, String otheruserdocid) async {
    try {
      late Chat userchat;
      DocumentSnapshot currusersnapshot = await users.doc(curruserid).get();
      List chatlist = currusersnapshot['chats'];
      for (int i = 0; i < chatlist.length; i++) {
        DocumentSnapshot chatsnapshot = await chats.doc(chatlist[i]).get();
        if ((chatsnapshot['type'] == 'user') &&
            userchatparticipantsequality(
                chatsnapshot['participants'], otheruserdocid, curruserid)) {
          userchat = Chat.fromJson(chatsnapshot.data(), chatsnapshot.id);
        }
      }

      return userchat;
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> updatelastuserlocandusage(
      String uid, double lat, double lng, AppUser curruser) async {
    try {
      GeoFirePoint lastknownloc = geo.point(latitude: lat, longitude: lng);
      curruser.plan == "business"
          ? await users.doc(uid).set(
              {'lastusagetime': FieldValue.serverTimestamp()},
              SetOptions(merge: true))
          : await users.doc(uid).set({
              'lastknownloc': lastknownloc.data,
              'lastknownlat': lat,
              'lastknownlng': lng,
              'lastusagetime': FieldValue.serverTimestamp()
            }, SetOptions(merge: true));
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> businesssetloc(String uid, AppLocation businesslocation) async {
    try {
      GeoFirePoint businessloc = geo.point(
          latitude: businesslocation.center[0],
          longitude: businesslocation.center[1]);
      await users.doc(uid).set({
        'lastknownloc': businessloc.data,
        'lastknownlat': businesslocation.center[0],
        'lastknownlng': businesslocation.center[1],
        'bio': businesslocation.address
      }, SetOptions(merge: true));
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

  Future<bool> undermaintenance() async {
    try {
      QuerySnapshot querySnapshot = await maintenance.get();
      bool maintenancestatus = false;
      querySnapshot.docs.forEach((element) {
        maintenancestatus = element['maintenance_status'];
      });
      return maintenancestatus;
    } catch (e) {
      throw Exception("Could not pull maintenance status");
    }
  }

  Future<bool> checkversionandneedupdate(String uid) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      await users
          .doc(uid)
          .set({"appversion": packageInfo.version}, SetOptions(merge: true));
      QuerySnapshot querySnapshot = await appupdate.get();
      bool needupdatestatus = false;
      List requiredversion = [];
      querySnapshot.docs.forEach((element) {
        needupdatestatus = element['need_update_status'];
        requiredversion = element['app_version'];
      });
      return (needupdatestatus &&
          !requiredversion.contains(packageInfo.version));
    } catch (e) {
      throw Exception("Could not pull update status");
    }
  }

  Future<bool> unauthcheckversionandneedupdate() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      QuerySnapshot querySnapshot = await appupdate.get();
      bool needupdatestatus = false;
      List requiredversion = [];
      querySnapshot.docs.forEach((element) {
        needupdatestatus = element['need_update_status'];
        requiredversion = element['app_version'];
      });
      return (needupdatestatus &&
          !requiredversion.contains(packageInfo.version));
    } catch (e) {
      throw Exception("Could not pull update status");
    }
  }

  Future<void> referralcloutinc(String referreduid, String shareruid) async {
    try {
      DocumentSnapshot referredsnapshot = await users.doc(referreduid).get();
      int referredlength = referredsnapshot['referredby'].length;
      if (referredlength < 1) {
        await users.doc(referreduid).set({
          "clout": FieldValue.increment(20),
          "referredby": FieldValue.arrayUnion([shareruid])
        }, SetOptions(merge: true));
        await users.doc(shareruid).set({
          "clout": FieldValue.increment(30),
          "referred": FieldValue.arrayUnion([referreduid])
        }, SetOptions(merge: true));
      } else {
        throw Exception();
      }
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> forceverifyemail(String curruserid) async {
    try {
      await emailverification
          .doc(curruserid)
          .set({'time': FieldValue.serverTimestamp()});
    } catch (e) {
      throw Exception();
    }
  }

  Future<List<String>> getsellerdetails(String uid) async {
    try {
      DocumentSnapshot user = await users.doc(uid).get();
      return [user['stripe_account_id'], user['stripe_seller_country']];
    } catch (e) {
      throw Exception();
    }
  }
}
