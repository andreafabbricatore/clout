import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:clout/components/searchlocation.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/loading.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EditEventScreen extends StatefulWidget {
  EditEventScreen(
      {super.key,
      required this.curruser,
      required this.allowbackarrow,
      required this.event,
      required this.analytics});
  AppUser curruser;
  bool allowbackarrow;
  FirebaseAnalytics analytics;

  Event event;

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
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
    "Games"
  ];

  db_conn db = db_conn();
  late String selectedinterest;
  ImagePicker picker = ImagePicker();
  var imagepath;
  var compressedimgpath;
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController desccontroller = TextEditingController();
  TextEditingController maxpartcontroller = TextEditingController();
  DateTime eventdate = DateTime(0, 0, 0, 0);
  AppLocation chosenLocation =
      AppLocation(address: "", city: "", country: "", center: [0, 0]);
  bool emptylocation = false;
  bool buttonpressed = false;
  bool isinviteonly = false;
  GoogleMapController? mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  List LatLngs = [];

  void setup() {
    setState(() {
      selectedinterest = widget.event.interest;
      titlecontroller.text = widget.event.title;
      desccontroller.text = widget.event.description;
      maxpartcontroller.text = widget.event.maxparticipants.toString();
      eventdate = widget.event.datetime;
      chosenLocation = AppLocation(
          address: widget.event.address,
          city: widget.event.city.join(" "),
          country: widget.event.country,
          center: [widget.event.lat, widget.event.lng]);
      isinviteonly = widget.event.isinviteonly;
    });
    _addMarker(LatLng(chosenLocation.center[0], chosenLocation.center[1]));
  }

  Future _addMarker(LatLng latlang) async {
    setState(() {
      const MarkerId markerId = MarkerId("chosenlocation");
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
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(latlang, 17.0));
  }

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

      return result!;
    } catch (e) {
      throw Exception();
    }
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

  void checklocationempty() {
    if (chosenLocation.address == "" &&
        chosenLocation.city == "" &&
        chosenLocation.country == "" &&
        listEquals(chosenLocation.center, [0.0, 0.0])) {
      setState(() {
        emptylocation = true;
      });
    } else {
      setState(() {
        emptylocation = false;
      });
    }
  }

  void goloadingscreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => LoadingScreen(
                uid: widget.curruser.uid,
                analytics: widget.analytics,
              ),
          settings: RouteSettings(name: "LoadingScreen")),
    );
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  @override
  void dispose() {
    titlecontroller.dispose();
    desccontroller.dispose();
    maxpartcontroller.dispose();
    eventdate = DateTime(0, 0, 0);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: widget.allowbackarrow
            ? GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColor,
                ),
              )
            : Container(),
        title: Text(
          "Edit Event",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: screenheight * 0.02,
          ),
          InkWell(
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
                displayErrorSnackBar("Error with profile picture");
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: imagepath == null
                  ? Image.network(
                      widget.event.image,
                      height: screenheight * 0.2,
                      width: screenheight * 0.2,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      imagepath,
                      height: screenheight * 0.2,
                      width: screenheight * 0.2,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(
            height: screenheight * 0.01,
          ),
          const Text(
            "Event Cover is Optional",
            style: TextStyle(color: Color.fromARGB(53, 0, 0, 0)),
            textScaleFactor: 1.0,
          ),
          SizedBox(
            height: screenheight * 0.01,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenwidth * 0.2),
            child: TextField(
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor)),
                hintText: "Event Name",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(39, 0, 0, 0),
                  fontSize: 30,
                ),
              ),
              textAlign: TextAlign.center,
              enableSuggestions: false,
              autocorrect: false,
              controller: titlecontroller,
            ),
          ),
          SizedBox(height: screenheight * 0.02),
          SizedBox(
            width: screenwidth * 0.6,
            child: DropdownButtonFormField(
              borderRadius: BorderRadius.circular(20),
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              )),
              value: selectedinterest,
              onChanged: (String? newValue) {
                setState(() {
                  selectedinterest = newValue!;
                });
              },
              onSaved: (String? newValue) {
                setState(() {
                  selectedinterest = newValue!;
                });
              },
              items: allinterests.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(
                    items,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w300),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: screenheight * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenwidth * 0.2),
            child: TextField(
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor)),
                hintText: "Description",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(39, 0, 0, 0),
                  fontSize: 15,
                ),
              ),
              textAlign: TextAlign.start,
              enableSuggestions: true,
              autocorrect: true,
              controller: desccontroller,
              keyboardType: TextInputType.text,
              minLines: 1,
              maxLines: 5,
            ),
          ),
          SizedBox(height: screenheight * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenwidth * 0.2),
            child: TextFormField(
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor)),
                hintText: "Max. Number of Participants",
                hintStyle: const TextStyle(
                  color: Color.fromARGB(39, 0, 0, 0),
                  fontSize: 15,
                ),
              ),
              textAlign: TextAlign.start,
              enableSuggestions: true,
              autocorrect: true,
              controller: maxpartcontroller,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          SizedBox(height: screenheight * 0.02),
          InkWell(
            onTap: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (_) => Container(
                        height: screenheight * 0.4,
                        color: Colors.white,
                        child: Column(
                          children: [
                            SizedBox(
                              height: screenheight * 0.4,
                              child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.dateAndTime,
                                  minimumDate: DateTime.now(),
                                  initialDateTime: eventdate,
                                  onDateTimeChanged: (val) {
                                    setState(() {
                                      eventdate = val;
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ));
            },
            child: Container(
              height: screenwidth * 0.13,
              width: screenwidth * 0.6,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(20)),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  eventdate == DateTime(0, 0, 0)
                      ? "Date and Time"
                      : "${DateFormat.MMMd().format(eventdate)} @ ${DateFormat('hh:mm a').format(eventdate)}",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                  textScaleFactor: 1.0,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Icon(
                  Icons.date_range,
                  size: 15,
                )
              ]),
            ),
          ),
          SizedBox(height: screenheight * 0.02),
          InkWell(
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
                                address: widget.event.address,
                                city: widget.event.city[0],
                                country: widget.event.country,
                                center: [widget.event.lat, widget.event.lng]),
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
              checklocationempty();
            },
            child: Container(
              height: screenwidth * 0.13,
              width: screenwidth * 0.6,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(20)),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  emptylocation ? "Location" : "Change Location",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                  textScaleFactor: 1.0,
                ),
                const SizedBox(
                  width: 5,
                ),
                const Icon(
                  Icons.map_rounded,
                  size: 15,
                )
              ]),
            ),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          emptylocation
              ? const SizedBox()
              : SizedBox(
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
                      zoom: 17.0, //initial zoom level
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
            height: screenheight * 0.03,
          ),
          Container(
            height: screenwidth * 0.13,
            width: screenwidth * 0.6,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(21)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isinviteonly = false;
                  });
                },
                child: Container(
                  width:
                      isinviteonly ? screenwidth * 0.24 : screenwidth * 0.354,
                  decoration: BoxDecoration(
                      color: isinviteonly
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      border: Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Text(
                      "Public",
                      style: TextStyle(
                          fontSize: isinviteonly ? 16 : 20,
                          color: isinviteonly ? Colors.black : Colors.white),
                      textScaleFactor: 1.0,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isinviteonly = true;
                  });
                },
                child: Container(
                  width:
                      isinviteonly ? screenwidth * 0.354 : screenwidth * 0.24,
                  decoration: BoxDecoration(
                      color: isinviteonly
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      border: Border.all(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Text(
                      "Invite-Only",
                      style: TextStyle(
                          fontSize: isinviteonly ? 18 : 14,
                          color: isinviteonly ? Colors.white : Colors.black),
                      textScaleFactor: 1.0,
                    ),
                  ),
                ),
              )
            ]),
          ),
          SizedBox(
            height: screenheight * 0.01,
          ),
          Text(
            isinviteonly
                ? "Can only join through shared link"
                : "Anyone can join the event",
            style: const TextStyle(color: Color.fromARGB(53, 0, 0, 0)),
            textScaleFactor: 1.0,
          ),
          SizedBox(
            height: screenheight * 0.03,
          ),
          GestureDetector(
              onTap: buttonpressed
                  ? null
                  : () async {
                      setState(() {
                        buttonpressed = true;
                      });
                      if (titlecontroller.text.trim().isEmpty) {
                        displayErrorSnackBar(
                            "Please enter a name for your event");
                      } else if (desccontroller.text.trim().isEmpty) {
                        displayErrorSnackBar("Please enter a description");
                      } else if (int.parse(maxpartcontroller.text) <= 1) {
                        displayErrorSnackBar(
                            "Please enter a valid max number of participants");
                      } else if (eventdate
                          .isAtSameMomentAs(DateTime(0, 0, 0))) {
                        displayErrorSnackBar(
                            "Please choose a date for your event");
                      } else if (emptylocation) {
                        displayErrorSnackBar(
                            "Please choose a location for your event");
                      } else {
                        setState(() {
                          widget.event.title = titlecontroller.text.trim();
                          widget.event.description = desccontroller.text.trim();
                          widget.event.maxparticipants =
                              int.parse(maxpartcontroller.text);
                          widget.event.interest = selectedinterest;
                          widget.event.datetime = eventdate;
                          widget.event.country =
                              chosenLocation.country.toLowerCase();
                          widget.event.address = chosenLocation.address;
                          widget.event.city =
                              chosenLocation.city.toLowerCase().split(" ");
                          widget.event.lat = chosenLocation.center[0];
                          widget.event.lng = chosenLocation.center[1];
                          widget.event.isinviteonly = isinviteonly;
                        });
                        try {
                          if (imagepath == null) {
                            compressedimgpath = null;
                          } else {
                            compressedimgpath =
                                await CompressAndGetFile(imagepath);
                          }
                          await db.updateEvent(widget.event, compressedimgpath);
                          goloadingscreen();
                        } catch (e) {
                          displayErrorSnackBar("Could not update event");
                          setState(() {
                            buttonpressed = false;
                          });
                        }
                      }
                      setState(() {
                        buttonpressed = false;
                      });
                    },
              child: PrimaryButton(
                screenwidth: screenwidth,
                buttonpressed: buttonpressed,
                text: "Update Event",
                buttonwidth: screenwidth * 0.6,
                bold: false,
              )),
          SizedBox(
            height: screenheight * 0.04,
          ),
        ]),
      ),
    );
  }
}
