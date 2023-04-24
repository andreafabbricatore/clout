import 'package:clout/components/primarybutton.dart';
import 'package:clout/main.dart';
import 'package:clout/screens/authentication/pswresetscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

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

  void donesignin() {
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
          "Clout.",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontFamily: "Archivo",
              fontWeight: FontWeight.w800,
              fontSize: 50),
          textScaleFactor: 1.0,
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
            InkWell(
                onTap: signinbuttonpressed
                    ? null
                    : () async {
                        try {
                          setState(() {
                            signinbuttonpressed = true;
                          });
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: pswController.text.trim());
                          await widget.analytics.setUserId(
                              id: FirebaseAuth.instance.currentUser!.uid);
                          await widget.analytics.logLogin(loginMethod: "email");
                          donesignin();
                        } catch (e) {
                          displayErrorSnackBar("Could not Sign in");
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
                  text: "Sign In",
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

class PhoneSigninScreen extends StatefulWidget {
  PhoneSigninScreen({super.key, required this.analytics});
  FirebaseAnalytics analytics;
  @override
  State<PhoneSigninScreen> createState() => _PhoneSigninScreenState();
}

class _PhoneSigninScreenState extends State<PhoneSigninScreen> {
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'IT';
  PhoneNumber userNumber = PhoneNumber(isoCode: 'IT');
  bool sendcodebuttonpressed = false;

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
          "Sign In.",
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PhoneSigninOTPInputScreen(
                                      userNumber: userNumber,
                                      verificationId: verificationId,
                                      analytics: widget.analytics)));
                        } catch (e) {
                          displayErrorSnackBar("Could not verify phone number");
                        }
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {},
                    );
                    //final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode)

                    setState(() {
                      sendcodebuttonpressed = false;
                    });
                  },
            child: PrimaryButton(
                screenwidth: screenwidth,
                buttonpressed: sendcodebuttonpressed,
                text: "Sign In",
                buttonwidth: screenwidth * 0.8,
                bold: false),
          )
        ],
      ),
    );
  }
}

class PhoneSigninOTPInputScreen extends StatefulWidget {
  PhoneSigninOTPInputScreen(
      {super.key,
      required this.userNumber,
      required this.verificationId,
      required this.analytics});
  PhoneNumber userNumber;
  String verificationId;
  FirebaseAnalytics analytics;
  @override
  State<PhoneSigninOTPInputScreen> createState() =>
      _PhoneSigninOTPInputScreenState();
}

class _PhoneSigninOTPInputScreenState extends State<PhoneSigninOTPInputScreen> {
  void donesignin() {
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
      ),
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

            await FirebaseAuth.instance.signInWithCredential(credential);
            donesignin();
          },
        ),
      ]),
    );
  }
}
