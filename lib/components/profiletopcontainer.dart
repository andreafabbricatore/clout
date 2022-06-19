import 'package:clout/components/user.dart';
import 'package:flutter/material.dart';

class ProfileTopContainer extends StatelessWidget {
  ProfileTopContainer({Key? key, required this.user}) : super(key: key);
  AppUser user;
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
                Text(
                  "${user.followers.length}\nFollowers",
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: screenwidth * 0.05,
                ),
                Text(
                  "${user.following.length}\nFollowing",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Text(
              user.fullname,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
          )
        ],
      ),
    );
  }
}
