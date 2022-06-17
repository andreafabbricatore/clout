import 'package:clout/components/searchgridview.dart';
import 'package:clout/screens/interestsearchscreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/event.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen(
      {super.key, required this.interestpics, required this.userdocid});
  List interestpics;
  String userdocid;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  db_conn db = db_conn();
  List interests = [
    "Sports",
    "Nature",
    "Music",
    "Dance",
    "Movies",
    "Acting",
    "Singing",
    "Drinking",
    "Food",
    "Art"
  ];

  Widget _listviewitem(String banner, String interest) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.network(
        banner,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    Future<void> _searchnav(String interest) async {
      List<Event> res = await db.getInterestEvents([interest]);
      print(res);
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => InterestSearchScreen(
                    interest: interest,
                    events: res,
                    userdocid: widget.userdocid,
                  )));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(10, screenheight * 0.1, 10, 10),
        child: Column(children: [
          TextField(
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
          SearchGridView(
            interests: interests,
            interestpics: widget.interestpics,
            onTap: _searchnav,
          )
        ]),
      ),
    );
  }
}
