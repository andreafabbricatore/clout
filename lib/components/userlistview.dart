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

  Widget _listviewitem(String username, String pfp_url) {
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
                pfp_url,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Text(
          "@$username",
          style: TextStyle(
              fontSize: 25,
              color: curruser.username == username
                  ? Color.fromARGB(255, 255, 48, 117)
                  : Colors.black),
        )
      ],
    );

    return GestureDetector(
      onTap: () => {},
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
                child: _listviewitem(
                    userres[index].username, userres[index].pfp_url));
          }),
    );
  }
}
