import 'package:clout/components/primarybutton.dart';
import 'package:clout/main.dart';
import 'package:clout/screens/pswresetscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  db_conn db = db_conn();
  final emailController = TextEditingController();
  final pswController = TextEditingController();

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

  void donesignin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthenticationWrapper(),
          fullscreenDialog: true),
    );
  }

  bool signinbuttonpressed = false;

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Clout",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontFamily: "Kristi",
              fontWeight: FontWeight.w500,
              fontSize: 50),
          textScaleFactor: 1.0,
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 48, 117))),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: screenheight * 0.2,
            ),
            const Center(
                child: Text(
              "Email Address",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 20),
            )),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenwidth * 0.2),
                child: TextField(
                  decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 48, 117))),
                      hintText: 'e.g. timcook@gmail.com',
                      hintStyle: TextStyle(color: Color.fromARGB(39, 0, 0, 0))),
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  enableSuggestions: false,
                  autocorrect: false,
                ),
              ),
            ),
            SizedBox(height: screenheight * 0.02),
            const Center(
                child: Text(
              "Password",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 20),
            )),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenwidth * 0.2),
                child: TextField(
                  decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 48, 117))),
                      hintText: 'e.g. supersecret',
                      hintStyle: TextStyle(color: Color.fromARGB(39, 0, 0, 0))),
                  controller: pswController,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  textAlign: TextAlign.center,
                  enableSuggestions: false,
                  autocorrect: false,
                ),
              ),
            ),
            SizedBox(height: screenheight * 0.02),
            InkWell(
                onTap: signinbuttonpressed
                    ? null
                    : () async {
                        try {
                          setState(() {
                            signinbuttonpressed = true;
                          });
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: pswController.text.trim());
                          donesignin();
                        } catch (e) {
                          displayErrorSnackBar("Could not Sign in");
                        } finally {
                          setState(() {
                            signinbuttonpressed = false;
                          });
                        }
                      },
                child: PrimaryButton(
                  screenwidth: screenwidth,
                  buttonwidth: screenwidth * 0.5,
                  buttonpressed: signinbuttonpressed,
                  text: "Sign In",
                )),
            SizedBox(height: screenheight * 0.02),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => PswResetScreen()),
                );
              },
              child: const Center(
                child: Text("Forgot password?"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
