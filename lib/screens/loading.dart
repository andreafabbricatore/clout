import 'dart:async';

import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/authscreen.dart';
import 'package:clout/screens/mainscreen.dart';
import 'package:clout/services/db.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key? key, required this.uid}) : super(key: key);
  final String uid;
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;
  bool error = false;
  AppLocation curruserlocation =
      AppLocation(address: "", city: "", country: "", center: [0.0, 0.0]);
  Dio _dio = Dio();
  db_conn db = db_conn();
  String docid = "";
  List interests = [];
  List<Event> currloceventlist = [];
  List<Event> eventlist = [];
  List<Event> interesteventlist = [];
  List allinterests = [
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
  Future<void> _getUserLocation() async {
    Location location = Location();

    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        throw Exception();
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw Exception();
      }
    }

    final _locationData = await location.getLocation();
    setState(() {
      _userLocation = _locationData;
    });
  }

  Future<void> getUserAppLocation() async {
    String searchquery =
        "${_userLocation?.longitude},${_userLocation?.latitude}";
    String accessToken = dotenv.get('MAPBOX_ACCESS_TOKEN');
    String url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$searchquery.json?limit=1&types=poi%2Caddress&access_token=$accessToken';
    url = Uri.parse(url).toString();
    //print(url);

    _dio.options.contentType = Headers.jsonContentType;
    final responseData = await _dio.get(url);
    List<AppLocation> response = (responseData.data['features'] as List)
        .map((e) => AppLocation.fromJson(e))
        .toList();
    setState(() {
      curruserlocation = response[0];
    });
  }

  void appinit() async {
    try {
      setState(() {
        error = false;
      });
      await _getUserLocation();
      await getUserAppLocation();
      if (curruserlocation.address != "" &&
          curruserlocation.city != "" &&
          curruserlocation.country != "" &&
          !listEquals(curruserlocation.center, [0.0, 0.0])) {
        docid = await db.getUserDocID(widget.uid);
        AppUser curruser = await db.getUserFromDocID(docid);
        interests = curruser.interests;
        currloceventlist = await db.getLngLatEvents(
            curruserlocation.center[0], curruserlocation.center[1]);
        for (int i = 0; i < currloceventlist.length; i++) {
          if (interests.contains(currloceventlist[i].interest)) {
            setState(() {
              interesteventlist.add(currloceventlist[i]);
            });
          } else {
            setState(() {
              eventlist.add(currloceventlist[i]);
            });
          }
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => MainScreen(
                  interests: interests,
                  eventlist: eventlist,
                  interesteventlist: interesteventlist,
                  curruser: curruser,
                  userlocation: curruserlocation),
              fullscreenDialog: true),
        );
      }
    } catch (e) {
      setState(() {
        error = true;
      });
    }
  }

  @override
  void initState() {
    appinit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: error
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Please make sure Location Services are enabled\nor\nCheck your internet connection",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: screenheight * 0.02,
                    ),
                    InkWell(
                      onTap: () {
                        appinit();
                      },
                      child: SizedBox(
                          height: 50,
                          width: screenwidth * 0.6,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 255, 48, 117),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: const Center(
                                child: Text(
                              "Refresh",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            )),
                          )),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Clout",
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 48, 117),
                        fontWeight: FontWeight.bold,
                        fontSize: 60),
                  ),
                  Text(
                    "Go Out",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 40),
                  ),
                  SizedBox(
                    height: screenheight * 0.1,
                  ),
                  SpinKitFadingFour(
                    color: Color.fromARGB(255, 255, 48, 117),
                  ),
                ],
              ),
      ),
    );
  }
}
