import 'dart:io';
import 'package:clout/components/datatextfield.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:clout/main.dart';
import 'package:clout/screens/authscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key, required this.analytics}) : super(key: key);
  FirebaseAnalytics analytics;
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final pswController = TextEditingController();
  db_conn db = db_conn();
  bool signupbuttonpressed = false;

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

  void gopicandnamescreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => PicandNameScreen(
                analytics: widget.analytics,
              ),
          fullscreenDialog: true,
          settings: RouteSettings(name: "PicandNameScreen")),
    );
  }

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
                onTap: signupbuttonpressed
                    ? null
                    : () async {
                        setState(() {
                          signupbuttonpressed = true;
                        });
                        bool emailunique =
                            await db.emailUnique(emailController.text.trim());
                        if (emailController.text.isNotEmpty &&
                            RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(emailController.text.trim()) &&
                            emailunique &&
                            pswController.text.length >= 8) {
                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: emailController.text.trim(),
                                    password: pswController.text);
                            String uid = FirebaseAuth.instance.currentUser!.uid;
                            await db.createuserinstance(
                                emailController.text.trim(),
                                uid); //set all signup attributes to false
                            gopicandnamescreen();
                          } catch (e) {
                            displayErrorSnackBar(
                                "Could not Sign Up, please try again");
                          }
                        } else {
                          if (emailController.text.isEmpty ||
                              !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(emailController.text.trim())) {
                            displayErrorSnackBar("Invalid email address");
                          } else if (!emailunique) {
                            displayErrorSnackBar(
                                "An account is already associated with this email");
                          } else if (pswController.text.length < 8) {
                            displayErrorSnackBar(
                                "Password has to be at least 8 characters");
                          }
                        }
                        setState(() {
                          signupbuttonpressed = false;
                        });
                      },
                child: PrimaryButton(
                  screenwidth: screenwidth,
                  buttonwidth: screenwidth * 0.5,
                  buttonpressed: signupbuttonpressed,
                  text: "Sign Up",
                  bold: true,
                )),
            SizedBox(height: screenheight * 0.3),
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
                              launchUrl(Uri.parse(
                                  "https://termify.io/eula/1664706776"));
                            }),
                      const TextSpan(text: " and "),
                      TextSpan(
                          text: "the Privacy Statement",
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(Uri.parse(
                                  "https://termify.io/privacy-policy/1664707655"));
                            }),
                      const TextSpan(text: "."),
                    ]),
              ),
            ),
            SizedBox(height: screenheight * 0.02),
          ],
        ),
      ),
    );
  }
}

class PicandNameScreen extends StatefulWidget {
  PicandNameScreen({super.key, required this.analytics});
  FirebaseAnalytics analytics;
  @override
  State<PicandNameScreen> createState() => _PicandNameScreenState();
}

class _PicandNameScreenState extends State<PicandNameScreen> {
  final fullnamecontroller = TextEditingController();
  ImagePicker picker = ImagePicker();
  var imagepath;
  db_conn db = db_conn();
  bool cancelbuttonpressed = false;
  bool continuebuttonpressed = false;
  TextEditingController psw = TextEditingController();
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

  var compressedimgpath;

  Future<File> CompressAndGetFile(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
      var result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 5,
      );

      //print(file.lengthSync());
      //print(result!.lengthSync());

