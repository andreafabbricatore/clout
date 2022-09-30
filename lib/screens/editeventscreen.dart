import 'package:clout/components/event.dart';
import 'package:clout/components/loadingoverlay.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/searchlocation.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/loading.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EditEventScreen extends StatefulWidget {
  EditEventScreen(
      {super.key,
      required this.curruser,
      required this.allowbackarrow,
      required this.event});
  AppUser curruser;
  bool allowbackarrow;

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
    "Art"
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
          center: [widget.event.lng, widget.event.lat]);
    });
  }

  Future<File> CompressAndGetFile(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
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

  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
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
        builder: (BuildContext context) =>
            LoadingScreen(uid: widget.curruser.uid),
      ),
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
    return buttonpressed
        ? LoadingOverlay(
            text: "Updating your event...",
            color: Colors.black,
          )
        : Scaffold(
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
              title: GestureDetector(
                onTap: () {
                  CompressAndGetFile(imagepath);
                },
                child: const Text(
                  "Edit Event",
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 48, 117),
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
              ),
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
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 48, 117),
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 48, 117))),
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
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 48, 117))),
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
                  child: TextFormField(
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 48, 117))),
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
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
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                        child: FlutterMap(
                          options: MapOptions(
                            center: LatLng(chosenLocation.center[1],
                                chosenLocation.center[0]),
                            zoom: 15.0,
                            maxZoom: 20.0,
                            minZoom: 13.0,
                          ),
                          layers: [
                            TileLayerOptions(
                                additionalOptions: {
                                  'accessToken':
                                      dotenv.get('MAPBOX_ACCESS_TOKEN'),
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
                                        color:
                                            Color.fromARGB(255, 255, 48, 117),
                                        size: 18,
                                      )))
                            ])
                          ],
                        ),
                      ),
                SizedBox(
                  height: screenheight * 0.02,
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
                              widget.event.description =
                                  desccontroller.text.trim();
                              widget.event.maxparticipants =
                                  int.parse(maxpartcontroller.text);
                              widget.event.interest = selectedinterest;
                              widget.event.datetime = eventdate;
                              widget.event.country =
                                  chosenLocation.country.toLowerCase();
                              widget.event.address = chosenLocation.address;
                              widget.event.city =
                                  chosenLocation.city.toLowerCase().split(" ");
                              widget.event.lat = chosenLocation.center[1];
                              widget.event.lng = chosenLocation.center[0];
                            });
                            try {
                              if (imagepath == null) {
                                compressedimgpath = null;
                              } else {
                                compressedimgpath =
                                    await CompressAndGetFile(imagepath);
                              }
                              await db.updateEvent(
                                  widget.event, compressedimgpath);
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
                          "Update Event",
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
