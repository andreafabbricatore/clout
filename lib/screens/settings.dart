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
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.white,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                        height: screenheight * 0.4,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(children: [
                          const Text("Change Email",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25)),
                          SizedBox(
                            height: screenheight * 0.02,
                          ),
                          const Text(
                            "In order to change email address,\nenter new address and re-enter password",
                            style: TextStyle(
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: screenheight * 0.02,
                          ),
                          textdatafield(
                              screenwidth * 0.4, "New Email", emailaddress),
                          textdatafield(screenwidth * 0.4, "Password", psw),
                          SizedBox(
                            height: screenheight * 0.04,
                          ),
                          GestureDetector(
                            onTap: updateemailbuttonpressed
                                ? null
                                : () async {
                                    setState(() {
                                      updateemailbuttonpressed = true;
                                    });
                                    try {
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                              email: widget.curruser.email,
                                              password: psw.text.trim());
                                      if (emailaddress.text.trim().isEmpty) {
                                        throw Exception(
                                            "Please enter new email address");
                                      }
                                      await db.changeattribute(
                                          'email',
                                          emailaddress.text.trim(),
                                          FirebaseAuth
                                              .instance.currentUser!.uid);
                                      await FirebaseAuth.instance.currentUser!
                                          .updateEmail(
                                              emailaddress.text.trim());
                                      goauthwrapper();
                                    } catch (e) {
                                      displayErrorSnackBar(
                                          "Invalid Action, try again");
                                    } finally {
                                      updateemailbuttonpressed = false;
                                    }
                                  },
                            child: SizedBox(
                                height: 50,
                                width: screenwidth * 0.7,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 255, 48, 117),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: const Center(
                                      child: Text(
                                    "Update",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )),
                                )),
                          ),
                        ]),
                      ),
                    );
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
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                        height: screenheight * 0.4,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(children: [
                          const Text("Change Password",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25)),
                          SizedBox(
                            height: screenheight * 0.02,
                          ),
                          const Text(
                            "In order to change password,\nenter old and new password",
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(
                            height: screenheight * 0.02,
                          ),
                          textdatafield(screenwidth * 0.4, "Old Password", psw),
                          textdatafield(
                              screenwidth * 0.4, "New Password", newpsw),
                          SizedBox(
                            height: screenheight * 0.04,
                          ),
                          GestureDetector(
                            onTap: updatepswbuttonpressed
                                ? null
                                : () async {
                                    setState(() {
                                      updatepswbuttonpressed = true;
                                    });
                                    try {
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                              email: widget.curruser.email,
                                              password: psw.text.trim());
                                      if (newpsw.text.trim().isEmpty) {
                                        throw Exception(
                                            "Please enter new password");
                                      }
                                      await FirebaseAuth.instance.currentUser!
                                          .updatePassword(newpsw.text.trim());
                                      goauthwrapper();
                                    } catch (e) {
                                      displayErrorSnackBar(
                                          "Invalid Action, try again");
                                    } finally {
                                      setState(() {
                                        updatepswbuttonpressed = false;
                                      });
                                    }
                                  },
                            child: SizedBox(
                                height: 50,
                                width: screenwidth * 0.7,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 255, 48, 117),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: const Center(
                                      child: Text(
                                    "Update",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )),
                                )),
                          ),
                        ]),
                      ),
                    );
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
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                        height: screenheight * 0.25,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(children: [
                          const Text("Delete Account",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25)),
                          SizedBox(
                            height: screenheight * 0.02,
                          ),
                          const Text(
                            "Are you sure you want to permanently delete you account?",
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: screenheight * 0.02,
                          ),
                          SizedBox(
                            height: screenheight * 0.02,
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      backgroundColor: Colors.white,
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 20, 10, 10),
                                        height: screenheight * 0.35,
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: Column(children: [
                                          const Text("Delete Account",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 25)),
                                          SizedBox(
                                            height: screenheight * 0.02,
                                          ),
                                          const Text(
                                            "We hate to see you go...\nEnter Password to permamently delete your account",
                                            style: TextStyle(fontSize: 15),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(
                                            height: screenheight * 0.02,
                                          ),
                                          textdatafield(screenwidth * 0.4,
                                              "Enter Password", psw),
                                          SizedBox(
                                            height: screenheight * 0.04,
                                          ),
                                          GestureDetector(
                                            onTap: deletebuttonpressed
                                                ? null
                                                : () async {
                                                    setState(() {
                                                      deletebuttonpressed =
                                                          true;
                                                    });
                                                    try {
                                                      await FirebaseAuth
                                                          .instance
                                                          .signInWithEmailAndPassword(
                                                              email: widget
                                                                  .curruser
                                                                  .email,
                                                              password: psw.text
                                                                  .trim());
                                                      await db.deleteuser(
                                                          widget.curruser);
                                                      await FirebaseAuth
                                                          .instance.currentUser!
                                                          .delete();
                                                      goauthwrapper();
                                                    } catch (e) {
                                                      displayErrorSnackBar(
                                                          "Invalid Action, try again");
                                                    } finally {
                                                      setState(() {
                                                        deletebuttonpressed =
                                                            false;
                                                      });
                                                    }
                                                  },
                                            child: SizedBox(
                                                height: 50,
                                                width: screenwidth * 0.7,
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Color
                                                              .fromARGB(255,
                                                                  255, 48, 117),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                  child: const Center(
                                                      child: Text(
                                                    "Delete Account :(",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white),
                                                  )),
                                                )),
                                          ),
                                        ]),
                                      ),
                                    );
                                  });
                            },
                            child: SizedBox(
                                height: 50,
                                width: screenwidth * 0.7,
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 255, 48, 117),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: const Center(
                                      child: Text(
                                    "Delete Account",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )),
                                )),
                          ),
                        ]),
                      ),
                    );
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
