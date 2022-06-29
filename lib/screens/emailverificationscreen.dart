import 'dart:async';

import 'package:clout/main.dart';
import 'package:clout/screens/authscreen.dart';
import 'package:clout/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
    } catch (e) {
      print("error with sending email");
    }
  }

  Future<void> checkemailverified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      try {
        isemailverified = FirebaseAuth.instance.currentUser!.emailVerified;
      } catch (e) {
        print("error here");
      }
    });

    if (isemailverified) {
      timer?.cancel();
    }
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Sent verification email\nIf you havent received it press below to send again",
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          )),
                        )),
                  ),
                ],
              ),
            ),
          );
  }
}
