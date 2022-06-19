import 'package:clout/components/profiletopcontainer.dart';
import 'package:clout/components/user.dart';
import 'package:clout/main.dart';
import 'package:clout/screens/loading.dart';
import 'package:clout/services/auth.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen(
      {super.key,
      required this.user,
      required this.curruser,
      required this.docid,
      iscurruser});
  AppUser user;
  AppUser curruser;
  bool iscurruser = false;
  String docid;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  db_conn db = db_conn();
  Future<void> refresh() async {
    AppUser updateduser = await db.getUserFromDocID(widget.docid);
    setState(() {
      widget.user = updateduser;
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.iscurruser = widget.user.uid == widget.curruser.uid;
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: widget.iscurruser ? false : true,
        leadingWidth: 0,
        title: Text(
          widget.user.username,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: widget.iscurruser ? 30 : 20),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        actions: widget.iscurruser
            ? [
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
                  ),
                )
              ]
            : [],
        shape: Border(
            bottom: BorderSide(color: Color.fromARGB(55, 158, 158, 158))),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        color: Color.fromARGB(255, 255, 48, 117),
        backgroundColor: Colors.white,
        child: SizedBox(
          child: SingleChildScrollView(
            child: SizedBox(
              height: screenheight,
              width: screenwidth,
              child: Column(children: [
                ProfileTopContainer(user: widget.user),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: Center(
                          child: Text(
                        "Joined Events",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      height: screenheight * 0.045,
                      width: screenwidth * 0.5,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromARGB(55, 158, 158, 158)),
                              right: BorderSide(
                                  color: Color.fromARGB(55, 158, 158, 158)))),
                    ),
                    Container(
                      child: Center(
                          child: Text(
                        "Hosted Events",
                        style: TextStyle(),
                      )),
                      height: screenheight * 0.045,
                      width: screenwidth * 0.5,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromARGB(55, 158, 158, 158)),
                              left: BorderSide(color: Colors.white))),
                    )
                  ],
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
