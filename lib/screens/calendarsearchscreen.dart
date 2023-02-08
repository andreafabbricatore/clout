import 'package:clout/components/event.dart';
import 'package:clout/components/eventlistview.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/createeventscreen.dart';
import 'package:clout/screens/eventdetailscreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CalendarSearchScreen extends StatefulWidget {
  AppLocation userlocation;
  AppUser curruser;
  CalendarSearchScreen(
      {Key? key, required this.userlocation, required this.curruser})
      : super(key: key);

  @override
  State<CalendarSearchScreen> createState() => _CalendarSearchScreenState();
}

class _CalendarSearchScreenState extends State<CalendarSearchScreen> {
  DateTime selectedDate = DateTime.now();
  db_conn db = db_conn();
  List<Event> filteredEventList = [];
  bool displaycalendar = true;
  DateTime initialDate = DateTime.now();

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      selectedDate = args.value;
    });
    getEventList();
    setState(() {
      displaycalendar = false;
    });
  }

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

  Future<void> updatecurruser() async {
    try {
      AppUser updateduser = await db.getUserFromUID(widget.curruser.uid);
      setState(() {
        widget.curruser = updateduser;
      });
    } catch (e) {
      displayErrorSnackBar("Could not refresh user");
    }
  }

  Future interactfav(Event event) async {
    try {
      if (widget.curruser.favorites.contains(event.docid)) {
        await db.remFromFav(widget.curruser.uid, event.docid);
      } else {
        await db.addToFav(widget.curruser.uid, event.docid);
      }
    } catch (e) {
      displayErrorSnackBar("Could not update favorites");
    } finally {
      updatecurruser();
    }
  }

  Future<void> getEventList() async {
    List<Event> res = [];
    filteredEventList = [];
    res = await db.getLngLatEventsFilteredByDate(
        widget.userlocation.center[0],
        widget.userlocation.center[1],
        selectedDate,
        widget.userlocation.country,
        widget.curruser);
    for (int i = 0; i < res.length; i++) {
      if (widget.curruser.following.contains(res[i].hostdocid)) {
        filteredEventList.insert(0, res[i]);
      } else {
        filteredEventList.add(res[i]);
      }
    }
    setState(() {});
  }

  Future<void> refresh() async {
    try {
      await getEventList();
      await updatecurruser();
    } catch (e) {
      displayErrorSnackBar("Could not refresh");
    }
  }

  @override
  void initState() {
    super.initState();
    updatecurruser();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    Future<void> navigate(Event event, int index) async {
      try {
        Event chosenEvent = await db.getEventfromDocId(event.docid);
        List<AppUser> participants = [
          for (String x in chosenEvent.participants) await db.getUserFromUID(x)
        ];

        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => EventDetailScreen(
                      event: chosenEvent,
                      curruser: widget.curruser,
                      participants: participants,
                      interactfav: interactfav,
                    )));
      } catch (e) {
        displayErrorSnackBar("Could not display event");
      }
      refresh();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Filter by Date",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          displaycalendar
              ? SfDateRangePicker(
                  onSelectionChanged: _onSelectionChanged,
                  enablePastDates: false,
                  initialSelectedDate: initialDate,
                  initialDisplayDate: initialDate,
                  minDate: DateTime.now(),
                  selectionColor: Theme.of(context).primaryColor,
                  todayHighlightColor: Colors.grey,
                  selectionTextStyle: const TextStyle(color: Colors.white),
                )
              : Row(
                  children: [
                    Text(
                      DateFormat.yMMMMd().format(selectedDate).toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                      textScaleFactor: 1.0,
                    ),
                    SizedBox(
                      width: screenwidth * 0.01,
                    ),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            displaycalendar = true;
                            filteredEventList = [];
                            initialDate = selectedDate;
                          });
                        },
                        child: const Icon(Icons.edit))
                  ],
                ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          displaycalendar
              ? Container()
              : filteredEventList.isNotEmpty
                  ? EventListView(
                      onTap: navigate,
                      isHorizontal: false,
                      eventList: filteredEventList,
                      scrollable: true,
                      leftpadding: false,
                      curruser: widget.curruser,
                      interactfav: interactfav,
                      screenwidth: screenwidth,
                      screenheight: screenheight)
                  : Column(
                      children: [
                        SizedBox(
                          height: screenheight * 0.1,
                        ),
                        const Text(
                          "No Events yet :(",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                          textScaleFactor: 1.0,
                        ),
                        SizedBox(
                          height: screenheight * 0.03,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    CreateEventScreen(
                                  curruser: widget.curruser,
                                  allowbackarrow: true,
                                  startinterest: "Sports",
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: screenwidth * 0.13,
                            width: screenwidth * 0.6,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black)),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Create Event",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    )
        ]),
      ),
    );
  }
}
