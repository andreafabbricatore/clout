import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clout/components/datatextfield.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:clout/defs/location.dart';
import 'package:clout/models/searchlocation.dart';
import 'package:clout/models/updateinterests.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:image_picker/image_picker.dart';

class BusinessEditProfileScreen extends StatefulWidget {
  BusinessEditProfileScreen(
      {super.key, required this.curruser, required this.analytics});
  AppUser curruser;
  FirebaseAnalytics analytics;
  @override
  State<BusinessEditProfileScreen> createState() =>
      _BusinessEditProfileScreenState();
}

class _BusinessEditProfileScreenState extends State<BusinessEditProfileScreen> {
  db_conn db = db_conn();
  applogic logic = applogic();
  ImagePicker picker = ImagePicker();
  var imagepath;
  var compressedimgpath;
  TextEditingController fullnamecontroller = TextEditingController();
  TextEditingController usernamecontroller = TextEditingController();
  bool buttonpressed = false;
  List LatLngs = [];
  AppLocation chosenLocation =
      AppLocation(address: "", city: "", country: "", center: [0.0, 0.0]);
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  GoogleMapController? mapController;
  List<String> allinterests = [
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
  String? interest;

  Future _addMarker(LatLng latlang) async {
    setState(() {
      final MarkerId markerId = MarkerId("chosenlocation");
      Marker marker = Marker(
        markerId: markerId,
        draggable: true,
        position:
            latlang, //With this parameter you automatically obtain latitude and longitude
        infoWindow: const InfoWindow(
          title: "Chosen Location",
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      markers[markerId] = marker;
    });

    //This is optional, it will zoom when the marker has been created
  }

  bool error = false;

  Future<File> CompressAndGetFile(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(".");
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
      var result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 5,
      );

      //print(file.lengthSync());
      //print(result!.lengthSync());

      return File(result!.path);
    } catch (e) {
      throw Exception();
    }
  }

  @override
  void initState() {
    setState(() {
      fullnamecontroller.text = widget.curruser.fullname;
      usernamecontroller.text = widget.curruser.username;
      interest = widget.curruser.interests[0];
      chosenLocation = AppLocation(
          address: widget.curruser.bio,
          city: "",
          country: "",
          center: [widget.curruser.lastknownlat, widget.curruser.lastknownlng]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Center(
            child: GestureDetector(
              onTap: () async {
                try {
                  XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      imagepath = File(image.path);
                    });
                    //print(imagepath);
                  }
                } catch (e) {
                  logic.displayErrorSnackBar(
                      "Error with profile picture", context);
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: imagepath == null
                    ? CachedNetworkImage(
                        imageUrl: widget.curruser.pfpurl,
                        height: screenheight * 0.2,
                        width: screenheight * 0.2,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 10),
                      )
                    : Image.file(
                        imagepath,
                        height: screenheight * 0.2,
                        width: screenheight * 0.2,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          const Text(
            "Change Profile Picture",
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          textdatafield(screenwidth, "fullname", fullnamecontroller),
          SizedBox(
            height: screenheight * 0.02,
          ),
          textdatafield(screenwidth, "username", usernamecontroller),
          SizedBox(
            height: screenheight * 0.02,
          ),
          SizedBox(
            width: screenwidth * 0.6,
            child: DropdownButtonFormField(
              borderRadius: BorderRadius.circular(20),
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor))),
              value: interest,
              onChanged: (String? newValue) {
                setState(() {
                  interest = newValue!;
                });
              },
              onSaved: (String? newValue) {
                setState(() {
                  interest = newValue!;
                });
              },
              items: allinterests.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(items),
                );
              }).toList(),
              isExpanded: true,
            ),
          ),
          SizedBox(
            height: screenheight * 0.05,
          ),
          GestureDetector(
            onTap: () async {
              Position _locationData = await Geolocator.getCurrentPosition();
              setState(() {
                LatLngs = [_locationData.latitude, _locationData.longitude];
              });
              AppLocation chosen = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchLocation(
                            locationchosen: true,
                            startlocation: AppLocation(
                              address: chosenLocation.address,
                              center: chosenLocation.center,
                              city: chosenLocation.city,
                              country: chosenLocation.country,
                            ),
                            curruserLatLng: LatLngs,
                          ),
                      settings: RouteSettings(name: "SearchLocation")));
              setState(() {
                chosenLocation = chosen;
              });
              _addMarker(
                  LatLng(chosenLocation.center[0], chosenLocation.center[1]));
              mapController?.moveCamera(CameraUpdate.newLatLngZoom(
                  LatLng(chosenLocation.center[0], chosenLocation.center[1]),
                  17.0));
            },
            child: Container(
              height: screenwidth * 0.13,
              width: screenwidth * 0.6,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(20)),
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Change Location",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      textScaler: TextScaler.linear(1.0),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.map_rounded,
                      size: 15,
                    )
                  ]),
            ),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          SizedBox(
            height: screenheight * 0.2,
            width: screenwidth * 0.6,
            child: GoogleMap(
              //Map widget from google_maps_flutter package
              myLocationButtonEnabled: false,
              zoomGesturesEnabled: true, //enable Zoom in, out on map
              initialCameraPosition: CameraPosition(
                //innital position in map
                target: LatLng(chosenLocation.center[0],
                    chosenLocation.center[1]), //initial position
                zoom: 14.0, //initial zoom level
              ),
              mapType: MapType.normal, //map type
              markers: Set<Marker>.of(markers.values),
              onMapCreated: (controller) {
                //method called when map is created
                setState(() {
                  mapController = controller;
                });
              },
            ),
          ),
          SizedBox(
            height: screenheight * 0.05,
          ),
          GestureDetector(
              onTap: buttonpressed
                  ? null
                  : () async {
                      setState(() {
                        buttonpressed = true;
                        error = false;
                      });
                      try {
                        if (imagepath != null) {
                          compressedimgpath =
                              await CompressAndGetFile(imagepath);
                          await db.changepfp(
                              compressedimgpath, widget.curruser.uid);
                        }
                        bool unique = await db
                            .usernameUnique(usernamecontroller.text.trim());
                        if (unique &&
                            usernamecontroller.text.isNotEmpty &&
                            RegExp(r'^[a-zA-Z0-9&%=]+$')
                                .hasMatch(usernamecontroller.text.trim())) {
                          await db.changeusername(
                              usernamecontroller.text.trim(),
                              widget.curruser.uid);
                        } else {
                          if (usernamecontroller.text.trim() !=
                              widget.curruser.username) {
                            logic.displayErrorSnackBar(
                                "Invalid Username", context);
                            setState(() {
                              error = true;
                            });
                          }
                        }
                        if (fullnamecontroller.text.isNotEmpty) {
                          await db.changeattribute(
                              'fullname',
                              fullnamecontroller.text.trim(),
                              widget.curruser.uid);
                        } else {
                          logic.displayErrorSnackBar(
                              "Please do not leave fields empty", context);
                          setState(() {
                            error = true;
                          });
                        }
                        await db.changeinterests(
                            'interests', [interest], widget.curruser.uid);
                        await db.businesssetloc(
                            widget.curruser.uid, chosenLocation);
                      } catch (e) {
                        logic.displayErrorSnackBar(
                            "Could not update profile", context);
                        setState(() {
                          error = true;
                        });
                      } finally {
                        setState(() {
                          buttonpressed = false;
                        });
                        if (!error) {
                          logic.displayErrorSnackBar(
                              "Updated Profile!", context);
                          Navigator.pop(context);
                        }
                      }
                    },
              child: PrimaryButton(
                screenwidth: screenwidth,
                buttonpressed: buttonpressed,
                text: "Update Profile",
                buttonwidth: screenwidth * 0.6,
                bold: false,
              )),
          SizedBox(
            height: screenheight * 0.05,
          )
        ]),
      ),
    );
  }
}
