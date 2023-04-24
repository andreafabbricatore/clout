import 'package:clout/components/datatextfield.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:clout/components/user.dart';
import 'package:clout/main.dart';
import 'package:clout/screens/authentication/authscreen.dart';
import 'package:clout/screens/authscreens/blockedusersscreen.dart';
import 'package:clout/screens/authscreens/linkphoneauth.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  TextEditingController psw = TextEditingController();

  TextEditingController newpsw = TextEditingController();

  TextEditingController emailaddress = TextEditingController();

  TextEditingController bugcontroller = TextEditingController();

  bool deletebuttonpressed = false;
  bool updatepswbuttonpressed = false;
  bool updateemailbuttonpressed = false;
  bool bugbuttonpressed = false;

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

  void goauthwrapper() {
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
              launchUrl(Uri.parse("https://termify.io/eula/1664706776"));
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
                  Uri.parse("https://termify.io/privacy-policy/1664707655"));
            },
            child: Row(
              children: const [
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
              showDialog(
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
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
                                          color:
                                              Theme.of(context).primaryColor)),
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
                                          await db.reportbug(
                                              bugcontroller.text.trim(),
                                              widget.curruser.uid);
                                          bugcontroller.clear();
                                          Navigator.pop(context);
                                        } catch (e) {
                                          displayErrorSnackBar(
                                              "Invalid Action, try again");
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
            },
            child: Row(
              children: const [
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
          GestureDetector(
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
          ),
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
                    settings: RouteSettings(name: "BlockedUsersScreen")),
              );
            },
            child: Row(
              children: const [
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
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          backgroundColor: Colors.white,
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 20, 10, 10),
                                            height: screenheight * 0.35,
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            child: Column(children: [
                                              const Text("Delete Account",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                              textdatafield(screenwidth * 0.4,
                                                  "Enter Password", psw),
                                              SizedBox(
                                                height: screenheight * 0.04,
                                              ),
                                              GestureDetector(
                                                  onTap: deletebuttonpressed
                                                      ? null
                                                      : () async {
                                                          setState(() {
                                                            deletebuttonpressed =
                                                                true;
                                                          });
                                                          try {
                                                            await db.deleteuser(
                                                                widget
                                                                    .curruser);
                                                            await FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .delete();
                                                            emailaddress
                                                                .clear();
                                                            psw.clear();
                                                            newpsw.clear();
                                                            goauthwrapper();
                                                          } catch (e) {
                                                            displayErrorSnackBar(
                                                                "Invalid Action, try again");
                                                          } finally {
                                                            setState(() {
                                                              deletebuttonpressed =
                                                                  false;
                                                            });
                                                          }
                                                        },
                                                  child: PrimaryButton(
                                                    bold: false,
                                                    screenwidth: screenwidth,
                                                    buttonpressed:
                                                        deletebuttonpressed,
                                                    text: "Delete Account :(",
                                                    buttonwidth:
                                                        screenwidth * 0.7,
                                                  )),
                                            ]),
                                          ),
                                        );
                                      },
                                    );
                                  });
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
}
