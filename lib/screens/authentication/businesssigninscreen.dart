import 'package:clout/components/primarybutton.dart';
import 'package:clout/main.dart';
import 'package:clout/screens/authentication/pswresetscreen.dart';
import 'package:clout/screens/authentication/signupflowscreens.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

class BusinessSignInScreen extends StatefulWidget {
  BusinessSignInScreen({Key? key, required this.analytics}) : super(key: key);
  FirebaseAnalytics analytics;
  @override
  State<BusinessSignInScreen> createState() => _BusinessSignInScreenState();
}

class _BusinessSignInScreenState extends State<BusinessSignInScreen> {
  db_conn db = db_conn();
  final emailController = TextEditingController();
  final pswController = TextEditingController();
  applogic logic = applogic();

  void donesignin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthenticationWrapper(
                analytics: widget.analytics,
              ),
          fullscreenDialog: true,
          settings: const RouteSettings(name: "AuthenticationWrapper")),
    );
  }

  void donesignup() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => PicandNameScreen(
                  analytics: widget.analytics,
                  business: true,
                ),
            fullscreenDialog: true,
            settings: const RouteSettings(name: "PicAndNameScreen")));
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
        title: Text(
          "Clout Business.",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontFamily: "Archivo",
              fontWeight: FontWeight.w900,
              fontSize: 30),
          textScaler: TextScaler.linear(1.0),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child:
                Icon(Icons.arrow_back, color: Theme.of(context).primaryColor)),
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
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      hintText: 'e.g. example@outwithclout.com',
                      hintStyle:
                          const TextStyle(color: Color.fromARGB(39, 0, 0, 0))),
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
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      hintText: 'e.g. supersecret',
                      hintStyle:
                          const TextStyle(color: Color.fromARGB(39, 0, 0, 0))),
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
            GestureDetector(
                onTap: signinbuttonpressed
                    ? null
                    : () async {
                        try {
                          setState(() {
                            signinbuttonpressed = true;
                          });
                          List<String> res = await FirebaseAuth.instance
                              .fetchSignInMethodsForEmail(
                                  emailController.text.trim());
                          if (res.isEmpty) {
                            try {
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: emailController.text.trim(),
                                      password: pswController.text.trim());
                              await db.createbusinessinstance(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  emailController.text.trim());
                              await widget.analytics.setUserId(
                                  id: FirebaseAuth.instance.currentUser!.uid);
                              await widget.analytics
                                  .logLogin(loginMethod: "email");
                              donesignup();
                            } catch (e) {
                              throw Exception("Could not sign up");
                            }
                          } else {
                            try {
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: emailController.text.trim(),
                                      password: pswController.text.trim());
                              await widget.analytics.setUserId(
                                  id: FirebaseAuth.instance.currentUser!.uid);
                              await widget.analytics
                                  .logLogin(loginMethod: "email");
                              donesignin();
                            } catch (e) {
                              throw Exception("Could not sign in");
                            }
                          }
                        } catch (e) {
                          logic.displayErrorSnackBar(e.toString(), context);
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
                  text: "Sign On",
                  bold: true,
                )),
            SizedBox(height: screenheight * 0.02),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => PswResetScreen(),
                      settings: RouteSettings(name: "PswResetScreen")),
                );
              },
              child: const Center(
                child: Text(
                  "Forgot password?",
                  style: TextStyle(
                      color: Colors.grey, decoration: TextDecoration.underline),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
