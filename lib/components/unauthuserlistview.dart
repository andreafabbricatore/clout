import 'package:clout/components/user.dart';
import 'package:flutter/material.dart';

class UnAuthUserListView extends StatefulWidget {
  UnAuthUserListView(
      {Key? key,
      required this.userres,
      required this.screenwidth,
      required this.onTap,
      this.physics = const AlwaysScrollableScrollPhysics(),
      this.presentparticipants = const []})
      : super(key: key);
  List<AppUser> userres;
  double screenwidth;
  List presentparticipants;
  var physics;
  final Function(AppUser user, int index)? onTap;

  @override
  State<UnAuthUserListView> createState() => _UnAuthUserListViewState();
}

class _UnAuthUserListViewState extends State<UnAuthUserListView> {
  Widget _listviewitem(
    AppUser user,
    int index,
    double screenwidth,
    List presentparticipants,
    Function(AppUser user, int index)? onTap,
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
      ],
    );

    return GestureDetector(
      onTap: () async {
        await onTap?.call(user, index);
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
                    widget.presentparticipants,
                    widget.onTap));
          }),
    );
  }
}

class UnAuthEventUserListViewItem extends StatefulWidget {
  UnAuthEventUserListViewItem(
      {super.key,
      required this.uid,
      required this.pfp_url,
      required this.screenwidth,
      required this.screenheight,
      required this.username,
      required this.fullname,
      required this.present,
      this.onTap});
  String pfp_url;
  double screenwidth;
  double screenheight;
  String username;
  String fullname;
  String uid;
  bool present;

  final Function(String uid)? onTap;

  @override
  State<UnAuthEventUserListViewItem> createState() =>
      _UnAuthEventUserListViewItemState();
}

class _UnAuthEventUserListViewItemState
    extends State<UnAuthEventUserListViewItem> {
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
                      color: Colors.black),
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
          widget.present
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