      return result!;
    } catch (e) {
      throw Exception();
    }
  }

  void goauthscreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthScreen(
                analytics: widget.analytics,
              ),
          fullscreenDialog: true,
          settings: RouteSettings(name: "AuthScreen")),
    );
  }

  void gousernamescreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => UsernameScreen(
                analytics: widget.analytics,
              ),
          fullscreenDialog: true,
          settings: RouteSettings(name: "UsernameScreen")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    //print(imagepath == null);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
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
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                          height: screenheight * 0.35,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Column(children: [
                            const Text("Cancel SignUp",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25)),
                            SizedBox(
                              height: screenheight * 0.02,
                            ),
                            const Text(
                              "Enter password to cancel Sign Up.",
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: screenheight * 0.02,
                            ),
                            textdatafield(
                                screenwidth * 0.4, "Enter Password", psw),
                            SizedBox(
                              height: screenheight * 0.04,
                            ),
                            GestureDetector(
                                onTap: cancelbuttonpressed
                                    ? null
                                    : () async {
                                        setState(() {
                                          cancelbuttonpressed = true;
                                        });
                                        try {
                                          String email = FirebaseAuth.instance
                                                  .currentUser!.email ??
                                              "";
                                          try {
                                            await FirebaseAuth.instance
                                                .signInWithEmailAndPassword(
                                                    email: email,
                                                    password: psw.text.trim());
                                          } catch (e) {
                                            displayErrorSnackBar(
                                                "Could not cancel Sign Up, pleaes make sure password is correct");
                                          }
                                          await db.firstcancelsignup(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid);
                                          await FirebaseAuth
                                              .instance.currentUser!
                                              .delete();
                                          psw.clear();
                                          goauthscreen();
                                        } catch (e) {
                                        } finally {
                                          setState(() {
                                            cancelbuttonpressed = false;
                                          });
                                        }
                                      },
                                child: PrimaryButton(
                                    screenwidth: screenwidth,
                                    buttonpressed: cancelbuttonpressed,
                                    text: "Cancel Sign Up",
                                    buttonwidth: screenwidth * 0.7,
                                    bold: false)),
                          ]),
                        ),
                      );
                    },
                  );
                });
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        title: Text(
          "Who are you",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Row(
              children: [
                Container(
                  width: screenwidth * 0.25,
                  color: Theme.of(context).primaryColor,
                  height: 4.0,
                ),
                SizedBox(
                  width: screenwidth * 0.75,
                  height: 4.0,
                )
              ],
            )),
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenheight * 0.1),
          const Center(
            child: Text(
              "Upload Profile Picture",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              textScaleFactor: 1.0,
            ),
          ),
          SizedBox(
            height: screenheight * 0.03,
          ),
          Center(
              child: InkWell(
                  onTap: () async {
                    XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        imagepath = File(image.path);
                      });
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: imagepath != null
                        ? Image.file(
                            imagepath,
                            fit: BoxFit.cover,
                            height: screenheight * 0.2,
                            width: screenheight * 0.2,
                          )
                        : Container(
                            color: Theme.of(context).primaryColor,
                            height: screenheight * 0.2,
                            width: screenheight * 0.2,
                            child: Icon(
                              Icons.upload_rounded,
                              color: Colors.white,
                              size: screenheight * 0.18,
                            ),
                          ),
                  ))),
          SizedBox(height: screenheight * 0.05),
          textdatafield(screenwidth, "Full Name", fullnamecontroller),
          SizedBox(
            height: screenheight * 0.1,
          ),
          GestureDetector(
            onTap: continuebuttonpressed
                ? null
                : () async {
                    setState(() {
                      continuebuttonpressed = true;
                    });
                    bool compressedimgpathgood = false;
                    if (imagepath != null &&
                        fullnamecontroller.text.trim().isNotEmpty) {
                      try {
                        compressedimgpath = await CompressAndGetFile(imagepath);
                        setState(() {
                          compressedimgpathgood = true;
                        });
                      } catch (e) {
                        displayErrorSnackBar(
                            "Error with profile picture, might be an invalid format");
                      }
                      if (compressedimgpathgood) {
                        try {
                          await db.changepfp(compressedimgpath,
                              FirebaseAuth.instance.currentUser!.uid);
                          await db.changeattribute(
                              'fullname',
                              fullnamecontroller.text.trim(),
                              FirebaseAuth.instance.currentUser!.uid);
                          await db.changeattributebool('setnameandpfp', true,
                              FirebaseAuth.instance.currentUser!.uid);
                          gousernamescreen();
                        } catch (e) {
                          displayErrorSnackBar(
                              "Could not proceed with signup, please check internet connection and try again");
                        }
                      }
                    } else if (imagepath == null) {
                      displayErrorSnackBar("Please upload Profile Picture");
                    } else if (fullnamecontroller.text.trim().isEmpty) {
                      displayErrorSnackBar("Please enter your full name");
                    } else {
                      displayErrorSnackBar(
                          "Error with full name or profile picture");
                    }

                    setState(() {
                      continuebuttonpressed = false;
                    });
                  },
            child: PrimaryButton(
              screenwidth: screenwidth,
              buttonpressed: continuebuttonpressed,
              text: "Continue",
              buttonwidth: screenwidth * 0.6,
              bold: false,
            ),
          )
        ],
      )),
    );
  }
}

