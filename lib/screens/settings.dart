import 'package:clout/components/datatextfield.dart';
import 'package:clout/components/user.dart';
import 'package:clout/main.dart';
import 'package:clout/screens/authscreen.dart';
import 'package:clout/screens/loading.dart';
import 'package:clout/services/auth.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetttingsScreen extends StatelessWidget {
  SetttingsScreen({Key? key, required this.curruser}) : super(key: key);
  AppUser curruser;
  db_conn db = db_conn();
  TextEditingController psw = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    AlertDialog pswalert = AlertDialog(
      title: const Text("Re-enter password"),
      content: SizedBox(
        height: screenheight * 0.15,
        child: Center(
          child: Column(
            children: [
              const Text("In order to delete account, re-enter password"),
              SizedBox(
                height: screenheight * 0.02,
              ),
              textdatafield(screenwidth * 0.4, "Password", psw)
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Delete Account"),
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: curruser.email, password: psw.text.trim());
              await FirebaseAuth.instance.currentUser!.delete();
              await db.deleteuser(curruser);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => AuthenticationWrapper()),
              );
            } catch (e) {
              print(e);
            }
          },
        ),
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Delete Account"),
      content: const Text(
          "Are you sure you want to permanently delete your account?"),
      actions: [
        TextButton(
          child: const Text("Delete Account"),
          onPressed: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return pswalert;
                });
          },
        ),
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
        child: ListView(children: [
          SizedBox(
            height: screenheight * 0.02,
          ),
          Row(
            children: const [
              Icon(Icons.email_outlined, size: 30),
              SizedBox(
                width: 6,
              ),
              Text(
                "Update Email Address",
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Row(
            children: const [
              Icon(Icons.lock_outline, size: 30),
              SizedBox(
                width: 6,
              ),
              Text(
                "Update Password",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          SizedBox(
            height: screenheight * 0.04,
          ),
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => AuthenticationWrapper()),
              );
            },
            child: const Text(
              "Log out",
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(255, 255, 48, 117)),
            ),
          ),
          SizedBox(
            height: screenheight * 0.6,
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  });
            },
            child: const Center(
              child: Text(
                "Delete Account",
                style: TextStyle(
                    fontSize: 20, color: Color.fromARGB(255, 255, 48, 117)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
