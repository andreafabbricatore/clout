import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
          padding: EdgeInsets.fromLTRB(screenwidth * 0.05, screenheight * 0.1,
              screenwidth * 0.05, screenheight * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenheight * 0.15),
              Text(
                "GET\nCLOUT\nGO\nOUT",
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenheight * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 50,
                      width: screenwidth * 0.5,
                      child: Container(
                        child: Center(
                            child: Text(
                          "SIGN UP",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 48, 117),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                      )),
                ],
              )
            ],
          )),
    );
  }
}