class UsernameScreen extends StatefulWidget {
  UsernameScreen({
    Key? key,
    required this.analytics,
  }) : super(key: key);
  FirebaseAnalytics analytics;
  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final usernamecontroller = TextEditingController();
  db_conn db = db_conn();
  bool cancelbuttonpressed = false;
  bool continuebuttonpressed = false;
  TextEditingController psw = TextEditingController();

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

  void goauthscreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthScreen(
                analytics: widget.analytics,
              ),
          fullscreenDialog: true),
    );
  }

  void gotomiscscreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => MiscScreen(
                analytics: widget.analytics,
              ),
          settings: RouteSettings(name: "MiscScreen")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
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
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                          height: screenheight * 0.35,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Column(children: [
                            const Text("Cancel SignUp",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25)),
                            SizedBox(
                              height: screenheight * 0.02,
                            ),
                            const Text(
                              "Enter password to cancel Sign Up.",
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: screenheight * 0.02,
                            ),
                            textdatafield(
                                screenwidth * 0.4, "Enter Password", psw),
                            SizedBox(
                              height: screenheight * 0.04,
                            ),
                            GestureDetector(
                                onTap: cancelbuttonpressed
                                    ? null
                                    : () async {
                                        setState(() {
                                          cancelbuttonpressed = true;
                                        });
                                        try {
                                          String email = FirebaseAuth.instance
                                                  .currentUser!.email ??
                                              "";
                                          await FirebaseAuth.instance
                                              .signInWithEmailAndPassword(
                                                  email: email,
                                                  password: psw.text.trim());
                                          await db.cancelsignup(FirebaseAuth
                                              .instance.currentUser!.uid);
                                          await FirebaseAuth
                                              .instance.currentUser!
                                              .delete();
                                          psw.clear();
                                          goauthscreen();
                                        } catch (e) {
                                          displayErrorSnackBar(
                                              "Could not cancel signup, please try again and makes sure password is correct");
                                        } finally {
                                          setState(() {
                                            cancelbuttonpressed = false;
                                          });
                                        }
                                      },
                                child: PrimaryButton(
                                    screenwidth: screenwidth,
                                    buttonpressed: cancelbuttonpressed,
                                    text: "Cancel Sign Up",
                                    buttonwidth: screenwidth * 0.7,
                                    bold: false)),
                          ]),
                        ),
                      );
                    },
                  );
                });
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        title: Text(
          "Username",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Row(
              children: [
                Container(
                  width: screenwidth * 0.5,
                  color: Theme.of(context).primaryColor,
                  height: 4.0,
                ),
                SizedBox(
                  width: screenwidth * 0.5,
                  height: 4.0,
                )
              ],
            )),
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: screenheight * 0.3),
          textdatafield(screenwidth, "Username", usernamecontroller),
          SizedBox(
            height: screenheight * 0.1,
          ),
          GestureDetector(
            onTap: continuebuttonpressed
                ? null
                : () async {
                    setState(() {
                      continuebuttonpressed = true;
                    });
                    bool uniqueness =
                        await db.usernameUnique(usernamecontroller.text);
                    if (!uniqueness && usernamecontroller.text.isNotEmpty) {
                      setState(() {
                        displayErrorSnackBar("Username already taken");
                      });
                    } else if (usernamecontroller.text.isEmpty) {
                      displayErrorSnackBar("Invalid Username");
                    } else if (!RegExp(r'^[a-zA-Z0-9&%=]+$')
                        .hasMatch(usernamecontroller.text.trim())) {
                      displayErrorSnackBar(
                          "Please only enter alphanumeric characters");
                    } else {
                      try {
                        await db.changeusername(
                            usernamecontroller.text.trim().toLowerCase(),
                            FirebaseAuth.instance.currentUser!.uid);
                        await db.changeattributebool('setusername', true,
                            FirebaseAuth.instance.currentUser!.uid);
                        gotomiscscreen();
                      } catch (e) {
                        displayErrorSnackBar(
                            "Could not proceed with signup, please check internet connection and try again");
                      }
                    }
                    setState(() {
                      continuebuttonpressed = false;
                    });
                  },
            child: PrimaryButton(
                screenwidth: screenwidth,
                buttonpressed: continuebuttonpressed,
                text: "Continue",
                buttonwidth: screenwidth * 0.6,
                bold: false),
          )
        ],
      )),
    );
  }
}

