import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class db_conn {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

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
        'interests': []
      });
    } catch (e) {
      return Future.error("Could not Sign Up");
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
}
