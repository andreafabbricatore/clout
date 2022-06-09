import 'package:clout/screens/mainscreen.dart';
import 'package:clout/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final pswController = TextEditingController();
  String? error = "";
  Color errorcolor = Colors.white;
  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
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
            child: Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 48, 117))),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: screenheight * 0.2,
            ),
            Center(
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
            Center(
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
                String? res = await context
                    .read<AuthenticationService>()
                    .signIn(
                        email: emailController.text.trim(),
                        password: pswController.text.trim());
                if (res == "Yes") {
                  setState(() {
                    error = "";
                    errorcolor = Colors.white;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => MainScreen(),
                    ),
                  );
                } else {
                  setState(() {
                    error = res;
                    errorcolor = Colors.red;
                  });
                }
              },
              child: SizedBox(
                  height: 50,
                  width: screenwidth * 0.5,
                  child: Container(
                    child: Center(
                        child: Text(
                      "Sign In",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 48, 117),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  )),
            ),
            SizedBox(height: screenheight * 0.02),
            Center(
              child: Text(
                error.toString(),
                style: TextStyle(color: errorcolor),
              ),
            )
          ],
        ),
      ),
    );
  }
}