class MiscScreen extends StatefulWidget {
  MiscScreen({super.key, required this.analytics});
  FirebaseAnalytics analytics;
  @override
  State<MiscScreen> createState() => _MiscScreenState();
}

class _MiscScreenState extends State<MiscScreen> {
  DateTime birthday = DateTime(0, 0, 0);
  String gender = 'Male';
  String nationality = 'Australia';
  db_conn db = db_conn();
  bool cancelbuttonpressed = false;
  bool continuebuttonpressed = false;
  TextEditingController psw = TextEditingController();
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

  var maskFormatter = MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  var genders = ['Male', 'Female', 'Non-Binary'];
  var nations = [
    'Afghanistan',
    'Aland Islands',
    'Albania',
    'Algeria',
    'American Samoa',
    'Andorra',
    'Angola',
    'Anguilla',
    'Antarctica',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Aruba',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bermuda',
    'Bhutan',
    'Bolivia, Plurinational State of',
    'Bonaire, Sint Eustatius and Saba',
    'Bosnia and Herzegovina',
    'Botswana',
    'Bouvet Island',
    'Brazil',
    'British Indian Ocean Territory',
    'Brunei Darussalam',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Cape Verde',
    'Cayman Islands',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Christmas Island',
    'Cocos (Keeling) Islands',
    'Colombia',
    'Comoros',
    'Congo',
    'Congo, The Democratic Republic of the',
    'Cook Islands',
    'Costa Rica',
    "Côte d'Ivoire",
    'Croatia',
    'Cuba',
    'Curaçao',
    'Cyprus',
    'Czech Republic',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Ethiopia',
    'Falkland Islands (Malvinas)',
    'Faroe Islands',
    'Fiji',
    'Finland',
    'France',
    'French Guiana',
    'French Polynesia',
    'French Southern Territories',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Gibraltar',
    'Greece',
    'Greenland',
    'Grenada',
    'Guadeloupe',
    'Guam',
    'Guatemala',
    'Guernsey',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Heard Island and McDonald Islands',
    'Holy See (Vatican City State)',
    'Honduras',
    'Hong Kong',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran, Islamic Republic of',
    'Iraq',
    'Ireland',
    'Isle of Man',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jersey',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    "Korea, Democratic People's Republic of",
    'Korea, Republic of',
    'Kuwait',
    'Kyrgyzstan',
    "Lao People's Democratic Republic",
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Macao',
    'Macedonia, Republic of',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Martinique',
    'Mauritania',
    'Mauritius',
    'Mayotte',
    'Mexico',
    'Micronesia, Federated States of',
    'Moldova, Republic of',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Montserrat',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Caledonia',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'Niue',
    'Norfolk Island',
    'Northern Mariana Islands',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Palestinian Territory, Occupied',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Pitcairn',
    'Poland',
    'Portugal',
    'Puerto Rico',
    'Qatar',
    'Réunion',
    'Romania',
    'Russian Federation',
    'Rwanda',
    'Saint Barthélemy',
    'Saint Helena, Ascension and Tristan da Cunha',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Martin (French part)',
    'Saint Pierre and Miquelon',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Sint Maarten (Dutch part)',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Georgia and the South Sandwich Islands',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'South Sudan',
    'Svalbard and Jan Mayen',
    'Swaziland',
    'Sweden',
    'Switzerland',
    'Syrian Arab Republic',
    'Taiwan, Province of China',
    'Tajikistan',
    'Tanzania, United Republic of',
    'Thailand',
    'Timor-Leste',
    'Togo',
    'Tokelau',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Turks and Caicos Islands',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'United States Minor Outlying Islands',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Venezuela, Bolivarian Republic of',
    'Viet Nam',
    'Virgin Islands, British',
    'Virgin Islands, U.S.',
    'Wallis and Futuna',
    'Yemen',
    'Zambia',
    'Zimbabwe'
  ];

