import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/searchgridview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/authscreens/interestsearchscreen.dart';
import 'package:clout/screens/authscreens/searchscreen.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapScreen extends StatefulWidget {
  MapScreen(
      {super.key,
      required this.curruserlocation,
      required this.analytics,
      required this.curruser});
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  AppUser curruser;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
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
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    Future<void> searchnav(String interest) async {
      try {
        List<Event> interesteventlist = [];
        interesteventlist = await db.getLngLatEventsByInterest(
            widget.curruserlocation.center[0],
            widget.curruserlocation.center[1],
            interest,
            widget.curruserlocation.country,
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
        body: SlidingUpPanel(
          minHeight: 40,
          maxHeight: screenheight * 0.6,
          defaultPanelState: PanelState.OPEN,
          backdropColor: Theme.of(context).primaryColor,
          parallaxEnabled: true,
          parallaxOffset: 0.2,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          panel: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(60, 0, 0, 0),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              SearchGridView(
                interests: interests,
                onTap: searchnav,
              ),
            ],
          ),
          body: Stack(
            children: [
              GoogleMap(
                //Map widget from google_maps_flutter package
                myLocationButtonEnabled: false,
                zoomGesturesEnabled: true, //enable Zoom in, out on map
                initialCameraPosition: CameraPosition(
                  //innital position in map
                  target: LatLng(widget.curruserlocation.center[1],
                      widget.curruserlocation.center[0]), //initial position
                  zoom: 12.0, //initial zoom level
                ),

                mapType: MapType.normal, //map type

                onMapCreated: (controller) {
                  //method called when map is created
                  setState(() {
                    mapController = controller;
                  });
                },
              ),
            ],
          ),
        ));
  }
}
