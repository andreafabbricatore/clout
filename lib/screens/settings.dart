import 'package:clout/components/datatextfield.dart';
import 'package:clout/components/user.dart';
import 'package:clout/main.dart';
import 'package:clout/screens/authscreen.dart';
import 'package:clout/screens/blockedusersscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SetttingsScreen extends StatefulWidget {
  SetttingsScreen({Key? key, required this.curruser}) : super(key: key);
  AppUser curruser;

  @override
  State<SetttingsScreen> createState() => _SetttingsScreenState();
}

class _SetttingsScreenState extends State<SetttingsScreen> {
  db_conn db = db_conn();

  TextEditingController psw = TextEditingController();

  TextEditingController newpsw = TextEditingController();

  TextEditingController emailaddress = TextEditingController();

  bool deletebuttonpressed = false;
  bool updatepswbuttonpressed = false;
  bool updateemailbuttonpressed = false;

  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void goauthscreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthScreen(),
          fullscreenDialog: true),
    );
  }

  void goauthwrapper() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthenticationWrapper(),
          fullscreenDialog: true),
    );
  }

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
            onPressed: deletebuttonpressed
                ? null
                : () async {
                    setState(() {
                      deletebuttonpressed = true;
                    });
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: widget.curruser.email,
                          password: psw.text.trim());
                      await db.deleteuser(widget.curruser);
                      await FirebaseAuth.instance.currentUser!.delete();
                      goauthwrapper();
                    } catch (e) {
                      displayErrorSnackBar("Invalid Action, try again");
                    } finally {
                      setState(() {
                        deletebuttonpressed = false;
                      });
                    }
                  },
            child: const Text("Delete Account")),
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      ],
    );
    AlertDialog changeEmail = AlertDialog(
      title: const Text("Update Email Address"),
      content: SizedBox(
        height: screenheight * 0.25,
        child: Center(
          child: Column(
            children: [
              const Text(
                  "In order to change email address,\nenter new address and re-enter password"),
              SizedBox(
                height: screenheight * 0.02,
              ),
              textdatafield(screenwidth * 0.4, "New Email", emailaddress),
              textdatafield(screenwidth * 0.4, "Password", psw)
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: updateemailbuttonpressed
                ? null
                : () async {
                    setState(() {
                      updateemailbuttonpressed = true;
                    });
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: widget.curruser.email,
                          password: psw.text.trim());
                      if (emailaddress.text.trim().isEmpty) {
                        throw Exception("Please enter new email address");
                      }
                      await db.changeattribute(
                          'email',
                          emailaddress.text.trim(),
                          FirebaseAuth.instance.currentUser!.uid);
                      await FirebaseAuth.instance.currentUser!
                          .updateEmail(emailaddress.text.trim());
                      goauthwrapper();
                    } catch (e) {
                      displayErrorSnackBar("Invalid Action, try again");
                    } finally {
                      updateemailbuttonpressed = false;
                    }
                  },
            child: const Text("Update")),
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
    AlertDialog changePsw = AlertDialog(
      title: const Text("Update Password"),
      content: SizedBox(
        height: screenheight * 0.25,
        child: Center(
          child: Column(
            children: [
              const Text(
                  "In order to change password,\nenter old and new password"),
              SizedBox(
                height: screenheight * 0.02,
              ),
              textdatafield(screenwidth * 0.4, "Old Password", psw),
              textdatafield(screenwidth * 0.4, "New Password", newpsw)
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: updatepswbuttonpressed
                ? null
                : () async {
                    setState(() {
                      updatepswbuttonpressed = true;
                    });
                    try {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: widget.curruser.email,
                          password: psw.text.trim());
                      if (newpsw.text.trim().isEmpty) {
                        throw Exception("Please enter new password");
                      }
                      await FirebaseAuth.instance.currentUser!
                          .updatePassword(newpsw.text.trim());
                      goauthwrapper();
                    } catch (e) {
                      displayErrorSnackBar("Invalid Action, try again");
                    } finally {
                      setState(() {
                        updatepswbuttonpressed = false;
                      });
                    }
                  },
            child: const Text("Update")),
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
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
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return changeEmail;
                  });
            },
            child: Row(
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
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return changePsw;
                  });
            },
            child: Row(
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
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => BlockedUsersScreen(
                          curruser: widget.curruser,
                        )),
              );
            },
            child: Row(
              children: const [
                Icon(Icons.block, size: 30),
                SizedBox(
                  width: 6,
                ),
                Text(
                  "Blocked Users",
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
          ),
          SizedBox(
            height: screenheight * 0.04,
          ),
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              goauthwrapper();
            },
            child: const Text(
              "Log out",
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(255, 255, 48, 117)),
            ),
          ),
          SizedBox(
            height: screenheight * 0.55,
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
