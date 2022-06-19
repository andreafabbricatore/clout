import 'package:clout/components/user.dart';
import 'package:flutter/material.dart';

class UserListView extends StatelessWidget {
  UserListView(
      {Key? key,
      required this.userres,
      required this.onTap,
      required this.curruser})
      : super(key: key);
  List<AppUser> userres;
  AppUser curruser;
  final Function(AppUser user, int index)? onTap;

  Widget _listviewitem(AppUser user, int index) {
    Widget widget;
    widget = Row(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
          child: SizedBox(
            height: 35,
            width: 35,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Image.network(
                user.pfp_url,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Text(
          "@${user.username}",
          style: TextStyle(
              fontSize: 25,
              color: curruser.username == user.username
                  ? Color.fromARGB(255, 255, 48, 117)
                  : Colors.black),
        )
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
