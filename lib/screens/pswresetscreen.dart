import 'package:clout/components/datatextfield.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PswResetScreen extends StatefulWidget {
  PswResetScreen({Key? key}) : super(key: key);

  @override
  State<PswResetScreen> createState() => _PswResetScreenState();
}

class _PswResetScreenState extends State<PswResetScreen> {
  TextEditingController email = TextEditingController();
  bool resetbuttonpressed = false;
  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

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
                  onTap: resetbuttonpressed
                      ? null
                      : () async {
                          setState(() {
                            resetbuttonpressed = true;
                          });
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                                email: email.text.trim());
                            displayErrorSnackBar("Password Reset Email Sent");
                          } catch (e) {
                            displayErrorSnackBar(
                                "Could not send email, check internet connection or ensure email address is valid");
                          } finally {
                            setState(() {
                              resetbuttonpressed = false;
                            });
                          }
                        },
                  child: PrimaryButton(
                      screenwidth: screenwidth,
                      buttonpressed: resetbuttonpressed,
                      text: "Send Password Reset Email",
                      buttonwidth: screenwidth * 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}
