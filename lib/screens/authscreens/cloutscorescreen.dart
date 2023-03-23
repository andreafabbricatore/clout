import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/authscreens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CloutScoreScreen extends StatefulWidget {
  CloutScoreScreen(
      {Key? key,
      required this.curruser,
      required this.curruserlocation,
      required this.analytics})
      : super(key: key);
  AppUser curruser;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;

  @override
  State<CloutScoreScreen> createState() => _CloutScoreScreenState();
}

class _CloutScoreScreenState extends State<CloutScoreScreen> {
  List<AppUser> globalrankedusers = [];

  db_conn db = db_conn();

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

  Future<void> getUserList() async {
    try {
      List<AppUser> temp = await db.getAllUsersRankedByCloutScore();
      setState(() {
        globalrankedusers = temp;
      });
    } catch (e) {
      displayErrorSnackBar("Could not get user rankings");
    }
  }

  Future<String> createShareLink() async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(
          "https://outwithclout.com/#/referral/${widget.curruser.uid}"),
      uriPrefix: "https://outwithclout.page.link",
    );
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    return dynamicLink.shortUrl.toString();
  }

  void refer(String text) async {
    final box = context.findRenderObject() as RenderBox?;
    await widget.analytics.logEvent(name: "referred_user", parameters: {});
    await Share.share(
      text,
      subject: "${widget.curruser.fullname} wants you to join them on Clout",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  void initState() {
    super.initState();
    getUserList();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> usernavigate(AppUser user, int index) async {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => ProfileScreen(
                    user: user,
                    curruser: widget.curruser,
                    visit: true,
                    curruserlocation: widget.curruserlocation,
                    analytics: widget.analytics,
                  ),
              settings: RouteSettings(name: "ProfileScreen")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Clout Score",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30),
          textScaleFactor: 1.0,
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenheight * 0.8 + globalrankedusers.length * 60,
            width: screenwidth,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: screenheight * 0.01,
              ),
              const Text(
                "What is your Clout Score?",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
                textScaleFactor: 1.0,
              ),
              SizedBox(
                height: screenheight * 0.01,
              ),
              const Text(
                "It is a measure of your popularity based on how many events you join or create.",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w200,
                    fontSize: 20),
                textScaleFactor: 1.0,
              ),
              SizedBox(
                height: screenheight * 0.02,
              ),
              const Text(
                "How is it measured?",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
                textScaleFactor: 1.0,
              ),
              SizedBox(
                height: screenheight * 0.01,
              ),
              const Text(
                "Clout Scores are assigned as following:\n• 20 points for creating an event.\n• 10 points for participating in an event.\n• 5 points everytime a user participates in an event you host. \n• 30 points every time you invite a new person on Clout\n• 20 points when you're invited on Clout",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w200,
                    fontSize: 20),
                textScaleFactor: 1.0,
              ),
              SizedBox(
                height: screenheight * 0.02,
              ),
              GestureDetector(
                onTap: () async {
                  String link = await createShareLink();
                  String text =
                      "${widget.curruser.fullname} wants you to join them on Clout.\nPress the link after signing up to boost your Clout score.\n\n$link";
                  refer(text);
                },
                child: Container(
                  height: screenheight * 0.05,
                  width: screenwidth,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      "Friends invited: ${widget.curruser.referred.length}",
                      textScaleFactor: 1.0,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenheight * 0.02,
              ),
              const Text(
                "Global Ranking",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30),
                textScaleFactor: 1.0,
              ),
              SizedBox(
                height: screenheight * 0.01,
              ),
              UserListView(
                userres: globalrankedusers,
                onTap: usernavigate,
                curruser: widget.curruser,
                screenwidth: screenwidth,
                showcloutscore: true,
                showrembutton: false,
                physics: const NeverScrollableScrollPhysics(),
              ),
              SizedBox(
                height: screenheight * 0.02,
              )
            ]),
          ),
        ),
      ),
    );
  }
}
