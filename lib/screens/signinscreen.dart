import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final PhoneNumberController = TextEditingController();

  Color errorcolor = Color.fromARGB(0, 255, 255, 255);

  bool isPhoneNoValid(String? phoneNo) {
    if (phoneNo == null) return false;
    final regExp = RegExp(r'(^\+(?:[0-9] ?){6,14}[0-9]$)');
    return regExp.hasMatch(phoneNo);
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: screenheight * 0.2,
          ),
          Center(
              child: Text(
            "Enter Phone Number",
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
                    hintText: 'e.g. +001234567890',
                    hintStyle: TextStyle(color: Color.fromARGB(39, 0, 0, 0))),
                controller: PhoneNumberController,
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: screenheight * 0.02),
          Text(
            "Invalid Phone Number\nNeeds to be of form:\n+001234567890",
            style: TextStyle(color: errorcolor, fontWeight: FontWeight.bold),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          bool isValid = isPhoneNoValid(PhoneNumberController.text);
          if (isValid) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerificationCodeScreen(
                        phonenumber: PhoneNumberController.text,
                      )),
            );
          } else {
            print("Invalid");
            setState(() {
              errorcolor = Colors.red;
            });
          }
        },
        backgroundColor: Color.fromARGB(255, 255, 48, 117),
        child: Icon(
          CupertinoIcons.arrow_right_circle,
          size: 50,
        ),
      ),
    );
  }
}

class VerificationCodeScreen extends StatelessWidget {
  final String phonenumber;
  VerificationCodeScreen({required this.phonenumber});

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "$phonenumber",
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: screenheight * 0.2,
          ),
          Center(
              child: Text(
            "Enter Verification Code",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 20),
          )),
          Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenwidth * 0.2),
                child: Container()),
          ),
        ],
      ),
    );
  }
}
