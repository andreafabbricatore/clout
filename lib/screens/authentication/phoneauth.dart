import 'package:clout/components/datatextfield.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:clout/main.dart';

import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart' as pf;
import 'package:pinput/pinput.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneInputScreen extends StatefulWidget {
  PhoneInputScreen({super.key, required this.analytics});
  FirebaseAnalytics analytics;
  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  bool sendcodebuttonpressed = false;
  final referralController = TextEditingController();
  bool referralbuttonpressed = false;
  pf.PhoneNumber? userNumber;
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

  void verifycode(String verificationId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => OTPInputScreen(
                  verificationId: verificationId,
                  analytics: widget.analytics,
                  referral: referralController.text.trim(),
                )));
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Go Out.",
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
              height: screenheight * 0.02,
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
                            displayErrorSnackBar(
                                "Could not verify phone number");
                          },
                          codeSent: (String verificationId, int? resendToken) {
                            verifycode(verificationId);
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {},
                        );
                        //final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode)
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
            ),
            SizedBox(
              height: screenheight * 0.02,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context, setState) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.white,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 20, 10, 10),
                                height: screenheight * 0.25,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Column(children: [
                                  const Text("Enter Referral Link",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25)),
                                  SizedBox(
                                    height: screenheight * 0.02,
                                  ),
                                  textdatafield(screenwidth * 0.4, "Enter Link",
                                      referralController),
                                  SizedBox(
                                    height: screenheight * 0.03,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: PrimaryButton(
                                          screenwidth: screenwidth,
                                          buttonpressed: referralbuttonpressed,
                                          text: "Save",
                                          buttonwidth: screenwidth * 0.7,
                                          bold: false)),
                                ]),
                              ),
                            );
                          },
                        );
                      });
                },
                child: Text(
                  "Invited by a friend?",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenheight * 0.4),
            SizedBox(
              width: screenwidth * 0.6,
              child: RichText(
                textAlign: TextAlign.justify,
                textScaleFactor: 1.0,
                text: TextSpan(
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontFamily: "Archivo"),
                    children: [
                      const TextSpan(
                          text: "By continuing you are agreeing to the "),
                      TextSpan(
                          text: "End User License Agreement",
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                  Uri.parse("https://outwithclout.com/#/eula/"),
                                  mode: LaunchMode.inAppWebView);
                            }),
                      const TextSpan(text: " and "),
                      TextSpan(
                          text: "the Privacy Statement",
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                  Uri.parse(
                                      "https://outwithclout.com/#/privacy_policy/"),
                                  mode: LaunchMode.inAppWebView);
                            }),
                      const TextSpan(text: "."),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OTPInputScreen extends StatefulWidget {
  OTPInputScreen(
      {super.key,
      required this.verificationId,
      required this.analytics,
      required this.referral});

  String verificationId;
  FirebaseAnalytics analytics;
  String referral;
  @override
  State<OTPInputScreen> createState() => _OTPInputScreenState();
}

class _OTPInputScreenState extends State<OTPInputScreen> {
  db_conn db = db_conn();

  void done() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthenticationWrapper(
                analytics: widget.analytics,
              ),
          fullscreenDialog: true,
          settings: RouteSettings(name: "AuthenticationWrapper")),
    );
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
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child:
                Icon(Icons.arrow_back, color: Theme.of(context).primaryColor)),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
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
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: widget.verificationId,
                            smsCode: verificationCode);
                    //link credential
                    UserCredential usercredential = await FirebaseAuth.instance
                        .signInWithCredential(credential);
                    if (usercredential.additionalUserInfo!.isNewUser) {
                      await db.createuserinstance(usercredential
                          .user!.uid); //set all signup attributes to false
                      if (widget.referral.isNotEmpty) {
                        try {
                          String shareruid = widget.referral.split("/").last;
                          await db.referralcloutinc(
                              usercredential.user!.uid, shareruid);
                          displayErrorSnackBar("Successfully referred!");
                          done();
                        } catch (e) {
                          displayErrorSnackBar(
                              "Invalid code, change it or remove it.");
                        }
                      } else {
                        done();
                      }
                    } else {
                      done();
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
      ),
    );
  }
}
