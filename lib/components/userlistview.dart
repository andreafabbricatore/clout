import 'package:clout/components/event.dart';
import 'package:clout/components/user.dart';
import 'package:flutter/material.dart';

class UserListView extends StatelessWidget {
  UserListView(
      {Key? key,
      required this.userres,
      required this.onTap,
      required this.curruser,
      required this.screenwidth,
      required this.showcloutscore,
      required this.showrembutton,
      this.removeUser,
      this.removebuttonblack = false,
      this.physics = const AlwaysScrollableScrollPhysics()})
      : super(key: key);
  List<AppUser> userres;
  AppUser curruser;
  double screenwidth;
  bool showcloutscore;
  bool showrembutton;
  bool removebuttonblack;
  var physics;

  final Function(AppUser user, int index)? onTap;
  final Function(AppUser user, int index)? removeUser;

  Widget _listviewitem(
    AppUser user,
    int index,
  ) {
    Widget widget;
    widget = Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
          child: SizedBox(
            height: 50,
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Image.network(
                user.pfpurl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(
          width: screenwidth * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "@${user.username}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: curruser.username == user.username
                        ? const Color.fromARGB(255, 255, 48, 117)
                        : Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "${user.fullname}",
                style: const TextStyle(fontSize: 15, color: Colors.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        showcloutscore
            ? Text(
                "${user.clout}",
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              )
            : Container(),
        showrembutton && user.docid != curruser.docid
            ? GestureDetector(
                onTap: () {
                  removeUser?.call(user, index);
                },
                child: Icon(
                  Icons.remove_circle_outline,
                  color: removebuttonblack
                      ? Colors.black
                      : const Color.fromARGB(255, 255, 48, 117),
                ),
              )
            : Container()
      ],
    );

    return GestureDetector(
      onTap: () => onTap?.call(user, index),
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          physics: physics,
          padding: const EdgeInsets.fromLTRB(8, 16, 0, 0),
          shrinkWrap: true,
          itemCount: userres.length,
          itemBuilder: (_, index) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                child: _listviewitem(userres[index], index));
          }),
    );
  }
}
