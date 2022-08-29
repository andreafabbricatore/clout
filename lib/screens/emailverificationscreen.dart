import 'dart:async';

import 'package:clout/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isemailverified = false;
  Timer? timer;

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

  void displayErrorSnackBar(String error) async {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    await Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    if (!isemailverified) {
      sendverificationemail();
    }
    timer =
        Timer.periodic(const Duration(seconds: 3), (_) => checkemailverified());
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
        ? AuthenticationWrapper()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sent verification email to: \n${FirebaseAuth.instance.currentUser!.email}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: screenheight * 0.02,
                    ),
                    const Text(
                      "Press below to send again",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: screenheight * 0.02,
                    ),
                    InkWell(
                      onTap: () {
                        sendverificationemail();
                      },
                      child: SizedBox(
                          height: 50,
                          width: screenwidth * 0.6,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 255, 48, 117),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: const Center(
                                child: Text(
                              "Resend Email",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            )),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
