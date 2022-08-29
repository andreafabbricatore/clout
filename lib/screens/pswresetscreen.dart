import 'package:clout/components/datatextfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PswResetScreen extends StatelessWidget {
  PswResetScreen({Key? key}) : super(key: key);

  TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    void displayErrorSnackBar(String error) async {
      final snackBar = SnackBar(
        content: Text(error),
        duration: const Duration(seconds: 2),
      );
      await Future.delayed(const Duration(milliseconds: 400));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 255, 48, 117),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Please enter the email address associated with your account",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: screenheight * 0.02,
              ),
              textdatafield(screenwidth, "e.g. timcook@gmail.com", email),
              SizedBox(
                height: screenheight * 0.03,
              ),
              InkWell(
                onTap: () async {
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email.text.trim());
                    displayErrorSnackBar("Password Reset Email Sent");
                  } catch (e) {
                    displayErrorSnackBar(
                        "Could not send email, check internet connection or ensure email address is valid");
                  }
                },
                child: SizedBox(
                    height: 50,
                    width: screenwidth * 0.8,
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 255, 48, 117),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: const Center(
                          child: Text(
                        "Send Password Reset Email",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        textScaleFactor: 1.1,
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
