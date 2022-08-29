import 'package:clout/screens/signinscreen.dart';
import 'package:clout/screens/signupscreen.dart';
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
              const Text(
                "GET\nCLOUT\nGO\nOUT",
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
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
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
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
                            style: TextStyle(fontSize: 20, color: Colors.white),
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
                      child: const Text("Already have an account?")))
            ],
          )),
    );
  }
}
