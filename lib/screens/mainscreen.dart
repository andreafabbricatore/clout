import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/authscreen.dart';
import 'package:clout/screens/createeventscreen.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/screens/favscreen.dart';
import 'package:clout/screens/homescreen.dart';
import 'package:clout/screens/profilescreen.dart';
import 'package:clout/screens/searchscreen.dart';
import 'package:clout/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  List interests;
  List<Event> eventlist;
  List<Event> interesteventlist;
  List interestpics;
  AppUser curruser;
  MainScreen(
      {Key? key,
      required this.interests,
      required this.eventlist,
      required this.interesteventlist,
      required this.interestpics,
      required this.curruser})
      : super(key: key);
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  List Page = [];

  void parampasser(bool updatehome) {
    Page = [
      HomeScreen(
        curruser: widget.curruser,
        interests: widget.interests,
        eventlist: widget.eventlist,
        interestevents: widget.interesteventlist,
        updatehome: updatehome,
      ),
      SearchScreen(
        interestpics: widget.interestpics,
        curruser: widget.curruser,
      ),
      CreateEventScreen(),
      FavScreen(),
      ProfileScreen(
        user: widget.curruser,
        curruser: widget.curruser,
        visit: false,
        interestpics: widget.interestpics,
        interests: widget.interests,
      )
    ];
  }

  @override
  void initState() {
    parampasser(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Page[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (newIndex) {
          if (newIndex == 0) {
            parampasser(true);
          }
          setState(() => _index = newIndex);
        },
        currentIndex: _index,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Color.fromARGB(255, 255, 48, 117),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
              ),
              label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.add,
              ),
              label: "Create"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.bookmark,
              ),
              label: "Favorites"),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_crop_circle),
            label: "Profile",
          )
        ],
        backgroundColor: Colors.white,
      ),
    );
  }
}