  void goauthscreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthScreen(
                analytics: widget.analytics,
              ),
          fullscreenDialog: true,
          settings: RouteSettings(name: "AuthScreen")),
    );
  }

  void gointerestscreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => InterestScreen(
                analytics: widget.analytics,
              ),
          fullscreenDialog: true,
          settings: RouteSettings(name: "InterestScreen")),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
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
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                          height: screenheight * 0.35,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Column(children: [
                            const Text("Cancel SignUp",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25)),
                            SizedBox(
                              height: screenheight * 0.02,
                            ),
                            const Text(
                              "Enter password to cancel Sign Up.",
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: screenheight * 0.02,
                            ),
                            textdatafield(
                                screenwidth * 0.4, "Enter Password", psw),
                            SizedBox(
                              height: screenheight * 0.04,
                            ),
                            GestureDetector(
                                onTap: cancelbuttonpressed
                                    ? null
                                    : () async {
                                        setState(() {
                                          cancelbuttonpressed = true;
                                        });
                                        try {
                                          String email = FirebaseAuth.instance
                                                  .currentUser!.email ??
                                              "";
                                          await FirebaseAuth.instance
                                              .signInWithEmailAndPassword(
                                                  email: email,
                                                  password: psw.text.trim());
                                          await db.cancelsignup(FirebaseAuth
                                              .instance.currentUser!.uid);
                                          await FirebaseAuth
                                              .instance.currentUser!
                                              .delete();
                                          psw.clear();
                                          goauthscreen();
                                        } catch (e) {
                                          displayErrorSnackBar(
                                              "Could not cancel signup, please try again and makes sure password is correct");
                                        } finally {
                                          setState(() {
                                            cancelbuttonpressed = false;
                                          });
                                        }
                                      },
                                child: PrimaryButton(
                                    screenwidth: screenwidth,
                                    buttonpressed: cancelbuttonpressed,
                                    text: "Cancel Sign Up",
                                    buttonwidth: screenwidth * 0.7,
                                    bold: false)),
                          ]),
                        ),
                      );
                    },
                  );
                });
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        title: Text(
          "Other info",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Row(
              children: [
                Container(
                  width: screenwidth * 0.75,
                  color: Theme.of(context).primaryColor,
                  height: 4.0,
                ),
                SizedBox(
                  width: screenwidth * 0.25,
                  height: 4.0,
                )
              ],
            )),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: screenheight * 0.2),
            SizedBox(
              width: screenwidth * 0.6,
              child: DropdownButtonFormField(
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor))),
                value: gender,
                onChanged: (String? newValue) {
                  setState(() {
                    gender = newValue!;
                  });
                },
                onSaved: (String? newValue) {
                  setState(() {
                    gender = newValue!;
                  });
                },
                items: genders.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: screenheight * 0.02),
            SizedBox(
              width: screenwidth * 0.6,
              child: DropdownButtonFormField(
                borderRadius: BorderRadius.circular(20),
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                )),
                value: nationality,
                onChanged: (String? newValue) {
                  setState(() {
                    nationality = newValue!;
                  });
                },
                onSaved: (String? newValue) {
                  setState(() {
                    nationality = newValue!;
                  });
                },
                items: nations.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                isExpanded: true,
              ),
            ),
            SizedBox(height: screenheight * 0.02),
            InkWell(
              onTap: () {
                showCupertinoModalPopup(
                    context: context,
                    builder: (_) => Container(
                          height: screenheight * 0.4,
                          color: Colors.white,
                          child: Column(
                            children: [
                              SizedBox(
                                height: screenheight * 0.4,
                                child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.date,
                                    maximumDate: DateTime(
                                        DateTime.now().year - 18,
                                        DateTime.now().month,
                                        DateTime.now().day),
                                    minimumDate: DateTime(1950, 1, 1),
                                    initialDateTime: DateTime(
                                        DateTime.now().year - 18,
                                        DateTime.now().month,
                                        DateTime.now().day),
                                    onDateTimeChanged: (val) {
                                      setState(() {
                                        birthday = val;
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ));
              },
              child: Container(
                height: screenwidth * 0.13,
                width: screenwidth * 0.6,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(20)),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    birthday == DateTime(0, 0, 0)
                        ? "Enter birthday"
                        : DateFormat('dd MMMM yyyy').format(birthday),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Icon(
                    Icons.date_range,
                    size: 15,
                  )
                ]),
              ),
            ),
            SizedBox(
              height: screenheight * 0.1,
            ),
            GestureDetector(
              onTap: continuebuttonpressed
                  ? null
                  : () async {
                      setState(() {
                        continuebuttonpressed = true;
                      });

                      if (birthday != DateTime(0, 0, 0)) {
                        try {
                          await db.changeattribute('gender', gender,
                              FirebaseAuth.instance.currentUser!.uid);
                          await db.changeattribute('nationality', nationality,
                              FirebaseAuth.instance.currentUser!.uid);
                          await db.changebirthday(
                              birthday, FirebaseAuth.instance.currentUser!.uid);
                          await db.changeattributebool('setmisc', true,
                              FirebaseAuth.instance.currentUser!.uid);
                          gointerestscreen();
                        } catch (e) {
                          displayErrorSnackBar(
                              "Could not proceed with signup, please check internet connection and try again");
                        }
                      } else {
                        displayErrorSnackBar(
                            "Please try again and make sure all fields are filled correctly");
                      }
                      setState(() {
                        continuebuttonpressed = false;
                      });
                    },
              child: PrimaryButton(
                screenwidth: screenwidth,
                buttonpressed: continuebuttonpressed,
                text: "Continue",
                buttonwidth: screenwidth * 0.6,
                bold: false,
              ),
            )
          ],
        ),
      )),
    );
  }
}

