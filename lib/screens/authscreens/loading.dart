import 'dart:async';

import 'package:clout/defs/location.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/screens/authentication/signupflowscreens.dart';
import 'package:clout/screens/authscreens/linkphoneauth.dart';
import 'package:clout/screens/authscreens/mainscreen.dart';
import 'package:clout/services/db.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

  Future<void> finishloading(AppUser curruser) async {
    try {
      if (curruser.setnameandpfp == false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => PicandNameScreen(
                    analytics: widget.analytics,
                    business: curruser.plan == "business",
                  ),
              settings: const RouteSettings(name: "PicandNameScreen"),
              fullscreenDialog: true),
        );
      } else if (curruser.setusername == false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => UsernameScreen(
                    analytics: widget.analytics,
                    business: curruser.plan == "business",
                  ),
              settings: const RouteSettings(name: "UsernameScreen"),
              fullscreenDialog: true),
        );
      } else if (curruser.setmisc == false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => MiscScreen(
                    analytics: widget.analytics,
                  ),
              settings: const RouteSettings(name: "MiscScreen"),
              fullscreenDialog: true),
        );
      } else if (curruser.plan != "business" &&
          curruser.setinterests == false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => InterestScreen(
                    analytics: widget.analytics,
                  ),
              settings: const RouteSettings(name: "InterestScreen"),
              fullscreenDialog: true),
        );
      } else {
        await newgetUserAppLocation();
        await db.updatelastuserlocandusage(widget.uid,
            curruserlocation.center[1], curruserlocation.center[0], curruser);
        doneLoading(curruser);
      }
    } catch (e) {
      throw Exception();
    }
  }

  Future<void> newgetUserAppLocation() async {
    //broken
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${_userLocation?.latitude},${_userLocation?.longitude}&result_type=country&key=AIzaSyAR9bmRxpCYai5b2k6AKtc4f7Es9w1307w';
    url = Uri.parse(url).toString();

    _dio.options.contentType = Headers.jsonContentType;
    final responseData = await _dio.get(url);
    String country = responseData.data['results'][0]['address_components'][0]
            ['long_name']
        .toString()
        .toLowerCase();
    curruserlocation = AppLocation(
        address: "",
        city: "",
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
      await widget.analytics.setUserId(id: widget.uid);
      AppUser curruser = await db.getUserFromUID(widget.uid);
      print("got user");
      if (curruser.plan != "business") {
        await linkauth(curruser);
      } else {
        await finishloading(curruser);
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

  Future<void> linkauth(AppUser curruser) async {
    List<UserInfo>? providersdata =
        FirebaseAuth.instance.currentUser?.providerData;
    List providers = [];
    for (int i = 0; i < providersdata!.length; i++) {
      providers.add(providersdata[i].providerId);
    }
    if (!providers.contains('phone')) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LinkPhoneInputScreen(
            analytics: widget.analytics,
            updatephonenumber: false,
          ),
          fullscreenDialog: true,
        ),
      );
    } else {
      await finishloading(curruser);
    }
  }

  void loadinglogic() async {
    try {
      await ensurelocation();
      print("done");
      await undermaintenance();
      print("done");
      if (!maintenance) {
        await needupdate();
        print("done");
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
