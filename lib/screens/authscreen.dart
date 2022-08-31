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
  List allinterests = [
    "Sports",
    "Music",
    "Dance",
    "Movies",
    "Singing",
    "Drinking",
    "Art"
  ];
  int chosenindex = 0;

  void chooseBackground() {
    Random rnd = Random();
    int r = 0 + rnd.nextInt(allinterests.length);
    setState(() {
      chosenindex = r;
    });
  }

  @override
  void initState() {
    super.initState();
    chooseBackground();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPress: () {
          chooseBackground();
          setState(() {});
        },
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      "assets/images/interestbanners/${allinterests[chosenindex].toString().toLowerCase()}.jpeg"),
                  fit: BoxFit.cover,
                  opacity: 0.7)),
          child: Padding(
              padding: EdgeInsets.fromLTRB(screenwidth * 0.05,
                  screenheight * 0.1, screenwidth * 0.05, screenheight * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenheight * 0.15),
                  const Text(
                    "GET\nCLOUT\nGO\nOUT",
                    style: TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textScaleFactor: 1.0,
                  ),
                  SizedBox(height: screenheight * 0.1),
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
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 255, 48, 117),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: const Center(
                                  child: Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
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
                          child: Container(
                            color: const Color.fromARGB(35, 255, 48, 117),
                            child: const Text(
                              "Already have an account?",
                              style: TextStyle(color: Colors.white),
                            ),
                          )))
                ],
              )),
        ),
      ),
    );
  }
}
