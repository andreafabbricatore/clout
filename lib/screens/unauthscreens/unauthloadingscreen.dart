import 'dart:async';

import 'package:clout/components/location.dart';
import 'package:clout/screens/unauthscreens/unauthmainscreen.dart';
import 'package:clout/services/db.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

class UnAuthLoadingScreen extends StatefulWidget {
  FirebaseAnalytics analytics;
  UnAuthLoadingScreen({Key? key, required this.analytics}) : super(key: key);
  @override
  State<UnAuthLoadingScreen> createState() => _UnAuthLoadingScreenState();
}

class _UnAuthLoadingScreenState extends State<UnAuthLoadingScreen> {
  late bool _serviceEnabled;
  late LocationPermission permission;
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
      await getUserAppLocation();
      if (curruserlocation.address != "" &&
          curruserlocation.city != "" &&
          curruserlocation.country != "" &&
          !listEquals(curruserlocation.center, [0.0, 0.0])) {
        //
        String city =
            await getcitywithoutnums(curruserlocation.city.toLowerCase());
        //
        curruserlocation.city = city;

        stopwatch.stop();

        int diff = stopwatch.elapsed.inSeconds.ceil() > 2
            ? stopwatch.elapsed.inSeconds.ceil()
            : 2 - stopwatch.elapsed.inSeconds.ceil();
        Timer(Duration(seconds: diff), () => doneLoading());
      } else {
        stopwatch.stop();
        throw Exception();
      }
    } catch (e) {
      setState(() {
        error = true;
      });
    }
  }

  void doneLoading() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UnAuthMainScreen(
                curruserlocation: curruserlocation,
                justloaded: true,
                analytics: widget.analytics,
              ),
          fullscreenDialog: true),
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

  void loadinglogic() async {
    try {
      await ensurelocation();
      await appinit();
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
    if (error) {
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
