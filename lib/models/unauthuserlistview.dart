import 'package:cached_network_image/cached_network_image.dart';
import 'package:clout/defs/user.dart';
import 'package:flutter/material.dart';

class UnAuthUserListView extends StatefulWidget {
  UnAuthUserListView(
      {Key? key,
      required this.userres,
      required this.screenwidth,
      required this.onTap,
      required this.showaddfriend,
      this.physics = const AlwaysScrollableScrollPhysics(),
      this.presentparticipants = const [],
      this.sendRequest})
      : super(key: key);
  List<AppUser> userres;
  double screenwidth;
  bool showaddfriend;
  List presentparticipants;
  var physics;
  final Function(AppUser user)? onTap;
  Function(AppUser user, int index)? sendRequest;

  @override
  State<UnAuthUserListView> createState() => _UnAuthUserListViewState();
}

class _UnAuthUserListViewState extends State<UnAuthUserListView> {
  bool addfriendbuttonpressed = false;
  Widget _listviewitem(
    AppUser user,
    int index,
    double screenwidth,
    bool showaddfriend,
    List presentparticipants,
    Function(AppUser user)? onTap,
    Function(AppUser user, int index)? sendRequest,
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
              child: CachedNetworkImage(
                imageUrl: user.pfpurl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 10),
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
                    color: Colors.black),
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
        presentparticipants.contains(user.uid)
            ? const Icon(
                Icons.check,
                color: Color.fromARGB(255, 255, 48, 117),
              )
            : Container(),
        showaddfriend
            ? GestureDetector(
                onTap: addfriendbuttonpressed
                    ? null
                    : () {
                        setState(() {
                          addfriendbuttonpressed = true;
                        });
                        sendRequest?.call(user, index);
                        setState(() {
                          addfriendbuttonpressed = false;
                        });
                      },
                child: const Icon(
                  Icons.person_add,
                  color: Colors.black,
                ),
              )
            : Container()
      ],
    );

    return GestureDetector(
      onTap: () async {
        await onTap?.call(user);
      },
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
                  widget.showaddfriend,
                  widget.presentparticipants,
                  widget.onTap,
                  widget.sendRequest));
        });
  }
}
