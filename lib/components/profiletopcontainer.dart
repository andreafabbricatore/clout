import 'package:clout/components/user.dart';
import 'package:flutter/material.dart';

class ProfileTopContainer extends StatefulWidget {
  ProfileTopContainer(
      {Key? key,
      required this.user,
      required this.curruser,
      required this.iscurruser,
      required this.follow,
      required this.editprofile,
      required this.followerscreen,
      required this.followingscreen,
      required this.cloutscreen})
      : super(key: key);
  AppUser user;
  AppUser curruser;
  bool iscurruser;
  final VoidCallback follow;
  final VoidCallback editprofile;
  final VoidCallback followerscreen;
  final VoidCallback followingscreen;
  final VoidCallback cloutscreen;

  @override
  State<ProfileTopContainer> createState() => _ProfileTopContainerState();
}

class _ProfileTopContainerState extends State<ProfileTopContainer> {
  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Container(
      height: screenheight * 0.2,
      decoration: const BoxDecoration(
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
                    widget.user.pfpurl,
                    height: screenheight * 0.1,
                    width: screenheight * 0.1,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: screenwidth * 0.15,
                ),
                GestureDetector(
                  onTap: widget.iscurruser
                      ? () {
                          widget.cloutscreen();
                        }
                      : () {},
                  child: Text(
                    "${widget.user.clout}\nClout",
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
                  ),
                ),
                SizedBox(
                  width: screenwidth * 0.05,
                ),
                GestureDetector(
                  onTap: () {
                    widget.followerscreen();
                  },
                  child: Text(
                    "${widget.user.followers.length}\nFollowers",
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
                  ),
                ),
                SizedBox(
                  width: screenwidth * 0.05,
                ),
                GestureDetector(
                  onTap: () {
                    widget.followingscreen();
                  },
                  child: Text(
                    "${widget.user.following.length}\nFollowing",
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
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
                  widget.user.fullname,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w300),
                  textScaleFactor: 1.0,
                ),
                widget.iscurruser
                    ? GestureDetector(
                        onTap: () {
                          widget.editprofile();
                        },
                        child: Container(
                          height: screenheight * 0.025,
                          width: screenheight * 0.1,
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
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
                        onTap: () {
                          widget.follow();
                        },
                        child: Container(
                          height: screenheight * 0.03,
                          width: widget.curruser.following
                                  .contains(widget.user.docid)
                              ? screenwidth * 0.3
                              : screenwidth * 0.2,
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(
                                  color: const Color.fromARGB(
                                      161, 158, 158, 158))),
                          child: Center(
                              child: Text(
                            widget.curruser.following
                                    .contains(widget.user.docid)
                                ? "Stop Following"
                                : "Follow",
                            style: const TextStyle(fontSize: 15),
                            textScaleFactor: 1.0,
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
