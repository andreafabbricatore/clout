import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

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
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
  bool showbutton = false;
  CameraPosition? cameraposition;
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

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

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

  Future<BitmapDescriptor> convertImageFileToCustomBitmapDescriptor(
    File imageFile, {
    int size = 150,
    bool addBorder = true,
    Color borderColor = const Color.fromARGB(255, 255, 48, 117),
    double borderSize = 10,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color;
    final double radius = size / 2;

    //make canvas clip path to prevent image drawing over the circle
    final Path clipPath = Path();
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Radius.circular(200)));

    canvas.clipPath(clipPath);

    //paintImage
    final Uint8List imageUint8List = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(imageUint8List);
    final ui.FrameInfo imageFI = await codec.getNextFrame();
    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        image: imageFI.image,
        fit: BoxFit.cover);

    if (addBorder) {
      //draw Border
      paint.color = borderColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = borderSize;
      canvas.drawCircle(Offset(radius, radius), radius, paint);
    }

    //convert canvas as PNG bytes
    final _image = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final data = await _image.toByteData(format: ui.ImageByteFormat.png);

    //convert PNG bytes as BitmapDescriptor
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  void setusermarkers(List<AppUser> users) async {
    Map<MarkerId, Marker> markerdict = {};
    for (int i = 0; i < users.length; i++) {
      final File markerImageFile =
          await DefaultCacheManager().getSingleFile(users[i].pfpurl);
      BitmapDescriptor bmd =
          await convertImageFileToCustomBitmapDescriptor(markerImageFile);

      Marker marker = Marker(
          markerId: MarkerId(users[i].uid),
          draggable: true,
          position: LatLng(
              users[i].lastknownlat,
              users[i]
                  .lastknownlng), //With this parameter you automatically obtain latitude and longitude
          icon: bmd,
          infoWindow: InfoWindow.noText,
          onTap: () async {
            AppUser user = await db.getUserFromUID(users[i].uid);
            logic.usernavigate(widget.analytics, widget.curruserlocation,
                widget.curruser, user, 0, context);
          });
      markerdict[MarkerId(users[i].uid)] = marker;
    }

    setState(() {
      markers = markerdict;
    });
  }

  void seteventmarkers(List<Event> events) async {
    Map<MarkerId, Marker> markerdict = {};
    for (int i = 0; i < events.length; i++) {
      final File markerImageFile =
          await DefaultCacheManager().getSingleFile(events[i].image);
      final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
      final ui.Codec markerImageCodec = await ui.instantiateImageCodec(
        markerImageBytes,
        targetWidth: 50,
      );
      final ui.FrameInfo frameInfo = await markerImageCodec.getNextFrame();
      final ByteData? byteData = await frameInfo.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List resizedMarkerImageBytes = byteData!.buffer.asUint8List();

      Marker marker = Marker(
        markerId: MarkerId(events[i].docid),
        draggable: true,
        position: LatLng(
            events[i].lat,
            events[i]
                .lng), //With this parameter you automatically obtain latitude and longitude
        infoWindow: InfoWindow(
          title: events[i].title,
        ),
        icon: BitmapDescriptor.fromBytes(resizedMarkerImageBytes),
      );
      markerdict[MarkerId(events[i].docid)] = marker;
    }

    setState(() {
      markers = markerdict;
    });
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
                markers: Set<Marker>.of(markers.values),
                zoomGesturesEnabled: true, //enable Zoom in, out on map
                initialCameraPosition: CameraPosition(
                  //innital position in map
                  target: LatLng(widget.curruserlocation.center[1],
                      widget.curruserlocation.center[0]), //initial position
                  zoom: 12.0, //initial zoom level
                ),

                mapType: MapType.normal, //map type

                onMapCreated: (controller) async {
                  //method called when map is created
                  List<AppUser> users = await db.retrievefriendsformap(
                      widget.curruser,
                      widget.curruserlocation.center[1],
                      widget.curruserlocation.center[0]);
                  setusermarkers(users);
                  setState(() {
                    mapController = controller;
                    showbutton = false;
                  });
                },
                onCameraMove: (position) {
                  setState(() {
                    cameraposition = position;
                    showbutton = true;
                  });
                },
              ),
              showbutton
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 150),
                        child: GestureDetector(
                          onTap: () async {
                            List<AppUser> users =
                                await db.retrievefriendsformap(
                              widget.curruser,
                              cameraposition!.target.latitude,
                              cameraposition!.target.longitude,
                            );
                            setusermarkers(users);
                            setState(() {
                              showbutton = false;
                            });
                          },
                          child: Container(
                            width: screenwidth * 0.4,
                            height: screenheight * 0.05,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: const Center(
                              child: Text(
                                "Search Area",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ));
  }
}
