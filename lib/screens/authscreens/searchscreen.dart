import 'package:clout/components/location.dart';
import 'package:clout/components/searchbarlistview.dart';
import 'package:clout/components/searchgridview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/authscreens/calendarsearchscreen.dart';
import 'package:clout/screens/authscreens/interestsearchscreen.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:clout/components/event.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen(
      {super.key,
      required this.curruser,
      required this.curruserlocation,
      required this.analytics});
  AppUser curruser;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  db_conn db = db_conn();
  applogic logic = applogic();
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
    "Games",
    "Studying",
    "Chilling"
  ];

  Future<void> updatecurruser() async {
    AppUser updateduser = await db.getUserFromUID(widget.curruser.uid);
    setState(() {
      widget.curruser = updateduser;
    });
  }

  List<Event> searchedevents = [];
  List<AppUser> searchedusers = [];
  TextEditingController searchcontroller = TextEditingController();
  bool searching = false;
  bool searchevents = true;
  FocusNode focusNode = FocusNode();
  Color suffixiconcolor = Colors.white;

  void gotointerestsearchscreen(
      String interest, List<Event> interesteventlist) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => InterestSearchScreen(
                  interest: interest,
                  events: interesteventlist,
                  curruser: widget.curruser,
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
        interesteventlist = await db.getLngLatEventsByInterest(
            widget.curruserlocation.center[0],
            widget.curruserlocation.center[1],
            interest,
            widget.curruser);
        await widget.analytics
            .logEvent(name: "go_to_interest_search_screen", parameters: {
          "interest": interest,
          "inuserinterests":
              (widget.curruser.interests.contains(interest)).toString(),
          "userclout": widget.curruser.clout
        });
        gotointerestsearchscreen(interest, interesteventlist);
      } catch (e) {
        logic.displayErrorSnackBar("Could not display events", context);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                          List<Event> res = await db.searchEvents(
                              searchquery.trim(), widget.curruser);
                          setState(() {
                            searchedevents = res;
                          });
                          updatecurruser();
                        } catch (e) {
                          logic.displayErrorSnackBar(
                              "Could not search events", context);
                        }
                      } else {
                        try {
                          List<AppUser> res = await db.searchUsers(
                              searchquery.trim(), widget.curruser);
                          setState(() {
                            searchedusers = res;
                          });
                          updatecurruser();
                        } catch (e) {
                          logic.displayErrorSnackBar(
                              "Could not search users", context);
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
                          List<Event> res = await db.searchEvents(
                              searchcontroller.text, widget.curruser);
                          setState(() {
                            searchedevents = res;
                          });
                          updatecurruser();
                        } catch (e) {
                          logic.displayErrorSnackBar(
                              "Could not search events", context);
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
                          List<AppUser> res = await db.searchUsers(
                              searchcontroller.text, widget.curruser);
                          setState(() {
                            searchedusers = res;
                          });
                          updatecurruser();
                        } catch (e) {
                          logic.displayErrorSnackBar(
                              "Could not search users", context);
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
              ? SearchBarListView(
                  searchevents: searchevents,
                  eventres: searchedevents,
                  userres: searchedusers,
                  curruser: widget.curruser,
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
