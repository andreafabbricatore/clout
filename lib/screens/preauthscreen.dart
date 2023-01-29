import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:clout/screens/authscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PreAuthScreen extends StatefulWidget {
  @override
  State<PreAuthScreen> createState() => _PreAuthScreenState();
}

class _PreAuthScreenState extends State<PreAuthScreen> {
  //PreAuthScreen({super.key});
  final controller = PageController(initialPage: 0);
  bool buttonpressed = false;
  int currpage = 1;
  void gotoauthscreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AuthScreen(), fullscreenDialog: true),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        PageView(
          onPageChanged: (index) {
            setState(() {
              currpage = index;
            });
          },
          controller: controller,
          children: [const Page1(), Page2(), const Page3()],
        ),
        SizedBox(
            height: screenheight,
            width: screenwidth,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SmoothPageIndicator(
                    controller: controller,
                    count: 3,
                    effect: const ExpandingDotsEffect(
                        dotWidth: 10,
                        dotHeight: 10,
                        dotColor: Color.fromARGB(130, 255, 48, 117),
                        activeDotColor: Color.fromARGB(255, 255, 48, 117)),
                    onDotClicked: (index) {
                      controller.jumpToPage(index);
                    },
                  ),
                  SizedBox(
                    height: currpage == 2
                        ? screenheight * 0.05
                        : screenheight * 0.05 + 32,
                  ),
                  GestureDetector(
                    onTap: currpage == 2
                        ? () {
                            setState(() {
                              buttonpressed = true;
                            });
                            if (buttonpressed) {
                              gotoauthscreen();
                            }
                            setState(() {
                              buttonpressed = false;
                            });
                          }
                        : () {
                            controller.jumpToPage(2);
                          },
                    child: currpage == 2
                        ? PrimaryButton(
                            screenwidth: screenwidth,
                            buttonpressed: buttonpressed,
                            text: "Continue",
                            buttonwidth: screenwidth * 0.5)
                        : const Text(
                            "Skip",
                            style: TextStyle(
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                                color: Colors.grey),
                            textScaleFactor: 1.0,
                          ),
                  ),
                  SizedBox(
                    height: screenheight * 0.05,
                  )
                ],
              ),
            )),
      ],
    );
  }
}

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: screenheight,
        width: screenwidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: screenheight * 0.1,
            ),
            SizedBox(
              height: screenheight * 0.5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/images/preauthscreen/bored.png"),
              ),
            ),
            SizedBox(
              height: screenheight * 0.035,
            ),
            RichText(
              textAlign: TextAlign.start,
              text: const TextSpan(
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Feeling ",
                    ),
                    TextSpan(
                        text: "bored",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    TextSpan(text: "?\n"),
                    TextSpan(
                        text: "Find ",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    TextSpan(
                      text: "something to do,\n",
                    ),
                    TextSpan(text: "Make "),
                    TextSpan(
                        text: "new friends",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    TextSpan(text: ".")
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class Page2 extends StatefulWidget {
  Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  List<String> passions = [
    "touching kids",
    "playing football",
    "drowning in pools",
    "partying hard",
    "caressing grass"
  ];
  String passion = "touching kids";
  int index = 0;
  Timer? timer;

  void updatepassion() {
    setState(() {
      if (index == passions.length - 1) {
        index = -1;
      }
      index += 1;
      passion = passions[index];
    });
  }

  @override
  void initState() {
    const oneSec = Duration(milliseconds: 2000);
    timer = Timer.periodic(oneSec, (Timer t) => updatepassion());
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: screenheight,
        width: screenwidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: screenheight * 0.1,
            ),
            SizedBox(
              height: screenheight * 0.5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/images/preauthscreen/skaters.png"),
              ),
            ),
            SizedBox(
              height: screenheight * 0.035,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black),
                  children: [
                    const TextSpan(text: "Like "),
                    TextSpan(
                        text: passion,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    const TextSpan(text: "?\nSomeone "),
                    const TextSpan(
                        text: "near you\n",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    const TextSpan(
                        text: "wants to",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    const TextSpan(text: " do that too.")
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: screenheight,
        width: screenwidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: screenheight * 0.1,
            ),
            SizedBox(
              height: screenheight * 0.5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/images/preauthscreen/walking.png"),
              ),
            ),
            SizedBox(
              height: screenheight * 0.035,
            ),
            RichText(
              textAlign: TextAlign.end,
              text: const TextSpan(
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Let's have ",
                    ),
                    TextSpan(
                        text: "real",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    TextSpan(
                        text: " fun",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    TextSpan(text: ".\n"),
                    TextSpan(
                        text: "Join",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    TextSpan(text: " or "),
                    TextSpan(
                        text: "Host",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    TextSpan(text: " an Event,\n"),
                    TextSpan(
                      text: "Get Clout, ",
                    ),
                    TextSpan(
                        text: "Go Out!",
                        style:
                            TextStyle(color: Color.fromARGB(255, 255, 48, 117)))
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
