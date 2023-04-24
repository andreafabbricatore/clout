import 'package:clout/components/primarybutton.dart';
import 'package:clout/screens/authscreens/loading.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class LinkPhoneInputScreen extends StatefulWidget {
  LinkPhoneInputScreen(
      {super.key, required this.analytics, required this.updatephonenumber});
  FirebaseAnalytics analytics;
  bool updatephonenumber;
  @override
  State<LinkPhoneInputScreen> createState() => _LinkPhoneInputScreenState();
}

class _LinkPhoneInputScreenState extends State<LinkPhoneInputScreen> {
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'IT';
  PhoneNumber userNumber = PhoneNumber(isoCode: 'IT');
  bool sendcodebuttonpressed = false;

  void verifycode(String verificationId) {
    Future.delayed(Duration.zero, () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => LinkOTPInputScreen(
                    userNumber: userNumber,
                    verificationId: verificationId,
                    analytics: widget.analytics,
                    updatephonenumber: widget.updatephonenumber,
                  )));
    });
  }

  void displayErrorSnackBar(
    String error,
  ) {
    final snackBar = SnackBar(
      content: Text(
        error,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color.fromARGB(230, 255, 48, 117),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: false,
      closeIconColor: Colors.white,
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Phone Number",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w900,
            fontSize: 30,
          ),
          textScaleFactor: 1.0,
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: widget.updatephonenumber
            ? GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back,
                    color: Theme.of(context).primaryColor))
            : Container(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: screenheight * 0.2,
          ),
          Center(
            child: SizedBox(
              width: screenwidth * 0.8,
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  setState(() {
                    userNumber = number;
                  });
                },
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.DROPDOWN,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: const TextStyle(color: Colors.black),
                initialValue: userNumber,
                textFieldController: controller,
                inputBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 255, 48, 117))),
                inputDecoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    hintStyle: TextStyle(color: Color.fromARGB(39, 0, 0, 0))),
                formatInput: true,
              ),
            ),
          ),
          SizedBox(
            height: screenheight * 0.04,
          ),
          GestureDetector(
            onTap: sendcodebuttonpressed
                ? null
                : () async {
                    setState(() {
                      sendcodebuttonpressed = true;
                    });
                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: userNumber.phoneNumber,
                      verificationCompleted:
                          (PhoneAuthCredential credential) {},
                      verificationFailed: (FirebaseAuthException e) {
                        displayErrorSnackBar("Could not verify phone number");
                      },
                      codeSent: (String verificationId, int? resendToken) {
                        try {
                          verifycode(verificationId);
                        } catch (e) {
                          displayErrorSnackBar("Could not verify phone number");
                        }
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {},
                    );

                    setState(() {
                      sendcodebuttonpressed = false;
                    });
                  },
            child: PrimaryButton(
                screenwidth: screenwidth,
                buttonpressed: sendcodebuttonpressed,
                text: "Verify",
                buttonwidth: screenwidth * 0.8,
                bold: false),
          )
        ],
      ),
    );
  }
}

class LinkOTPInputScreen extends StatefulWidget {
  LinkOTPInputScreen(
      {super.key,
      required this.userNumber,
      required this.verificationId,
      required this.analytics,
      required this.updatephonenumber});
  PhoneNumber userNumber;
  String verificationId;
  FirebaseAnalytics analytics;
  bool updatephonenumber;
  @override
  State<LinkOTPInputScreen> createState() => _LinkOTPInputScreenState();
}

class _LinkOTPInputScreenState extends State<LinkOTPInputScreen> {
  void donechange() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => LoadingScreen(
                uid: FirebaseAuth.instance.currentUser!.uid,
                analytics: widget.analytics)));
  }

  void displayErrorSnackBar(
    String error,
  ) {
    final snackBar = SnackBar(
      content: Text(
        error,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color.fromARGB(230, 255, 48, 117),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: false,
      closeIconColor: Colors.white,
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(
            "Enter Code",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
            textScaleFactor: 1.0,
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          elevation: 0.0,
          centerTitle: true,
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back,
                  color: Theme.of(context).primaryColor))),
      body: Column(children: [
        SizedBox(
          height: screenheight * 0.2,
        ),
        OtpTextField(
          numberOfFields: 6,
          borderColor: Theme.of(context).primaryColor,
          focusedBorderColor: Theme.of(context).primaryColor,
          showFieldAsBox: false,
          onCodeChanged: (String code) {},
          onSubmit: (String verificationCode) async {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: widget.verificationId,
                smsCode: verificationCode);

            try {
              if (widget.updatephonenumber) {
                await FirebaseAuth.instance.currentUser
                    ?.updatePhoneNumber(credential);
              } else {
                await FirebaseAuth.instance.currentUser
                    ?.linkWithCredential(credential);
              }
              donechange();
            } catch (e) {
              displayErrorSnackBar("Could not verify phone number.");
            }
          },
        ),
      ]),
    );
  }
}
