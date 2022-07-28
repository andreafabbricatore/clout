import 'package:clout/components/location.dart';
import 'package:clout/components/searchbarlistview.dart';
import 'package:clout/components/searchgridview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/interestsearchscreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';
import '../components/event.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key, required this.curruser, required this.userlocation});
  AppUser curruser;
  AppLocation userlocation;
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

  Future<void> updatecurruser() async {
    AppUser updateduser = await db.getUserFromDocID(widget.curruser.docid);
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

  void displayErrorSnackBar(String error) async {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    await Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

    Future<void> searchnav(String interest) async {
      try {
        List<Event> currloceventlist = await db.getLngLatEvents(
            widget.userlocation.center[0], widget.userlocation.center[1]);
        List<Event> interesteventlist = [];
        for (int i = 0; i < currloceventlist.length; i++) {
          if (interest == currloceventlist[i].interest) {
            setState(() {
              interesteventlist.add(currloceventlist[i]);
            });
          }
        }
        print(interesteventlist);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => InterestSearchScreen(
                    interest: interest,
                    events: interesteventlist,
                    curruser: widget.curruser,
                    userlocation: widget.userlocation)));
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
            child: TextField(
              controller: searchcontroller,
              onChanged: (String searchquery) async {
                if (searchevents) {
                  try {
                    List<Event> res = await db.searchEvents(searchquery);
                    setState(() {
                      searchedevents = res;
                    });
                    updatecurruser();
                  } catch (e) {
                    displayErrorSnackBar("Could not search events");
                  }
                } else {
                  try {
                    List<AppUser> res = await db.searchUsers(searchquery);
                    setState(() {
                      searchedusers = res;
                    });
                    updatecurruser();
                  } catch (e) {
                    displayErrorSnackBar("Could not search users");
                  }
                }
              },
              decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: InkWell(
                      onTap: () {
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
                      },
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
          SizedBox(
            height: screenheight * 0.01,
          ),
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
                          List<Event> res =
                              await db.searchEvents(searchcontroller.text);
                          setState(() {
                            searchedevents = res;
                          });
                          updatecurruser();
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
                                    ? const Color.fromARGB(255, 255, 48, 117)
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
                              await db.searchUsers(searchcontroller.text);
                          setState(() {
                            searchedusers = res;
                          });
                          updatecurruser();
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
                                    : const Color.fromARGB(255, 255, 48, 117)),
                          ),
                          child: const Center(child: Text("Users")),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
          searching
              ? SearchBarListView(
                  searchevents: searchevents,
                  eventres: searchedevents,
                  userres: searchedusers,
                  curruser: widget.curruser,
                  query: searchcontroller.text,
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
