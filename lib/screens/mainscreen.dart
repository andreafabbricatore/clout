import 'package:clout/components/eventlistview.dart';
import 'package:clout/screens/authscreen.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/screens/profilescreen.dart';
import 'package:clout/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  List Page = [HomeScreen(), ProfileScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Page[_index],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (newIndex) => setState(() => _index = newIndex),
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
            icon: Icon(Icons.account_circle_outlined),
            label: "Profile",
          )
        ],
        backgroundColor: Colors.white,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  List<Event> eventlist = [
    Event(
        title: "Football 5 aside",
        description:
            "U18 football for people eager to have fun and play with new people",
        interest: "Sports",
        location: "Thumb Plaza",
        time: "10 p.m.",
        image:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/ModernDance.jpg/1200px-ModernDance.jpg"),
    Event(
        title: "Karaoke Night",
        description:
            "Group of singers organizing fun night for courages and aspiring singers",
        interest: "Music",
        location: "ChinaTown",
        time: "6pm",
        image:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/ModernDance.jpg/1200px-ModernDance.jpg"),
    Event(
        title: "Dance off",
        description:
            "Dance battle for hip hop dancers in the turin area, if you wanna battle and free drinks come along!!",
        interest: "Dancing",
        location: "Parco del Valentino",
        time: "5 p.m.",
        image:
            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/ModernDance.jpg/1200px-ModernDance.jpg"),
  ];

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: const Icon(Icons.menu, color: Colors.grey),
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    Future<Widget?> _navigate(Event event, int index) {
      return Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(seconds: 1),
          pageBuilder: (_, __, ___) => EventDetailScreen(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Clout",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenheight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(),
            Text(
              "Suggested",
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: screenheight * 0.02),
            EventListView(
              eventList: eventlist,
              onTap: _navigate,
            ),
            Text("Popular",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600)),
            EventListView(
              isHorizontal: false,
              eventList: eventlist,
              onTap: _navigate,
            )
          ],
        ),
      ),
    );
  }
}
