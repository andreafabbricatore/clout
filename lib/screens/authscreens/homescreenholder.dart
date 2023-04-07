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
    controller.animateToPage(index,
        duration: const Duration(milliseconds: 250), curve: Curves.linear);
  }

  void returnhome() {
    controller.animateToPage(1,
        duration: const Duration(milliseconds: 250), curve: Curves.linear);
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
