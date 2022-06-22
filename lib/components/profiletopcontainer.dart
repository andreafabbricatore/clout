import 'package:clout/components/user.dart';
import 'package:clout/screens/editprofilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';

class ProfileTopContainer extends StatelessWidget {
  ProfileTopContainer(
      {Key? key,
      required this.user,
      required this.curruser,
      required this.iscurruser,
      required this.curruserdocid,
      required this.userdocid,
      required this.follow,
      required this.editprofile,
      required this.followerscreen,
      required this.followingscreen})
      : super(key: key);
  AppUser user;
  AppUser curruser;
  String curruserdocid;
  String userdocid;
  bool iscurruser;
  final VoidCallback follow;
  final VoidCallback editprofile;
  final VoidCallback followerscreen;
  final VoidCallback followingscreen;

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Container(
      height: screenheight * 0.2,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Color.fromARGB(55, 158, 158, 158)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: screenheight * 0.035,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    user.pfp_url,
                    height: screenheight * 0.1,
                    width: screenheight * 0.1,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: screenwidth * 0.15,
                ),
                Text(
                  "${user.clout}\nClout",
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: screenwidth * 0.05,
                ),
                GestureDetector(
                  onTap: () {
                    followerscreen();
                  },
                  child: Text(
                    "${user.followers.length}\nFollowers",
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: screenwidth * 0.05,
                ),
                GestureDetector(
                  onTap: () {
                    followingscreen();
                  },
                  child: Text(
                    "${user.following.length}\nFollowing",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  user.fullname,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                ),
                iscurruser
                    ? GestureDetector(
                        onTap: () {
                          editprofile();
                        },
                        child: Container(
                          height: screenheight * 0.025,
                          width: screenheight * 0.1,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              border: Border.all(
                                  color: Color.fromARGB(161, 158, 158, 158))),
                          child: Center(child: Text("Edit Profile")),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          follow();
                        },
                        child: Container(
                          height: screenheight * 0.03,
                          width: curruser.following.contains(userdocid)
                              ? screenwidth * 0.3
                              : screenwidth * 0.2,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              border: Border.all(
                                  color: Color.fromARGB(161, 158, 158, 158))),
                          child: Center(
                              child: Text(
                            curruser.following.contains(userdocid)
                                ? "Stop Following"
                                : "Follow",
                            style: TextStyle(fontSize: 15),
                          )),
                        ),
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}
