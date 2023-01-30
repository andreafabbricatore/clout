import 'package:clout/screens/signinscreen.dart';
import 'package:clout/screens/signupscreen.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class AuthScreen extends StatefulWidget {
  AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onLongPress: () {},
        child: Padding(
            padding: EdgeInsets.fromLTRB(screenwidth * 0.05, screenheight * 0.1,
                screenwidth * 0.05, screenheight * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenheight * 0.12),
                RichText(
                    textScaleFactor: 1.0,
                    text: TextSpan(
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(
                            text: "GET\n",
                          ),
                          TextSpan(
                              text: "Clout\n",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              )),
                          const TextSpan(
                            text: "GO\n",
                          ),
                          TextSpan(
                              text: "Out\n",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                        ])),
                SizedBox(height: screenheight * 0.08),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      },
                      child: SizedBox(
                          height: 50,
                          width: screenwidth * 0.5,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: const Center(
                                child: Text(
                              "Sign Up",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            )),
                          )),
                    )
                  ],
                ),
                SizedBox(
                  height: screenheight * 0.02,
                ),
                Center(
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInScreen()),
                          );
                        },
                        child: const Text(
                          "Already have an account?",
                          style: TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.underline),
                        )))
              ],
            )),
      ),
    );
  }
}
