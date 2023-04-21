import 'package:clout/components/user.dart';
import 'package:flutter/material.dart';

class UserListView extends StatefulWidget {
  UserListView(
      {Key? key,
      required this.userres,
      required this.onTap,
      required this.curruser,
      required this.screenwidth,
      required this.showcloutscore,
      required this.showrembutton,
      required this.showsendbutton,
      this.removeUser,
      this.removebuttonblack = false,
      this.physics = const AlwaysScrollableScrollPhysics(),
      this.presentparticipants = const [],
      this.selectedsenders = const [],
      this.toppadding = true})
      : super(key: key);
  List<AppUser> userres;
  AppUser curruser;
  double screenwidth;
  bool showcloutscore;
  bool showrembutton;
  bool removebuttonblack;
  List presentparticipants;
  List selectedsenders;
  bool toppadding;
  bool showsendbutton;
  var physics;

  final Function(AppUser user, int index)? onTap;
  final Function(AppUser user, int index)? removeUser;

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
      bool showrembutton,
      bool removebuttonblack,
      bool showsendbutton,
      Function(AppUser user, int index)? removeUser,
      Function(AppUser user, int index)? onTap,
      List presentparticipants,
      List selectedsenders) {
    return GestureDetector(
      onTap: ontappressed
          ? null
          : () async {
              setState(() {
                ontappressed = true;
              });
              await onTap?.call(user, index);
              setState(() {
                ontappressed = false;
              });
            },
      child: Row(
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
          showrembutton && user.uid != curruser.uid
              ? GestureDetector(
                  onTap: removeuserpressed
                      ? null
                      : () {
                          setState(() {
                            removeuserpressed = true;
                          });
                          removeUser?.call(user, index);
                          setState(() {
                            removeuserpressed = false;
                          });
                        },
                  child: Icon(
                    Icons.remove_circle_outline,
                    color: removebuttonblack
                        ? Colors.black
                        : const Color.fromARGB(255, 255, 48, 117),
                  ),
                )
              : presentparticipants.contains(user.uid)
                  ? const Icon(
                      Icons.check,
                      color: Color.fromARGB(255, 255, 48, 117),
                    )
                  : Container(),
          showsendbutton
              ? Icon(
                  selectedsenders.contains(user.uid)
                      ? Icons.circle
                      : Icons.circle_outlined,
                  color: selectedsenders.contains(user.uid)
                      ? Color.fromARGB(255, 255, 48, 117)
                      : Colors.black,
                )
              : Container()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: widget.physics,
        padding: EdgeInsets.fromLTRB(8, widget.toppadding ? 16 : 0, 0, 0),
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
                  widget.showrembutton,
                  widget.removebuttonblack,
                  widget.showsendbutton,
                  widget.removeUser,
                  widget.onTap,
                  widget.presentparticipants,
                  widget.selectedsenders));
        });
  }
}
