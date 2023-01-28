import 'dart:async';

import 'package:clout/components/primarybutton.dart';
import 'package:clout/components/user.dart';
import 'package:clout/main.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:clout/components/datatextfield.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isemailverified = false;
  bool deletebuttonpressed = false;
  bool sendbuttonpressed = false;
  Timer? timer;
  TextEditingController psw = TextEditingController();
  db_conn db = db_conn();

  Future<void> sendverificationemail() async {
    await FirebaseAuth.instance.currentUser!.sendEmailVerification();
  }

  Future<void> checkemailverified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isemailverified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isemailverified) {
      timer?.cancel();
    }
  }

  void displayErrorSnackBar(
    String error,
  ) {
    final snackBar = SnackBar(
      content: Text(
        error,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color.fromARGB(230, 255, 48, 117),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: false,
      closeIconColor: Colors.white,
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void goauthwrapper() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthenticationWrapper(),
          fullscreenDialog: true),
    );
  }

  void checker() {
    if (!isemailverified) {
      sendverificationemail();
    }
    timer =
        Timer.periodic(const Duration(seconds: 3), (_) => checkemailverified());
  }

  @override
  void initState() {
    super.initState();
    checker();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
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
                      String userid = await db.getUserDocIDfromUID(
                          FirebaseAuth.instance.currentUser!.uid);
                      AppUser curruser = await db.getUserFromUID(userid);
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: curruser.email, password: psw.text.trim());
                      await db.deleteuser(curruser);
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
            checker();
          },
        ),
      ],
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Cancel Sign Up"),
      content: const Text("Are you sure you want to cancel sign up?"),
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
            checker();
          },
        ),
      ],
    );

    return isemailverified
        ? AuthenticationWrapper()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: screenheight * 0.3,
                    ),
                    Center(
                        child: Text(
                      "Sent verification email to: \n${FirebaseAuth.instance.currentUser!.email}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.0,
                    )),
                    SizedBox(
                      height: screenheight * 0.02,
                    ),
                    const Center(
                        child: Text(
                      "Press below to send again",
                      style: TextStyle(fontSize: 15),
                      textScaleFactor: 1.0,
                    )),
                    SizedBox(
                      height: screenheight * 0.02,
                    ),
                    Center(
                        child: InkWell(
                            onTap: sendbuttonpressed
                                ? null
                                : () {
                                    setState(() {
                                      sendbuttonpressed = true;
                                    });
                                    sendverificationemail();
                                    setState(() {
                                      sendbuttonpressed = false;
                                    });
                                  },
                            child: PrimaryButton(
                                screenwidth: screenwidth,
                                buttonpressed: sendbuttonpressed,
                                text: "Resend Email",
                                buttonwidth: screenwidth * 0.6))),
                    SizedBox(
                      height: screenheight * 0.35,
                    ),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.justify,
                        textScaleFactor: 1.0,
                        text: TextSpan(
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 15),
                            children: [
                              const TextSpan(text: "Wrong Email? "),
                              TextSpan(
                                  text: "Cancel Sign Up",
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 255, 48, 117)),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      timer?.cancel();
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alert;
                                          });
                                    }),
                            ]),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
}
