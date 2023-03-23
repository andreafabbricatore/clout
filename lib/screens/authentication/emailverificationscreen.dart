import 'dart:async';

import 'package:clout/components/primarybutton.dart';
import 'package:clout/main.dart';
import 'package:clout/screens/authentication/authscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:clout/components/datatextfield.dart';

class EmailVerificationScreen extends StatefulWidget {
  EmailVerificationScreen({Key? key, required this.analytics})
      : super(key: key);
  FirebaseAnalytics analytics;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isemailverified = false;
  bool cancelbuttonpressed = false;
  bool sendbuttonpressed = false;
  Timer? timer;
  TextEditingController psw = TextEditingController();
  db_conn db = db_conn();
  String sendagain = "Press below to send";
  String sendbuttontext = "Send Email";

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

  void checker() {
    timer =
        Timer.periodic(const Duration(seconds: 3), (_) => checkemailverified());
  }

  void goauthscreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthScreen(
                analytics: widget.analytics,
              ),
          fullscreenDialog: true,
          settings: RouteSettings(name: "AuthScreen")),
    );
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

    return isemailverified
        ? AuthenticationWrapper(
            analytics: widget.analytics,
          )
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
                      "Verification for:\n${FirebaseAuth.instance.currentUser!.email}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.0,
                    )),
                    SizedBox(
                      height: screenheight * 0.02,
                    ),
                    Center(
                        child: Text(
                      sendagain,
                      style: const TextStyle(fontSize: 15),
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
                                      sendagain = "Press below to send again";
                                      sendbuttontext = "Resend email";
                                      sendbuttonpressed = false;
                                    });
                                  },
                            child: PrimaryButton(
                              screenwidth: screenwidth,
                              buttonpressed: sendbuttonpressed,
                              text: sendbuttontext,
                              buttonwidth: screenwidth * 0.6,
                              bold: false,
                            ))),
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
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      timer?.cancel();
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                              builder: (BuildContext context,
                                                  setState) {
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  backgroundColor: Colors.white,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        10, 20, 10, 10),
                                                    height: screenheight * 0.35,
                                                    decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                    child: Column(children: [
                                                      const Text(
                                                          "Cancel Sign Up",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 25)),
                                                      SizedBox(
                                                        height:
                                                            screenheight * 0.02,
                                                      ),
                                                      const Text(
                                                        "Enter password to cancel Sign Up.",
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            screenheight * 0.02,
                                                      ),
                                                      textdatafield(
                                                          screenwidth * 0.4,
                                                          "Enter Password",
                                                          psw),
                                                      SizedBox(
                                                        height:
                                                            screenheight * 0.04,
                                                      ),
                                                      GestureDetector(
                                                          onTap:
                                                              cancelbuttonpressed
                                                                  ? null
                                                                  : () async {
                                                                      setState(
                                                                          () {
                                                                        cancelbuttonpressed =
                                                                            true;
                                                                      });
                                                                      try {
                                                                        String
                                                                            email =
                                                                            FirebaseAuth.instance.currentUser!.email ??
                                                                                "";
                                                                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                                                                            email:
                                                                                email,
                                                                            password:
                                                                                psw.text.trim());
                                                                        await db.cancelsignup(FirebaseAuth
                                                                            .instance
                                                                            .currentUser!
                                                                            .uid);
                                                                        await FirebaseAuth
                                                                            .instance
                                                                            .currentUser!
                                                                            .delete();
                                                                        psw.clear();
                                                                        psw.dispose();
                                                                      } catch (e) {
                                                                        displayErrorSnackBar(
                                                                            "Could not cancel signup, please try again and makes sure password is correct");
                                                                      } finally {
                                                                        setState(
                                                                            () {
                                                                          cancelbuttonpressed =
                                                                              false;
                                                                        });
                                                                        goauthscreen();
                                                                      }
                                                                    },
                                                          child: PrimaryButton(
                                                              screenwidth:
                                                                  screenwidth,
                                                              buttonpressed:
                                                                  cancelbuttonpressed,
                                                              text:
                                                                  "Cancel Sign Up",
                                                              buttonwidth:
                                                                  screenwidth *
                                                                      0.7,
                                                              bold: false)),
                                                    ]),
                                                  ),
                                                );
                                              },
                                            );
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