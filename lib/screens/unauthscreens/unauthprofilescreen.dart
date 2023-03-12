import 'package:clout/screens/authentication/authscreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnAuthProfileScreen extends StatelessWidget {
  UnAuthProfileScreen(
      {super.key, required this.analytics, required this.visit});
  FirebaseAnalytics analytics;
  bool visit;
  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: visit
            ? GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            : const SizedBox(
                width: 0,
                height: 0,
              ),
        centerTitle: true,
        title: Text(
          "Profile",
          textScaleFactor: 1.0,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        shape: const Border(
            bottom: BorderSide(color: Color.fromARGB(55, 158, 158, 158))),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Center(
          child: Text(
            "Login or Signup to continue",
            style: TextStyle(fontSize: 20),
          ),
        ),
        SizedBox(
          height: screenheight * 0.04,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AuthScreen(
                        analytics: analytics,
                      ),
                  fullscreenDialog: true),
            );
          },
          child: Center(
            child: SizedBox(
                height: 50,
                width: screenwidth * 0.5,
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: const Center(
                      child: Text(
                    "Continue",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w800),
                  )),
                )),
          ),
        )
      ]),
    );
  }
}
