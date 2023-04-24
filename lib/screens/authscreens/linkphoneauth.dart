import 'package:clout/components/primarybutton.dart';
import 'package:clout/screens/authscreens/loading.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:phone_form_field/phone_form_field.dart' as pf;
import 'package:pinput/pinput.dart';

class LinkPhoneInputScreen extends StatefulWidget {
  LinkPhoneInputScreen(
      {super.key, required this.analytics, required this.updatephonenumber});
  FirebaseAnalytics analytics;
  bool updatephonenumber;
  @override
  State<LinkPhoneInputScreen> createState() => _LinkPhoneInputScreenState();
}

class _LinkPhoneInputScreenState extends State<LinkPhoneInputScreen> {
  pf.PhoneNumber? userNumber;
  bool sendcodebuttonpressed = false;

  void verifycode(String verificationId) {
    Future.delayed(Duration.zero, () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => LinkOTPInputScreen(
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
              width: screenwidth * 0.75,
              child: pf.PhoneFormField(
                controller: null, // controller & initialValue value
                initialValue: null, // can't be supplied simultaneously
                shouldFormat: true, // default
                defaultCountry: pf.IsoCode.IT, // default
                decoration: const InputDecoration(
                    errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 255, 48, 117))),
                    hintStyle: TextStyle(color: Color.fromARGB(39, 0, 0, 0))),
                validator: pf.PhoneValidator
                    .validMobile(), // default PhoneValidator.valid()
                isCountryChipPersistent: true, // default
                isCountrySelectionEnabled: true, // default
                countrySelectorNavigator:
                    const pf.CountrySelectorNavigator.draggableBottomSheet(),
                showFlagInInput: true, // default
                flagSize: 16, // default
                autofillHints: const [
                  AutofillHints.telephoneNumber
                ], // default to null
                enabled: true, // default
                autofocus: false, // default
                onSaved: null, // default null
                onChanged: (pf.PhoneNumber? p) {
                  setState(() {
                    userNumber = p;
                  });
                }, // default null
                // ... + other textfield params
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
                    if (userNumber!.nsn.isNotEmpty) {
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber:
                            "+" + userNumber!.countryCode + userNumber!.nsn,
                        verificationCompleted:
                            (PhoneAuthCredential credential) {},
                        verificationFailed: (FirebaseAuthException e) {
                          displayErrorSnackBar("Could not verify phone number");
                        },
                        codeSent: (String verificationId, int? resendToken) {
                          try {
                            verifycode(verificationId);
                          } catch (e) {
                            displayErrorSnackBar(
                                "Could not verify phone number");
                          }
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {},
                      );
                    }

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
      required this.verificationId,
      required this.analytics,
      required this.updatephonenumber});
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
        Center(
          child: SizedBox(
            width: screenwidth * 0.8,
            child: Pinput(
              length: 6,
              pinAnimationType: PinAnimationType.slide,
              showCursor: true,
              focusedPinTheme: PinTheme(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                          width: 1.5, color: Theme.of(context).primaryColor),
                    ),
                  ),
                  textStyle: TextStyle(
                      fontSize: 25, color: Theme.of(context).primaryColor)),
              defaultPinTheme: const PinTheme(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                          width: 1.5,
                          color: Color.fromARGB(255, 151, 149, 149)),
                    ),
                  ),
                  textStyle: TextStyle(fontSize: 25)),
              onCompleted: (String verificationCode) async {
                try {
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
                } catch (e) {
                  displayErrorSnackBar(
                      "Make sure OTP code was inserted correctly.");
                }
              },
            ),
          ),
        ),
      ]),
    );
  }
}
