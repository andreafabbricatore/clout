import 'package:cached_network_image/cached_network_image.dart';
import 'package:clout/defs/user.dart';
import 'package:flutter/material.dart';

class ProfileTopContainer extends StatefulWidget {
  ProfileTopContainer(
      {Key? key,
      required this.user,
      required this.curruser,
      required this.iscurruser,
      required this.friend,
      required this.editprofile,
      required this.friendsscreen,
      required this.cloutscreen,
      required this.refer})
      : super(key: key);
  AppUser user;
  AppUser curruser;
  bool iscurruser;
  final Function() friend;
  final VoidCallback editprofile;
  final VoidCallback friendsscreen;
  final VoidCallback cloutscreen;
  final VoidCallback refer;

  @override
  State<ProfileTopContainer> createState() => _ProfileTopContainerState();
}

class _ProfileTopContainerState extends State<ProfileTopContainer> {
  bool buttonpressed = false;
  String friendval = "";

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  void setfriendval() {
    if (widget.curruser.friends.contains(widget.user.uid)) {
      setState(() {
        friendval = "Remove Friend";
      });
    } else if (widget.curruser.requested.contains(widget.user.uid)) {
      setState(() {
        friendval = "Request Sent";
      });
    } else if (!widget.curruser.requested.contains(widget.user.uid)) {
      setState(() {
        friendval = "Add Friend";
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    setfriendval();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Container(
      height: widget.iscurruser
          ? widget.user.bio == ""
              ? screenheight * 0.27
              : screenheight * 0.31
          : widget.user.bio == ""
              ? screenheight * 0.21
              : screenheight * 0.25,
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color.fromARGB(55, 158, 158, 158)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.iscurruser
              ? GestureDetector(
                  onTap: widget.refer,
                  child: Center(
                    child: Container(
                      height: screenheight * 0.05,
                      width: screenwidth,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      child: const Center(
                        child: Text(
                          "Invite your friends to Clout!",
                          textScaleFactor: 1.0,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 10),
                    imageUrl: widget.user.pfpurl,
                    height: screenheight * 0.15,
                    width: screenheight * 0.15,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: screenwidth * 0.1,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: screenheight * 0.02,
                    ),
                    SizedBox(
                      width: screenwidth * 0.5,
                      child: Text(
                        "${widget.user.fullname}, ${calculateAge(widget.user.birthday)}",
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                        textScaleFactor: 1.0,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height: screenheight * 0.01,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: widget.iscurruser
                              ? () {
                                  widget.cloutscreen();
                                }
                              : () {},
                          child: Text(
                            "${widget.user.clout} Clout",
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          width: screenwidth * 0.025,
                        ),
                        const Text(
                          "-",
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.0,
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                        SizedBox(
                          width: screenwidth * 0.025,
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.friendsscreen();
                          },
                          child: Text(
                            "${widget.user.friends.length} Friends",
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.0,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: screenheight * 0.02,
                    ),
                    widget.iscurruser
                        ? GestureDetector(
                            onTap: () {
                              widget.editprofile();
                            },
                            child: Container(
                              height: screenheight * 0.03,
                              width: screenwidth * 0.4,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          161, 158, 158, 158))),
                              child: const Center(
                                  child: Text(
                                "Edit Profile",
                                textScaleFactor: 0.9,
                              )),
                            ),
                          )
                        : GestureDetector(
                            onTap: buttonpressed
                                ? null
                                : () async {
                                    setState(() {
                                      buttonpressed = true;
                                    });
                                    await widget.friend();
                                    setState(() {
                                      buttonpressed = false;
                                    });
                                    setfriendval();
                                    print(friendval);
                                  },
                            child: Container(
                              height: screenheight * 0.03,
                              width: screenwidth * 0.4,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          161, 158, 158, 158))),
                              child: Center(
                                  child: Text(
                                friendval,
                                textScaleFactor: 1.0,
                              )),
                            ),
                          )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          widget.user.bio == ""
              ? Container()
              : Column(children: [
                  SizedBox(
                    height: screenheight * 0.01,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 20, 0),
                    child: Text(
                      widget.user.bio,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w300),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ]),
        ],
      ),
    );
  }
}
