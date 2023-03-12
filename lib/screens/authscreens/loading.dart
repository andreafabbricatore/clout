import 'dart:async';
import 'dart:io';

import 'package:clout/components/location.dart';
import 'package:clout/components/user.dart';
import 'package:clout/main.dart';
import 'package:clout/screens/authscreens/mainscreen.dart';
import 'package:clout/services/db.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:launch_review/launch_review.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key? key, required this.uid, required this.analytics})
      : super(key: key);
  final String uid;
  FirebaseAnalytics analytics;
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late bool _serviceEnabled;
  late LocationPermission permission;
  bool maintenance = false;
  bool update = false;
  Position? _userLocation;
  bool error = false;
  AppLocation curruserlocation =
      AppLocation(address: "", city: "", country: "", center: [0.0, 0.0]);
  Dio _dio = Dio();
  db_conn db = db_conn();
  Future<bool> _getUserLocation() async {
    // Check if location service is enable
    try {
      _serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_serviceEnabled) {
        throw Exception();
      }

      // Check if permission is granted
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception();
      }

      final _locationData = await Geolocator.getCurrentPosition();

      _userLocation = _locationData;
      return true;
    } catch (e) {
      return false;
    }
  }

  //change to google maps
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

  Future<void> newgetUserAppLocation() async {
    //broken
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${_userLocation?.latitude},${_userLocation?.longitude}&key=AIzaSyAR9bmRxpCYai5b2k6AKtc4f7Es9w1307w';
    url = Uri.parse(url).toString();
    _dio.options.contentType = Headers.jsonContentType;
    final responseData = await _dio.get(url);
    String address =
        responseData.data['results'][0]['address_components'][1]['short_name'];
    String city =
        responseData.data['results'][0]['address_components'][2]['short_name'];
    String country =
        responseData.data['results'][0]['address_components'][6]['long_name'];
    curruserlocation = AppLocation(
        address: address,
        city: city,
        country: country,
        center: [_userLocation?.longitude, _userLocation?.latitude]);
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
      Stopwatch stopwatch = Stopwatch()..start();
      //await newgetUserAppLocation();
      await widget.analytics.setUserId(id: widget.uid);
      await getUserAppLocation();
      await db.updatelastuserloc(
          widget.uid, curruserlocation.center[1], curruserlocation.center[0]);
      if (curruserlocation.address != "" &&
          curruserlocation.city != "" &&
          curruserlocation.country != "" &&
          !listEquals(curruserlocation.center, [0.0, 0.0])) {
        AppUser curruser = await db.getUserFromUID(widget.uid);

        //
        String city =
            await getcitywithoutnums(curruserlocation.city.toLowerCase());
        //
        curruserlocation.city = city;

        stopwatch.stop();

        int diff = stopwatch.elapsed.inSeconds.ceil() > 2
            ? stopwatch.elapsed.inSeconds.ceil()
            : 2 - stopwatch.elapsed.inSeconds.ceil();
        Timer(Duration(seconds: diff), () => doneLoading(curruser));
      } else {
        stopwatch.stop();
        throw Exception();
      }
    } catch (e) {
      setState(() {
        error = true;
      });
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
            curruser: curruser,
            curruserlocation: curruserlocation,
            justloaded: true,
            analytics: widget.analytics),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> ensurelocation() async {
    setState(() {
      error = false;
    });
    bool gotuserlocation = await _getUserLocation();
    if (!gotuserlocation) {
      throw Exception();
    }
  }

  Future<void> undermaintenance() async {
    try {
      bool maint = await db.undermaintenance();
      setState(() {
        maintenance = maint;
      });
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> needupdate() async {
    try {
      bool upd = await db.checkversionandneedupdate(widget.uid);
      setState(() {
        update = upd;
      });
    } catch (e) {
      throw Exception();
    }
  }

  void loadinglogic() async {
    try {
      await ensurelocation();
      await undermaintenance();
      if (!maintenance) {
        await needupdate();
        if (!update) {
          await appinit();
        }
      }
    } catch (e) {
      setState(() {
        error = true;
      });
    }
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
    if (maintenance) {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Server under maintenance\n\nWe'll be back soon!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textScaleFactor: 1.2,
                ),
                SizedBox(
                  height: screenheight * 0.02,
                ),
                InkWell(
                  onTap: () {
                    loadinglogic();
                  },
                  child: SizedBox(
                      height: 50,
                      width: screenwidth * 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        child: const Center(
                            child: Text(
                          "Refresh",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                          textScaleFactor: 1.2,
                        )),
                      )),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (update) {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                    "Update available!\n\nUpdate Clout to keep Going Out!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textScaleFactor: 1.2),
                SizedBox(
                  height: screenheight * 0.02,
                ),
                InkWell(
                  onTap: () {
                    LaunchReview.launch(
                        iOSAppId: "1642153685",
                        androidAppId: "com.outwithclout.clout",
                        writeReview: false);
                  },
                  child: SizedBox(
                      height: 50,
                      width: screenwidth * 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        child: const Center(
                            child: Text(
                          "Update",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                          textScaleFactor: 1.2,
                        )),
                      )),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (error) {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                    "Please make sure Location Services are enabled\nor\nCheck your internet connection",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textScaleFactor: 1.2),
                SizedBox(
                  height: screenheight * 0.02,
                ),
                InkWell(
                  onTap: () {
                    loadinglogic();
                  },
                  child: SizedBox(
                      height: 50,
                      width: screenwidth * 0.6,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        child: const Center(
                            child: Text(
                          "Refresh",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                          textScaleFactor: 1.2,
                        )),
                      )),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child:
              Center(child: Image.asset("assets/images/logos/cloutlogo.gif")),
        ),
      );
    }
  }
}
