import 'package:clout/components/user.dart';
import 'package:flutter/material.dart';

class UserListView extends StatefulWidget {
  UserListView({
    Key? key,
    required this.userres,
    required this.onTap,
    required this.curruser,
    required this.screenwidth,
    required this.showcloutscore,
    this.physics = const AlwaysScrollableScrollPhysics(),
  }) : super(key: key);
  List<AppUser> userres;
  AppUser curruser;
  double screenwidth;
  bool showcloutscore;
  var physics;

  final Function(AppUser user)? onTap;

  @override
  State<UserListView> createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  bool ontappressed = false;
  bool removeuserpressed = false;

  Widget _listviewitem(
    AppUser user,
    int index,
    double screenwidth,
    AppUser curruser,
    bool showcloutscore,
    Function(AppUser user)? onTap,
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
                user.fullname,
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
                textScaleFactor: 1.0,
              )
            : Container(),
      ],
    );

    return GestureDetector(
      onTap: ontappressed
          ? null
          : () async {
              setState(() {
                ontappressed = true;
              });
              await onTap?.call(user);
              setState(() {
                ontappressed = false;
              });
            },
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          physics: widget.physics,
          padding: const EdgeInsets.fromLTRB(8, 16, 0, 0),
          shrinkWrap: true,
          itemCount: widget.userres.length,
          itemBuilder: (_, index) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                child: _listviewitem(
                  widget.userres[index],
                  index,
                  widget.screenwidth,
                  widget.curruser,
                  widget.showcloutscore,
                  widget.onTap,
                ));
          }),
    );
  }
}
