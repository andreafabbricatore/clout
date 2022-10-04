import 'package:cloud_firestore/cloud_firestore.dart';
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
        'favorites': [],
        'bio': '',
        'blocked_users': [],
        'blocked_by': []
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
        await unFollow(curruser.docid, userid);
      }
      //print("removed following");
      for (String userid in followers) {
        await unFollow(userid, curruser.docid);
      }
      //print("removed followers");
      await FirebaseStorage.instance
          .ref('/user_pfp/${curruser.uid}.jpg')
          .delete();
      //print("deleted pfp");
      return users.doc(curruser.docid).delete();
    } catch (e) {
      throw Exception("Could not delete user");
    }
  }

  Future createevent(Event newevent, AppUser curruser, var imagepath) async {
    try {
      String bannerUrl = "";
      List joinedEvents = curruser.joinedEvents;
      List hostedEvents = curruser.hostedEvents;
      bool customimage = false;
      int clout = curruser.clout;
      String eventid = "";
      bool unique = await eventUnique(
          newevent.title,
          newevent.description,
          newevent.interest,
          newevent.country,
          newevent.address,
          newevent.city,
          newevent.host,
          newevent.datetime,
          newevent.maxparticipants,
          [curruser.docid]);
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
          'participants': [curruser.docid],
          'image': "",
          'custom_image': false,
          'lat': newevent.lat,
          'lng': newevent.lng,
          'searchfield': searchfield
        }).then((value) {
          eventid = value.id;
        });
        joinedEvents.add(eventid);
        hostedEvents.add(eventid);
        if (imagepath == null) {
          bannerUrl = await downloadBannerUrl(newevent.interest);
        } else {
          customimage = true;
          bannerUrl = await uploadEventThumbnail(imagepath, eventid);
        }
        await events
            .doc(eventid)
            .update({'image': bannerUrl, 'custom_image': customimage});
        return users.doc(curruser.docid).update({
          'joined_events': joinedEvents,
          'hosted_events': hostedEvents,
          'clout': clout + 20
        }).catchError((error) {
          throw Exception("Could not host event");
        });
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
        'searchfield': searchfield
      });
      for (int i = 0; i < event.participants.length; i++) {
        if (event.participants[i] == event.hostdocid) {
        } else {
          updates.add({
            'target': event.participants[i],
            'title': 'Clout',
            'description': '${event.title} was modified. Check out the changes!'
          });
        }
      }
    } catch (e) {
      throw Exception();
    }
  }

  Future joinevent(Event event, AppUser curruser, String? eventid) async {
    try {
      DocumentSnapshot eventSnapshot = await events.doc(eventid).get();
      AppUser host = await getUserFromDocID(event.hostdocid);
      List participants = eventSnapshot['participants'];
      List joinedEvents = curruser.joinedEvents;
      if (participants.length + 1 > event.maxparticipants) {
        throw Exception("Too many participants");
      } else {
        joinedEvents.add(eventid);
        participants.add(curruser.docid);
        users.doc(curruser.docid).update({'joined_events': joinedEvents});
        users.doc(event.hostdocid).update({'clout': host.clout + 5});
        users.doc(curruser.docid).update({'clout': curruser.clout + 10});
        events.doc(eventid).update({'participants': participants});
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
            'target': event.hostdocid,
            'title': 'Clout',
            'description':
                '${curruser.fullname} joined your your event: ${event.title}'
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
      AppUser host = await getUserFromDocID(event.hostdocid);
      List participants = eventSnapshot['participants'];
      List joinedEvents = curruser.joinedEvents;
      if (participants.length == 1) {
        throw Exception("Cannot leave event");
      } else {
        joinedEvents.removeWhere((element) => element == event.docid);
        participants.removeWhere((element) => element == curruser.docid);
        users.doc(curruser.docid).update({'joined_events': joinedEvents});
        users.doc(event.hostdocid).update({'clout': host.clout - 5});
        users.doc(curruser.docid).update({'clout': curruser.clout - 10});
        events.doc(event.docid).update({'participants': participants});
      }
    } catch (e) {
      throw Exception("Could not leave event");
    }
  }

  Future removeparticipant(AppUser user, Event event) async {
    try {
      DocumentSnapshot eventSnapshot = await events.doc(event.docid).get();
      AppUser host = await getUserFromDocID(event.hostdocid);
      AppUser usertorem = await getUserFromDocID(user.docid);
      List participants = eventSnapshot['participants'];
      List joinedEvents = usertorem.joinedEvents;

      joinedEvents.removeWhere((element) => element == event.docid);
      participants.removeWhere((element) => element == user.docid);
      users.doc(user.docid).update({'joined_events': joinedEvents});
      events.doc(event.docid).update({'participants': participants});
      users.doc(event.hostdocid).update({'clout': host.clout - 5});
      users.doc(user.docid).update({'clout': usertorem.clout - 10});
      updates.add({
        'target': user.docid,
        'title': 'Clout',
        'description': 'You were kicked out of the event: ${event.title}'
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
        DocumentSnapshot documentSnapshot = await users.doc(x).get();
        List joinedEvents = documentSnapshot['joined_events'];
        int clout = documentSnapshot['clout'];
        if (x == host.docid) {
          List hostedEvents = documentSnapshot['hosted_events'];
          hostedEvents.removeWhere((element) => element == event.docid);
          users.doc(x).update({'hosted_events': hostedEvents});
          int decrease = (participants.length - 1) * 5 + 20;
          users.doc(x).update({'clout': clout - decrease});
        } else {
          users.doc(x).update({'clout': clout - 10});
        }
        joinedEvents.removeWhere((element) => element == event.docid);
        users.doc(x).update({'joined_events': joinedEvents});
      }
      if (eventSnapshot['custom_image']) {
        await FirebaseStorage.instance
            .ref('/event_thumbnails/${event.docid}.jpg')
            .delete();
      } else {}
      await events.doc(event.docid).delete();
    } catch (e) {
      throw Exception("Could not delete event");
    }
  }

  Future changepfp(File filePath, String uid) async {
    try {
      await uploadUserPFP(filePath, uid);
      String photoUrl = await downloadUserPFPURL(uid);
      String id = "";
      await getUserDocID(uid).then((value) => id = value);
      return users.doc(id).update({'pfp_url': photoUrl}).catchError((error) {
        throw Exception("Could not upload pfp");
      });
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
      int maxparticipants,
      List participants) async {
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
        if ((tempeventlist[i].lat < lat + 0.04 &&
            tempeventlist[i].lat > lat - 0.04 &&
            tempeventlist[i].lng < lng + 0.04 &&
            tempeventlist[i].lng > lng - 0.04)) {
          eventlist.add(tempeventlist[i]);
        }
      }
      return eventlist;
    } catch (e) {
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
        if ((tempeventlist[i].lat < lat + 0.04 &&
            tempeventlist[i].lat > lat - 0.04 &&
            tempeventlist[i].lng < lng + 0.04 &&
            tempeventlist[i].lng > lng - 0.04)) {
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

  Future<List<Event>> searchEvents(String searchquery, AppUser curruser) async {
    try {
      QuerySnapshot querySnapshot = await events
          .orderBy('time')
          .startAfter([DateTime.now()])
          .where('searchfield', arrayContains: searchquery.toLowerCase())
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
        if ((tempeventlist[i].lat < lat + 0.04 &&
            tempeventlist[i].lat > lat - 0.04 &&
            tempeventlist[i].lng < lng + 0.04 &&
            tempeventlist[i].lng > lng - 0.04)) {
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
          await users.orderBy('clout', descending: true).getSavy();
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
      try {
        updates.add({
          'target': userdocid,
          'title': "Clout",
          'description': "${curruserdoc['fullname']} started following you"
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
      var tokenRef =
          users.doc(curruser.docid).collection('tokens').doc(fcmToken);
      await tokenRef.set({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem
      });
    }
  }

  Future<void> reportUser(AppUser user) async {
    bool unique = true;
    String? docid;
    int? instances;
    try {
      await report.get().then((QuerySnapshot querySnapshot) => {
            querySnapshot.docs.forEach((doc) {
              if (doc["docid"] == user.docid && doc["type"] == "user") {
                unique = false;
                docid = doc.id;
                instances = doc["instances"];
              }
            })
          });
      if (unique) {
        report.add({"docid": user.docid, "type": "user", "instances": 1});
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
}
