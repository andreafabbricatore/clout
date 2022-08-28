import 'package:clout/main.dart';
import 'package:clout/screens/pswresetscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  db_conn db = db_conn();
  final emailController = TextEditingController();
  final pswController = TextEditingController();

  void displayErrorSnackBar(String error) async {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    await Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "CLOUT",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontWeight: FontWeight.bold,
              fontSize: 30),
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
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: pswController.text.trim());
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            AuthenticationWrapper(),
                        fullscreenDialog: true),
                  );
                } catch (e) {
                  displayErrorSnackBar("Could not Sign in");
                }
              },
              child: SizedBox(
                  height: 50,
                  width: screenwidth * 0.5,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 48, 117),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: const Center(
                        child: Text(
                      "Sign In",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
                  )),
            ),
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
