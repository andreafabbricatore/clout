import 'package:clout/components/searchbarlistview.dart';
import 'package:clout/components/searchgridview.dart';
import 'package:clout/screens/interestsearchscreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
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

  List<Event> searchedevents = [];
  TextEditingController searchcontroller = TextEditingController();
  bool searching = false;
  FocusNode focusNode = FocusNode();
  Color suffixiconcolor = Colors.white;
  Color eventsbuttoncolor = Color.fromARGB(255, 255, 48, 117);
  Color usersbuttoncolor = Colors.black;

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
    focusNode.addListener(() {
      print('1:  ${focusNode.hasFocus}');
    });
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
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Focus(
            onFocusChange: (hasfocus) {
              if (hasfocus) {
                setState(() {
                  searching = hasfocus;
                  suffixiconcolor = Colors.grey;
                });
              }
            },
            child: TextField(
              controller: searchcontroller,
              onChanged: (String searchquery) async {
                List<Event> res = await db.searchEvents(searchquery);
                setState(() {
                  searchedevents = res;
                });
              },
              decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          searching = false;
                          suffixiconcolor = Colors.white;
                        });
                        searchcontroller.clear();
                        FocusScope.of(context).unfocus();
                      },
                      child: Icon(Icons.close, color: suffixiconcolor)),
                  contentPadding: const EdgeInsets.all(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  )),
            ),
          ),
          SizedBox(
            height: screenheight * 0.01,
          ),
          searching
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          eventsbuttoncolor = Color.fromARGB(255, 255, 48, 117);
                          usersbuttoncolor = Colors.black;
                        });
                      },
                      child: SizedBox(
                        height: screenheight * 0.035,
                        width: screenwidth * 0.2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border:
                                Border.all(width: 1, color: eventsbuttoncolor),
                          ),
                          child: Center(child: Text("Events")),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          usersbuttoncolor = Color.fromARGB(255, 255, 48, 117);
                          eventsbuttoncolor = Colors.black;
                        });
                      },
                      child: SizedBox(
                        height: screenheight * 0.035,
                        width: screenwidth * 0.2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border:
                                Border.all(width: 1, color: usersbuttoncolor),
                          ),
                          child: Center(child: Text("Users")),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          searching
              ? SearchBarListView(
                  eventres: searchedevents,
                  userdocid: widget.userdocid,
                )
              : SearchGridView(
                  interests: interests,
                  interestpics: widget.interestpics,
                  onTap: _searchnav,
                )
        ]),
      ),
    );
  }
}
