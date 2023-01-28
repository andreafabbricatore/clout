import 'dart:async';

import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/mainscreen.dart';
import 'package:clout/services/db.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Location location = Location();
  Future<bool> _getUserLocation() async {
    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    final _locationData = await location.getLocation();

    _userLocation = _locationData;

    return true;
  }

  Future<void> getUserAppLocation() async {
    String searchquery =
        "${_userLocation?.longitude},${_userLocation?.latitude}";
    String accessToken = dotenv.get('MAPBOX_ACCESS_TOKEN');
    String url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$searchquery.json?limit=1&types=poi%2Caddress&access_token=$accessToken';
    url = Uri.parse(url).toString();

    _dio.options.contentType = Headers.jsonContentType;
    final responseData = await _dio.get(url);
    List<AppLocation> response = (responseData.data['features'] as List)
        .map((e) => AppLocation.fromJson(e))
        .toList();

    curruserlocation = response[0];
  }

  Future<String> getcitywithoutnums(String city) async {
    List splittext = city.split(" ");
    List res = [];
    for (int i = 0; i < splittext.length; i++) {
      try {
        int.parse(splittext[i]);
      } catch (e) {
        res.add(splittext[i]);
      }
    }
    String newcity = res.join(" ");
    return newcity;
  }

  Future<void> appinit() async {
    try {
      setState(() {
        error = false;
      });
      await getUserAppLocation();
      await db.updatelastuserloc(
          widget.uid, curruserlocation.center[1], curruserlocation.center[0]);
      if (curruserlocation.address != "" &&
          curruserlocation.city != "" &&
          curruserlocation.country != "" &&
          !listEquals(curruserlocation.center, [0.0, 0.0])) {
        AppUser curruser = await db.getUserFromUID(widget.uid);
        interests = curruser.interests;
        String city =
            await getcitywithoutnums(curruserlocation.city.toLowerCase());

        curruserlocation.city = city;

        currloceventlist = await db.getLngLatEvents(curruserlocation.center[0],
            curruserlocation.center[1], curruserlocation.country, curruser);
        for (int i = 0; i < currloceventlist.length; i++) {
          if (interests.contains(currloceventlist[i].interest)) {
            if (curruser.following.contains(currloceventlist[i].hostdocid)) {
              interesteventlist.insert(0, currloceventlist[i]);
            } else {
              interesteventlist.add(currloceventlist[i]);
            }
          } else {
            if (curruser.following.contains(currloceventlist[i].hostdocid)) {
              interesteventlist.insert(0, currloceventlist[i]);
            } else {
              eventlist.add(currloceventlist[i]);
            }
          }
        }
        doneLoading(curruser);
      } else {
        throw Exception();
      }
    } catch (e) {
      setState(() {
        error = true;
      });
      print(e);
      if (e.toString() == "Exception: Error with userdocid" ||
          e.toString() == "Exception: Could not retrieve user") {
        FirebaseAuth.instance.signOut();
      }
    }
  }

  void doneLoading(AppUser curruser) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => MainScreen(
              eventlist: eventlist,
              interesteventlist: interesteventlist,
              curruser: curruser,
              userlocation: curruserlocation),
          fullscreenDialog: true),
    );
  }

  Future<void> ensurelocation() async {
    try {
      setState(() {
        error = false;
      });
      bool gotpermissions = false;
      int counter = 0;
      while (gotpermissions == false) {
        gotpermissions = await _getUserLocation();
        counter += 1;
        if (counter >= 3) {
          throw Exception();
        }
      }
    } catch (e) {
      setState(() {
        error = true;
      });
    }
  }

  void loadinglogic() async {
    await ensurelocation();
    await appinit();
  }

  @override
  void initState() {
    loadinglogic();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Clout",
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 48, 117),
                          fontFamily: "Kristi",
                          fontWeight: FontWeight.w500,
                          fontSize: 80),
                      textScaleFactor: 1.0,
                    ),
                    const Text(
                      "Go Out",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    ),
                    SizedBox(
                      height: screenheight * 0.1,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
