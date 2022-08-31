import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/searchlocation.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/loading.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class CreateEventScreen extends StatefulWidget {
  CreateEventScreen(
      {super.key,
      required this.curruser,
      required this.allowbackarrow,
      required this.startinterest});
  AppUser curruser;
  bool allowbackarrow;
  String startinterest;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  Event event = Event(
      title: "",
      description: "",
      interest: "",
      image: "",
      address: "",
      city: "",
      host: "",
      maxparticipants: 0,
      participants: [],
      datetime: DateTime(0, 0, 0),
      docid: "",
      lat: 0,
      lng: 0);

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
    "Art"
  ];

  db_conn db = db_conn();
  late String selectedinterest;
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController desccontroller = TextEditingController();
  TextEditingController maxpartcontroller = TextEditingController();
  DateTime eventdate = DateTime(0, 0, 0);
  AppLocation chosenLocation =
      AppLocation(address: "", city: "", country: "", center: [0.0, 0.0]);
  bool emptylocation = true;

  void displayErrorSnackBar(String error) async {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    await Future.delayed(const Duration(milliseconds: 400));
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

  @override
  void initState() {
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
    selectedinterest = widget.startinterest;
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
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Color.fromARGB(255, 255, 48, 117),
                ),
              )
            : Container(),
        title: const Text(
          "Create Event",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: screenheight * 0.05,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenwidth * 0.2),
            child: TextField(
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 48, 117),
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 255, 48, 117))),
                hintText: "Event Name",
                hintStyle: TextStyle(
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
              decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 255, 48, 117)))),
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
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 255, 48, 117))),
                hintText: "Description",
                hintStyle: TextStyle(
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
            child: TextField(
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 255, 48, 117))),
                  hintText: "Max. Number of Participants",
                  hintStyle: TextStyle(
                    color: Color.fromARGB(39, 0, 0, 0),
                    fontSize: 15,
                  ),
                ),
                textAlign: TextAlign.start,
                enableSuggestions: true,
                autocorrect: true,
                controller: maxpartcontroller,
                keyboardType: TextInputType.number),
          ),
          SizedBox(height: screenheight * 0.02),
          InkWell(
            onTap: () {
              DatePicker.showDateTimePicker(context,
                  showTitleActions: true,
                  minTime: DateTime.now(),
                  onChanged: (date) {}, onConfirm: (date) {
                setState(() {
                  eventdate = date;
                });
                //print(eventdate);
              }, currentTime: DateTime.now());
            },
            child: Container(
              height: screenwidth * 0.13,
              width: screenwidth * 0.6,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black)),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  eventdate == DateTime(0, 0, 0)
                      ? "Date and Time"
                      : "${DateFormat.MMMd().format(eventdate)} @ ${DateFormat('hh:mm a').format(eventdate)}",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
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
              AppLocation chosen = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchLocation(),
                  ));
              setState(() {
                chosenLocation = chosen;
              });
              checklocationempty();
            },
            child: Container(
              height: screenwidth * 0.13,
              width: screenwidth * 0.6,
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black)),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  emptylocation ? "Location" : "Change Location",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
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
                  child: FlutterMap(
                    options: MapOptions(
                      center: LatLng(
                          chosenLocation.center[1], chosenLocation.center[0]),
                      zoom: 15.0,
                      maxZoom: 20.0,
                      minZoom: 13.0,
                    ),
                    layers: [
                      TileLayerOptions(
                          additionalOptions: {
                            'accessToken': dotenv.get('MAPBOX_ACCESS_TOKEN'),
                            'id': 'mapbox.mapbox-streets-v8'
                          },
                          urlTemplate:
                              "https://api.mapbox.com/styles/v1/andreaf1108/cl4y4djy6005f15obfxs5i0bb/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYW5kcmVhZjExMDgiLCJhIjoiY2w0cjBxamlzMGFwZjNqcGRodm9nczA5biJ9.qXRB_MLgHmifo6DYtCYirw"),
                      MarkerLayerOptions(markers: [
                        Marker(
                            point: LatLng(chosenLocation.center[1],
                                chosenLocation.center[0]),
                            builder: ((context) => const Icon(
                                  Icons.location_pin,
                                  color: Color.fromARGB(255, 255, 48, 117),
                                  size: 18,
                                )))
                      ])
                    ],
                  ),
                ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          InkWell(
            onTap: () async {
              if (titlecontroller.text.trim().isEmpty) {
                displayErrorSnackBar("Please enter a name for your event");
              } else if (desccontroller.text.trim().isEmpty) {
                displayErrorSnackBar("Please enter a description");
              } else if (int.parse(maxpartcontroller.text) <= 1) {
                displayErrorSnackBar(
                    "Please enter a max number of participants");
              } else if (eventdate.isAtSameMomentAs(DateTime(0, 0, 0))) {
                displayErrorSnackBar("Please choose a date for your event");
              } else if (emptylocation) {
                displayErrorSnackBar("Please choose a location for your event");
              } else {
                setState(() {
                  event.title = titlecontroller.text.trim();
                  event.description = desccontroller.text.trim();
                  event.maxparticipants = int.parse(maxpartcontroller.text);
                  event.interest = selectedinterest;
                  event.datetime = eventdate;
                  event.address = chosenLocation.address;
                  event.city = chosenLocation.city;
                  event.host = widget.curruser.username;
                  event.lat = chosenLocation.center[1];
                  event.lng = chosenLocation.center[0];
                });
                try {
                  await db.createevent(event, widget.curruser);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          LoadingScreen(uid: widget.curruser.uid),
                    ),
                  );
                } catch (e) {
                  displayErrorSnackBar("Could not create event");
                }
              }
            },
            child: SizedBox(
                height: 50,
                width: screenwidth * 0.6,
                child: Container(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 48, 117),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: const Center(
                      child: Text(
                    "Create Event",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )),
                )),
          ),
          SizedBox(
            height: screenheight * 0.04,
          ),
        ]),
      ),
    );
  }
}
