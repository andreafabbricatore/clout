import 'package:clout/screens/authentication/signinscreen.dart';
import 'package:clout/screens/authentication/signupscreen.dart';
import 'package:clout/screens/unauthscreens/unauthloadingscreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({Key? key, required this.analytics}) : super(key: key);
  FirebaseAnalytics analytics;
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
            child: Stack(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenheight * 0.04),
                  RichText(
                      textScaleFactor: 1.0,
                      text: TextSpan(
                          style: const TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              fontFamily: "Archivo"),
                          children: [
                            const TextSpan(
                              text: "Get ",
                            ),
                            TextSpan(
                                text: "Clout,\n",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                )),
                            const TextSpan(
                              text: "Go ",
                            ),
                            TextSpan(
                                text: "Out!",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor)),
                          ])),
                  SizedBox(
                    height: screenheight * 0.4,
                    child: const RiveAnimation.asset(
                      'assets/images/rive/fun_time.riv',
                    ),
                  ),
                  SizedBox(height: screenheight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen(
                                      analytics: widget.analytics,
                                    ),
                                settings: RouteSettings(name: "SignUpScreen")),
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
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800),
                              )),
                            )),
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenheight * 0.02,
                  ),
                  Center(
                      child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInScreen(
                                        analytics: widget.analytics,
                                      ),
                                  settings:
                                      RouteSettings(name: "SignInScreen")),
                            );
                          },
                          child: Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ))),
                  SizedBox(
                    height: screenheight * 0.05,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UnAuthLoadingScreen(
                                    analytics: widget.analytics,
                                  ),
                              fullscreenDialog: true),
                        );
                      },
                      child: const Text(
                        "Continue as a Guest",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ])),
      ),
    );
  }
}