class InterestScreen extends StatefulWidget {
  InterestScreen({Key? key, required this.analytics}) : super(key: key);
  FirebaseAnalytics analytics;
  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  List allinterests = [
    "Sports",
    "Nature",
    "Music",
    "Dance",
    "Movies",
    "Acting",
    "Singing",
    "Drinking",
    "Food",
    "Art",
    "Animals",
    "Fashion",
    "Cooking",
    "Culture",
    "Travel",
    "Games"
  ];
  List<Color> textcolors =
      List.filled(10, const Color.fromARGB(255, 255, 48, 117));
  List<Color> cardcolors = List.filled(10, Colors.white);
  List selectedinterests = [];
  db_conn db = db_conn();
  bool buttonpressed = false;
  bool cancelbuttonpressed = false;
  TextEditingController psw = TextEditingController();

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

  void goauthscreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthScreen(
                analytics: widget.analytics,
              ),
          fullscreenDialog: true,
          settings: RouteSettings(name: "AuthScreen")),
    );
  }

  void donesignup() {
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

  Widget _listviewitem(String interest) {
    return GestureDetector(
      onTap: () {
        if (selectedinterests.contains(interest)) {
          setState(() {
            selectedinterests.removeWhere((element) => element == interest);
          });
        } else {
          setState(() {
            selectedinterests.add(interest);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
              width: selectedinterests.contains(interest) ? 2 : 0,
              color: selectedinterests.contains(interest)
                  ? Theme.of(context).primaryColor
                  : Colors.black),
          image: DecorationImage(
              opacity: selectedinterests.contains(interest) ? 0.8 : 1,
              image: AssetImage(
                "assets/images/interestbanners/${interest.toLowerCase()}.jpeg",
              ),
              fit: BoxFit.cover),
        ),
        child: Center(
            child: Text(
          interest,
          style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: selectedinterests.contains(interest)
                  ? Theme.of(context).primaryColor
                  : Colors.white),
          textScaleFactor: 1.0,
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
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
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                          height: screenheight * 0.35,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Column(children: [
                            const Text("Cancel SignUp",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25)),
                            SizedBox(
                              height: screenheight * 0.02,
                            ),
                            const Text(
                              "Enter password to cancel Sign Up.",
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: screenheight * 0.02,
                            ),
                            textdatafield(
                                screenwidth * 0.4, "Enter Password", psw),
                            SizedBox(
                              height: screenheight * 0.04,
                            ),
                            GestureDetector(
                                onTap: cancelbuttonpressed
                                    ? null
                                    : () async {
                                        setState(() {
                                          cancelbuttonpressed = true;
                                        });
                                        try {
                                          String email = FirebaseAuth.instance
                                                  .currentUser!.email ??
                                              "";
                                          await FirebaseAuth.instance
                                              .signInWithEmailAndPassword(
                                                  email: email,
                                                  password: psw.text.trim());
                                          await db.cancelsignup(FirebaseAuth
                                              .instance.currentUser!.uid);
                                          await FirebaseAuth
                                              .instance.currentUser!
                                              .delete();
                                          psw.clear();
                                          goauthscreen();
                                        } catch (e) {
                                          displayErrorSnackBar(
                                              "Could not cancel signup, please try again and makes sure password is correct");
                                        } finally {
                                          setState(() {
                                            cancelbuttonpressed = false;
                                          });
                                        }
                                      },
                                child: PrimaryButton(
                                    screenwidth: screenwidth,
                                    buttonpressed: cancelbuttonpressed,
                                    text: "Cancel Sign Up",
                                    buttonwidth: screenwidth * 0.7,
                                    bold: false)),
                          ]),
                        ),
                      );
                    },
                  );
                });
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        title: Text(
          "What are your interests?",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Row(
              children: [
                Container(
                  width: screenwidth,
                  color: Theme.of(context).primaryColor,
                  height: 4.0,
                ),
              ],
            )),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
        child: Stack(children: [
          Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  shrinkWrap: true,
                  itemCount: allinterests.length,
                  itemBuilder: ((context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: _listviewitem(allinterests[index]),
                    );
                  }),
                ),
              ),
            ],
          ),
        ]),
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: buttonpressed
              ? null
              : () async {
                  setState(() {
                    buttonpressed = true;
                  });
                  try {
                    if (selectedinterests.length >= 3) {
                      await db.changeinterests('interests', selectedinterests,
                          FirebaseAuth.instance.currentUser!.uid);
                      await db.changeattributebool('setinterests', true,
                          FirebaseAuth.instance.currentUser!.uid);
                      donesignup();
                    } else {
                      displayErrorSnackBar("Choose at least 3 interests");
                      setState(() {
                        buttonpressed = false;
                      });
                    }
                  } catch (e) {
                    displayErrorSnackBar("Could not create user");
                    setState(() {
                      buttonpressed = false;
                    });
                  }
                },
          backgroundColor: Theme.of(context).primaryColor,
          child: buttonpressed
              ? const Align(
                  alignment: Alignment.centerLeft,
                  child: SpinKitThreeInOut(
                    color: Colors.white,
                    size: 12,
                  ),
                )
              : const Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 30,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
