import 'package:clout/components/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventUserListViewItem extends StatefulWidget {
  EventUserListViewItem(
      {super.key,
      required this.uid,
      required this.pfp_url,
      required this.screenwidth,
      required this.screenheight,
      required this.username,
      required this.fullname,
      required this.curruser,
      required this.present,
      this.removeUser,
      this.onTap});
  String pfp_url;
  double screenwidth;
  double screenheight;
  String username;
  String fullname;
  String uid;
  bool present;
  AppUser curruser;

  final Function(String uid)? removeUser;
  final Function(String uid)? onTap;

  @override
  State<EventUserListViewItem> createState() => _EventUserListViewItemState();
}

class _EventUserListViewItemState extends State<EventUserListViewItem> {
  bool removeuserpressed = false;
  bool ontappressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontappressed
          ? null
          : () async {
              setState(() {
                ontappressed = true;
              });
              await widget.onTap?.call(widget.uid);
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
                  widget.pfp_url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            width: widget.screenwidth * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@${widget.username}",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.curruser.username == widget.username
                          ? const Color.fromARGB(255, 255, 48, 117)
                          : Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.fullname,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          widget.uid != widget.curruser.uid
              ? GestureDetector(
                  onTap: removeuserpressed
                      ? null
                      : () {
                          setState(() {
                            removeuserpressed = true;
                          });
                          widget.removeUser?.call(widget.uid);
                          setState(() {
                            removeuserpressed = false;
                          });
                        },
                  child: Icon(
                    Icons.remove_circle_outline,
                    color: const Color.fromARGB(255, 255, 48, 117),
                  ),
                )
              : widget.present
                  ? const Icon(
                      Icons.check,
                      color: Color.fromARGB(255, 255, 48, 117),
                    )
                  : Container(),
        ],
      ),
    );
  }
}
