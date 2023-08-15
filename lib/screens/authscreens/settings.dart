import 'dart:convert';

import 'package:clout/components/datatextfield.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/main.dart';
import 'package:clout/screens/authentication/authscreen.dart';
import 'package:clout/screens/authscreens/blockedusersscreen.dart';
import 'package:clout/screens/authscreens/linkphoneauth.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key, required this.curruser, required this.analytics})
      : super(key: key);
  AppUser curruser;
  FirebaseAnalytics analytics;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  db_conn db = db_conn();
  applogic logic = applogic();

  TextEditingController psw = TextEditingController();

  TextEditingController newpsw = TextEditingController();

  TextEditingController emailaddress = TextEditingController();

  TextEditingController bugcontroller = TextEditingController();

  bool deletebuttonpressed = false;
  bool updatepswbuttonpressed = false;
  bool updateemailbuttonpressed = false;
  bool bugbuttonpressed = false;
  bool businessbuttonpressed = false;

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

  void goauthwrapper() {
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

  Future<void> stripeSellerOnboarding() async {
    try {
      var response = await http.get(Uri.parse(
          'https://us-central1-clout-1108.cloudfunctions.net/stripeAccount/account?mobile=true&uid=${widget.curruser.uid}'));
      Map<String, dynamic> body = jsonDecode(response.body);
      launchUrl(Uri.parse(body['url']));
    } catch (e) {
      logic.displayErrorSnackBar(
          "Could not initialise registration as seller", context);
    }
  }

  void deleteaccountdialog(
      double screenheight, double screenwidth, String verificationId) {
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
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  height: screenheight * 0.3,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Enter Code to Delete",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        SizedBox(
                          height: screenheight * 0.02,
                        ),
                        Center(
                          child: SizedBox(
                            width: screenwidth * 0.6,
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
                                          width: 1.5,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  textStyle: TextStyle(
                                      fontSize: 25,
                                      color: Theme.of(context).primaryColor)),
                              defaultPinTheme: const PinTheme(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1.5,
                                          color: Color.fromARGB(
                                              255, 151, 149, 149)),
                                    ),
                                  ),
                                  textStyle: TextStyle(fontSize: 25)),
                              onCompleted: (String verificationCode) async {
                                try {
                                  PhoneAuthCredential credential =
                                      PhoneAuthProvider.credential(
                                          verificationId: verificationId,
                                          smsCode: verificationCode);
                                  //link credential
                                  UserCredential usercredential =
                                      await FirebaseAuth.instance
                                          .signInWithCredential(credential);
                                } catch (e) {
                                  logic.displayErrorSnackBar(
                                      "Make sure OTP code was inserted correctly.",
                                      context);
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: screenheight * 0.05,
                        ),
                        GestureDetector(
                            onTap: deletebuttonpressed
                                ? null
                                : () async {
                                    setState(() {
                                      deletebuttonpressed = true;
                                    });
                                    try {
                                      await db.deleteuser(widget.curruser);
                                      await FirebaseAuth.instance.currentUser!
                                          .delete();
                                      emailaddress.clear();
                                      psw.clear();
                                      newpsw.clear();
                                      goauthwrapper();
                                    } catch (e) {
                                      logic.displayErrorSnackBar(
                                          "Invalid Action, try again", context);
                                    } finally {
                                      setState(() {
                                        deletebuttonpressed = false;
                                      });
                                    }
                                  },
                            child: PrimaryButton(
                                screenwidth: screenwidth,
                                buttonpressed: deletebuttonpressed,
                                text: "Delete Account :(",
                                buttonwidth: screenwidth * 0.5,
                                bold: false)),
                      ]),
                ),
              );
            },
          );
        });
  }

  void sellerdialog(double screenheight, double screenwidth) {
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
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  height: screenheight * 0.25,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: screenheight * 0.02,
                        ),
                        const Center(
                            child: Text(
                          "Please use the same\nemail as with your\nClout account!",
                          style: TextStyle(fontSize: 23),
                          textAlign: TextAlign.center,
                        )),
                        SizedBox(
                          height: screenheight * 0.02,
                        ),
                        GestureDetector(
                            onTap: businessbuttonpressed
                                ? null
                                : () async {
                                    setState(() {
                                      businessbuttonpressed = true;
                                    });
                                    await stripeSellerOnboarding();
                                    setState(() {
                                      businessbuttonpressed = false;
                                    });
                                  },
                            child: PrimaryButton(
                                screenwidth: screenwidth,
                                buttonpressed: businessbuttonpressed,
                                text: "Continue",
                                buttonwidth: screenwidth * 0.5,
                                bold: false)),
                      ]),
                ),
              );
            },
          );
        });
  }

  @override
  void dispose() {
    bugcontroller.dispose();
    emailaddress.dispose();
    psw.dispose();
    newpsw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: ListView(children: [
          SizedBox(
            height: screenheight * 0.02,
          ),
          const Text(
            "Privacy",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse("https://outwithclout.com/#/eula/"));
            },
            child: Row(
              children: [
                const Icon(Icons.person, size: 30),
                const SizedBox(
                  width: 6,
                ),
                SizedBox(
                  width: screenwidth * 0.8,
                  child: const Text(
                    "End User License Agreement",
                    style: TextStyle(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          GestureDetector(
            onTap: () {
              launchUrl(
                  Uri.parse("https://outwithclout.com/#/privacy_policy/"));
            },
            child: const Row(
              children: [
                Icon(Icons.bookmark_outline, size: 30),
                SizedBox(
                  width: 6,
                ),
                Text(
                  "Privacy Statement",
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
          ),
          SizedBox(
            height: screenheight * 0.04,
          ),
          const Text(
            "Support",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          GestureDetector(
            onTap: () {
              showbugdialog(context, screenheight, screenwidth);
            },
            child: const Row(
              children: [
                Icon(Icons.bug_report_outlined, size: 30),
                SizedBox(
                  width: 6,
                ),
                Text(
                  "Report a Bug",
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
          ),
          SizedBox(
            height: screenheight * 0.04,
          ),
          const Text(
            "Account",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          widget.curruser.plan != "business"
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => LinkPhoneInputScreen(
                          analytics: widget.analytics,
                          updatephonenumber: true,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.phone_iphone, size: 30),
                      const SizedBox(
                        width: 6,
                      ),
                      SizedBox(
                        width: screenwidth * 0.8,
                        child: const Text(
                          "Update Phone Number",
                          style: TextStyle(fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
          widget.curruser.plan == "business"
              ? GestureDetector(
                  onTap: () {
                    showchangeemaildialog(context, screenheight, screenwidth);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 30),
                      const SizedBox(
                        width: 6,
                      ),
                      SizedBox(
                        width: screenwidth * 0.8,
                        child: const Text(
                          "Update Email Address",
                          style: TextStyle(fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
          widget.curruser.plan == "business"
              ? SizedBox(
                  height: screenheight * 0.02,
                )
              : Container(),
          widget.curruser.plan == "business"
              ? GestureDetector(
                  onTap: () {
                    showchangepswdialog(context, screenheight, screenwidth);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline, size: 30),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        "Update Password",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                )
              : Container(),
          SizedBox(
            height: screenheight * 0.02,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => BlockedUsersScreen(
                          curruser: widget.curruser,
                        ),
                    settings: const RouteSettings(name: "BlockedUsersScreen")),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.block, size: 30),
                SizedBox(
                  width: 6,
                ),
                Text(
                  "Blocked Users",
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
          ),
          widget.curruser.plan == "business"
              ? SizedBox(
                  height: screenheight * 0.02,
                )
              : Container(),
          widget.curruser.plan == "business" &&
                  widget.curruser.stripeaccountid == ""
              ? GestureDetector(
                  onTap: () {
                    sellerdialog(screenheight, screenwidth);
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.payment, size: 30),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        "Become a Seller",
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                )
              : Container(),
          SizedBox(
            height: screenheight * 0.05,
          ),
          GestureDetector(
              onTap: () async {
                await db.cleartokens(widget.curruser);
                await FirebaseAuth.instance.signOut();
                goauthwrapper();
              },
              child: Center(
                child: Text(
                  "Log Out",
                  style: TextStyle(
                      fontSize: 20, color: Theme.of(context).primaryColor),
                ),
              )),
          SizedBox(
            height: screenheight * 0.55,
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                        height: screenheight * 0.25,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(children: [
                          const Text("Delete Account",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25)),
                          SizedBox(
                            height: screenheight * 0.02,
                          ),
                          const Text(
                            "Are you sure you want to permanently delete you account?",
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: screenheight * 0.02,
                          ),
                          SizedBox(
                            height: screenheight * 0.02,
                          ),
                          GestureDetector(
                            onTap: widget.curruser.plan == "business"
                                ? () {
                                    businessdeleteaccountdialog(
                                        context, screenheight, screenwidth);
                                  }
                                : () async {
                                    await FirebaseAuth.instance
                                        .verifyPhoneNumber(
                                      phoneNumber: FirebaseAuth
                                          .instance.currentUser!.phoneNumber,
                                      verificationCompleted:
                                          (PhoneAuthCredential credential) {},
                                      verificationFailed:
                                          (FirebaseAuthException e) {
                                        logic.displayErrorSnackBar(
                                            "Could not verify phone number",
                                            context);
                                      },
                                      codeSent: (String verificationId,
                                          int? resendToken) {
                                        deleteaccountdialog(screenheight,
                                            screenwidth, verificationId);
                                      },
                                      codeAutoRetrievalTimeout:
                                          (String verificationId) {},
                                    );
                                  },
                            child: SizedBox(
                                height: 50,
                                width: screenwidth * 0.7,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20))),
                                  child: const Center(
                                      child: Text(
                                    "Delete Account",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  )),
                                )),
                          ),
                        ]),
                      ),
                    );
                  });
            },
            child: Center(
              child: Text(
                "Delete Account",
                style: TextStyle(
                    fontSize: 20, color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<dynamic> businessdeleteaccountdialog(
      BuildContext context, double screenheight, double screenwidth) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  height: screenheight * 0.35,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(children: [
                    const Text("Delete Account",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 25)),
                    SizedBox(
                      height: screenheight * 0.02,
                    ),
                    const Text(
                      "We hate to see you go...\nEnter Password to permamently delete your account",
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: screenheight * 0.02,
                    ),
                    textdatafield(screenwidth * 0.4, "Enter Password", psw),
                    SizedBox(
                      height: screenheight * 0.04,
                    ),
                    GestureDetector(
                        onTap: deletebuttonpressed
                            ? null
                            : () async {
                                setState(() {
                                  deletebuttonpressed = true;
                                });
                                try {
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: widget.curruser.email,
                                          password: psw.text.trim());
                                  await db.deleteuser(widget.curruser);
                                  await FirebaseAuth.instance.currentUser!
                                      .delete();
                                  emailaddress.clear();
                                  psw.clear();
                                  newpsw.clear();
                                  goauthwrapper();
                                } catch (e) {
                                  logic.displayErrorSnackBar(
                                      "Invalid Action, try again", context);
                                } finally {
                                  setState(() {
                                    deletebuttonpressed = false;
                                  });
                                }
                              },
                        child: PrimaryButton(
                          bold: false,
                          screenwidth: screenwidth,
                          buttonpressed: deletebuttonpressed,
                          text: "Delete Account :(",
                          buttonwidth: screenwidth * 0.7,
                        )),
                  ]),
                ),
              );
            },
          );
        });
  }

  Future<dynamic> showchangepswdialog(
      BuildContext context, double screenheight, double screenwidth) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                height: screenheight * 0.4,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(children: [
                  const Text(
                    "Change Password",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                    textScaleFactor: 1.0,
                  ),
                  SizedBox(
                    height: screenheight * 0.02,
                  ),
                  const Text(
                    "In order to change password,\nenter old and new password",
                    style: TextStyle(fontSize: 15),
                    textScaleFactor: 1.1,
                  ),
                  SizedBox(
                    height: screenheight * 0.02,
                  ),
                  textdatafield(screenwidth * 0.4, "Old Password", psw),
                  textdatafield(screenwidth * 0.4, "New Password", newpsw),
                  SizedBox(
                    height: screenheight * 0.04,
                  ),
                  GestureDetector(
                      onTap: updatepswbuttonpressed
                          ? null
                          : () async {
                              setState(() {
                                updatepswbuttonpressed = true;
                              });
                              try {
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: widget.curruser.email,
                                        password: psw.text.trim());
                                if (newpsw.text.trim().isEmpty) {
                                  throw Exception("Please enter new password");
                                }
                                await FirebaseAuth.instance.currentUser!
                                    .updatePassword(newpsw.text.trim());
                                emailaddress.clear();
                                psw.clear();
                                newpsw.clear();
                                goauthwrapper();
                              } catch (e) {
                                logic.displayErrorSnackBar(
                                    "Invalid Action, try again", context);
                              } finally {
                                setState(() {
                                  updatepswbuttonpressed = false;
                                });
                              }
                            },
                      child: PrimaryButton(
                          screenwidth: screenwidth,
                          buttonpressed: updatepswbuttonpressed,
                          text: "Update",
                          buttonwidth: screenwidth * 0.7,
                          bold: false)),
                ]),
              ),
            );
          });
        });
  }

  Future<dynamic> showchangeemaildialog(
      BuildContext context, double screenheight, double screenwidth) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: ((context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                height: screenheight * 0.4,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(children: [
                  const Text(
                    "Change Email",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                    textScaleFactor: 1.0,
                  ),
                  SizedBox(
                    height: screenheight * 0.02,
                  ),
                  const Text(
                    "In order to change email address,\nenter new address and re-enter password",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    textScaleFactor: 1.1,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: screenheight * 0.02,
                  ),
                  textdatafield(screenwidth * 0.4, "New Email", emailaddress),
                  textdatafield(screenwidth * 0.4, "Password", psw),
                  SizedBox(
                    height: screenheight * 0.04,
                  ),
                  GestureDetector(
                      onTap: updateemailbuttonpressed
                          ? null
                          : () async {
                              setState(() {
                                updateemailbuttonpressed = true;
                              });
                              try {
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: widget.curruser.email,
                                        password: psw.text.trim());
                                if (emailaddress.text.trim().isEmpty) {
                                  throw Exception(
                                      "Please enter new email address");
                                }
                                await db.changeattribute(
                                    'email',
                                    emailaddress.text.trim(),
                                    FirebaseAuth.instance.currentUser!.uid);
                                await FirebaseAuth.instance.currentUser!
                                    .updateEmail(emailaddress.text.trim());
                                emailaddress.clear();
                                psw.clear();
                                newpsw.clear();
                                goauthwrapper();
                              } catch (e) {
                                logic.displayErrorSnackBar(
                                    "Invalid Action, try again", context);
                              } finally {
                                updateemailbuttonpressed = false;
                              }
                            },
                      child: PrimaryButton(
                          screenwidth: screenwidth,
                          buttonpressed: updateemailbuttonpressed,
                          text: "Update",
                          buttonwidth: screenwidth * 0.7,
                          bold: false)),
                ]),
              ),
            );
          }));
        });
  }

  Future<dynamic> showbugdialog(
      BuildContext context, double screenheight, double screenwidth) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: ((context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                height: screenheight * 0.33,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Column(children: [
                  const Text(
                    "Report a Bug",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                    textScaleFactor: 1.0,
                  ),
                  SizedBox(
                    height: screenheight * 0.02,
                  ),
                  const Text(
                    "Please describe the bug",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: screenheight * 0.02,
                  ),
                  SizedBox(
                    width: screenwidth * 0.6,
                    child: TextField(
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        hintText: "Bug Description",
                        hintStyle: const TextStyle(
                          color: Color.fromARGB(39, 0, 0, 0),
                          fontSize: 15,
                        ),
                      ),
                      textAlign: TextAlign.start,
                      enableSuggestions: true,
                      autocorrect: true,
                      controller: bugcontroller,
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(
                    height: screenheight * 0.04,
                  ),
                  GestureDetector(
                      onTap: bugbuttonpressed
                          ? null
                          : () async {
                              setState(() {
                                bugbuttonpressed = true;
                              });
                              try {
                                await db.reportbug(bugcontroller.text.trim(),
                                    widget.curruser.uid);
                                bugcontroller.clear();
                                Navigator.pop(context);
                              } catch (e) {
                                logic.displayErrorSnackBar(
                                    "Invalid Action, try again", context);
                              } finally {
                                bugbuttonpressed = false;
                              }
                            },
                      child: PrimaryButton(
                        bold: false,
                        buttonwidth: screenwidth * 0.6,
                        screenwidth: screenwidth,
                        buttonpressed: bugbuttonpressed,
                        text: "Report",
                      )),
                ]),
              ),
            );
          }));
        });
  }
}
