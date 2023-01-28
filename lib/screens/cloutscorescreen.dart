import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CloutScoreScreen extends StatefulWidget {
  CloutScoreScreen({Key? key, required this.curruser}) : super(key: key);
  AppUser curruser;

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
                  )));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Clout Score",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontWeight: FontWeight.bold,
              fontSize: 30),
          textScaleFactor: 1.0,
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 255, 48, 117),
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenheight * 0.4 + globalrankedusers.length * 80,
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
                "Clout Scores are assigned as following:\n• 20 points for creating an event.\n• 10 points for joining an event.\n• 5 points everytime a user joins an event you created.",
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
