import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/authscreens/chatlistscreen.dart';
import 'package:clout/screens/authscreens/homescreen.dart';
import 'package:clout/screens/authscreens/searchscreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreenHolder extends StatefulWidget {
  HomeScreenHolder(
      {super.key,
      required this.curruser,
      required this.curruserlocation,
      required this.analytics,
      required this.justloaded});
  AppUser curruser;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  bool justloaded;
  @override
  State<HomeScreenHolder> createState() => _HomeScreenHolderState();
}

class _HomeScreenHolderState extends State<HomeScreenHolder> {
  final controller = PageController(initialPage: 1);

  bool showleading = false;
  void changePage(int index) {
    controller.jumpToPage(index);
  }

  void returnhome() {
    controller.jumpToPage(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: PageView(
        onPageChanged: (index) {},
        controller: controller,
        children: [
          SearchScreen(
              curruser: widget.curruser,
              curruserlocation: widget.curruserlocation,
              analytics: widget.analytics),
          HomeScreen(
            justloaded: widget.justloaded,
            curruser: widget.curruser,
            curruserlocation: widget.curruserlocation,
            analytics: widget.analytics,
            changePage: changePage,
          ),
          ChatListScreen(
            curruser: widget.curruser,
            curruserlocation: widget.curruserlocation,
            analytics: widget.analytics,
            returnHome: returnhome,
          )
        ],
      ),
    );
  }
}
