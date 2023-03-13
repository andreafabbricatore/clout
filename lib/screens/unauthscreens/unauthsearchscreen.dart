import 'package:clout/components/location.dart';
import 'package:clout/components/searchgridview.dart';
import 'package:clout/components/unauthsearchbarlistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/unauthscreens/unauthinterestsearchscreen.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:clout/components/event.dart';

class UnAuthSearchScreen extends StatefulWidget {
  UnAuthSearchScreen(
      {super.key, required this.curruserlocation, required this.analytics});
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  @override
  State<UnAuthSearchScreen> createState() => _UnAuthSearchScreenState();
}

class _UnAuthSearchScreenState extends State<UnAuthSearchScreen> {
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
    "Art",
    "Animals",
    "Fashion",
    "Cooking",
    "Culture",
    "Travel",
    "Games"
  ];

  List<Event> searchedevents = [];
  List<AppUser> searchedusers = [];
  TextEditingController searchcontroller = TextEditingController();
  bool searching = false;
  bool searchevents = true;
  FocusNode focusNode = FocusNode();
  Color suffixiconcolor = Colors.white;

  void displayErrorSnackBar(
    String error,
  ) {
    final snackBar = SnackBar(
      content: Text(
        error,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color.fromARGB(230, 255, 48, 117),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: false,
      closeIconColor: Colors.white,
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void gotointerestsearchscreen(
      String interest, List<Event> interesteventlist) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => UnAuthInterestSearchScreen(
                  interest: interest,
                  events: interesteventlist,
                  curruserlocation: widget.curruserlocation,
                  analytics: widget.analytics,
                ),
            settings: RouteSettings(name: "InterestSearchScreen")));
  }

  @override
  void initState() {
    focusNode.addListener(() {
      //print('1:  ${focusNode.hasFocus}');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    Future<void> searchnav(String interest) async {
      try {
        List<Event> interesteventlist = [];
        interesteventlist = await db.UnAuthgetLngLatEventsByInterest(
          widget.curruserlocation.center[0],
          widget.curruserlocation.center[1],
          interest,
          widget.curruserlocation.country,
        );
        gotointerestsearchscreen(interest, interesteventlist);
        //print(interesteventlist);
      } catch (e) {
        displayErrorSnackBar("Could not display events");
      }
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
            child: Row(
              children: [
                SizedBox(
                  width: screenwidth * 0.945,
                  child: TextField(
                    controller: searchcontroller,
                    onChanged: (String searchquery) async {
                      if (searchevents) {
                        try {
                          List<Event> res =
                              await db.UnAuthsearchEvents(searchquery.trim());
                          setState(() {
                            searchedevents = res;
                          });
                        } catch (e) {
                          displayErrorSnackBar("Could not search events");
                        }
                      } else {
                        try {
                          List<AppUser> res =
                              await db.UnAuthsearchUsers(searchquery.trim());
                          setState(() {
                            searchedusers = res;
                          });
                        } catch (e) {
                          displayErrorSnackBar("Could not search users");
                        }
                      }
                    },
                    decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: GestureDetector(
                            onTap: searching
                                ? () {
                                    if (searchcontroller.text.isNotEmpty) {
                                      searchcontroller.clear();
                                    } else {
                                      setState(() {
                                        searching = false;
                                        suffixiconcolor = Colors.white;
                                        searchedusers = [];
                                        searchedevents = [];
                                      });
                                      FocusScope.of(context).unfocus();
                                    }
                                  }
                                : null,
                            child: Icon(Icons.close, color: suffixiconcolor)),
                        contentPadding: const EdgeInsets.all(20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        )),
                  ),
                ),
              ],
            ),
          ),
          searching
              ? SizedBox(
                  height: screenheight * 0.02,
                )
              : Container(),
          searching
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () async {
                        setState(() {
                          searchedusers = [];
                          searchevents = true;
                        });
                        try {
                          List<Event> res = await db.UnAuthsearchEvents(
                              searchcontroller.text);
                          setState(() {
                            searchedevents = res;
                          });
                        } catch (e) {
                          displayErrorSnackBar("Could not search events");
                        }
                      },
                      child: SizedBox(
                        height: screenheight * 0.035,
                        width: screenwidth * 0.2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                width: 1,
                                color: searchevents
                                    ? Theme.of(context).primaryColor
                                    : Colors.black),
                          ),
                          child: const Center(child: Text("Events")),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          searchedevents = [];
                          searchevents = false;
                        });
                        try {
                          List<AppUser> res =
                              await db.UnAuthsearchUsers(searchcontroller.text);
                          setState(() {
                            searchedusers = res;
                          });
                        } catch (e) {
                          displayErrorSnackBar("Could not search users");
                        }
                      },
                      child: SizedBox(
                        height: screenheight * 0.035,
                        width: screenwidth * 0.2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                width: 1,
                                color: searchevents
                                    ? Colors.black
                                    : Theme.of(context).primaryColor),
                          ),
                          child: const Center(child: Text("Users")),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          SizedBox(
            height: searching ? screenheight * 0.01 : screenheight * 0.005,
          ),
          searching
              ? UnAuthSearchBarListView(
                  searchevents: searchevents,
                  eventres: searchedevents,
                  userres: searchedusers,
                  query: searchcontroller.text,
                  curruserlocation: widget.curruserlocation,
                  analytics: widget.analytics,
                )
              : SearchGridView(
                  interests: interests,
                  onTap: searchnav,
                )
        ]),
      ),
    );
  }
}
