import 'dart:async';
import 'dart:io';

import 'package:clout/components/chat.dart';
import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:clout/components/unauthuserlistview.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/authentication/authscreen.dart';
import 'package:clout/screens/authscreens/chatroomscreen.dart';
import 'package:clout/screens/authscreens/editeventscreen.dart';
import 'package:clout/screens/authscreens/interestsearchscreen.dart';
import 'package:clout/screens/authscreens/loading.dart';
import 'package:clout/screens/authscreens/profilescreen.dart';
import 'package:clout/screens/unauthscreens/unauthprofilescreen.dart';

import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart' as Maps;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class UnAuthEventDetailScreen extends StatefulWidget {
  UnAuthEventDetailScreen(
      {super.key,
      required this.event,
      required this.participants,
      required this.curruserlocation,
      required this.analytics});
  Event event;
  List<AppUser> participants;
  AppLocation curruserlocation;
  FirebaseAnalytics analytics;
  @override
  State<UnAuthEventDetailScreen> createState() =>
      _UnAuthEventDetailScreenState();
}

class _UnAuthEventDetailScreenState extends State<UnAuthEventDetailScreen> {
  db_conn db = db_conn();
  bool joined = false;
  String joinedval = "Authenticate to Join";
  bool buttonpressed = false;
  bool gotochatbuttonpressed = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? qrcontroller;
  String qrmessage = "";
  bool showqrmessage = false;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

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
  }

  void updatescreen(eventid) async {
    try {
      Event updatedevent = await db.getEventfromDocId(eventid);
      setState(() {
        widget.event = updatedevent;
      });
      List<AppUser> temp = await db.geteventparticipantslist(widget.event);
      await Future.delayed(Duration(milliseconds: 50)).then((value) => {
            setState(() {
              widget.participants = temp;
            })
          });
    } catch (e) {
      displayErrorSnackBar("Could not refresh");
    }
  }

  void interactevent() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AuthScreen(
                analytics: widget.analytics,
              ),
          fullscreenDialog: true),
    );
  }

  Future<String> createShareLink() async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://outwithclout.com/event/${widget.event.docid}"),
      uriPrefix: "https://outwithclout.page.link",
    );
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    //print(dynamicLink.previewLink);
    return dynamicLink.shortUrl.toString();
  }

  @override
  void initState() {
    _addMarker(LatLng(widget.event.lat, widget.event.lng));
    super.initState();
  }

  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> usernavigate(AppUser user, int index) async {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UnAuthProfileScreen(
                  analytics: widget.analytics,
                  visit: true,
                ),
            fullscreenDialog: true),
      );
    }

    void shareevent(String text) async {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        text,
        subject: "Join ${widget.event.title} on Clout!",
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: true,
          title: widget.event.isinviteonly
              ? const Text(
                  "Invite Only",
                  style: TextStyle(color: Colors.black),
                  textScaleFactor: 1.0,
                )
              : null,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColor,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                String link = await createShareLink();
                shareevent("Join ${widget.event.title} on Clout!\n\n$link");
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                child: Icon(
                  Icons.ios_share,
                  color: Colors.black,
                ),
              ),
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(children: [
          SizedBox(
            height: screenheight * 0.3,
            width: screenwidth * 0.7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  widget.event.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Text(
            widget.event.title,
            style: const TextStyle(
                fontSize: 40, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: screenheight * 0.005,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {},
                child: Text(
                  widget.event.interest,
                  style: TextStyle(
                      fontSize: 25,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                onTap: () async {
                  try {
                    String hostdocid =
                        await db.getUserUIDfromUsername(widget.event.host);
                    AppUser eventhost = await db.getUserFromUID(hostdocid);
                    usernavigate(eventhost, 0);
                  } catch (e) {
                    displayErrorSnackBar("Could not retrieve host information");
                  }
                },
                child: Text(
                  "@${widget.event.host}",
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Text(
            "At ${widget.event.address}, ${DateFormat.MMMd().format(widget.event.datetime)} @ ${DateFormat('hh:mm a').format(widget.event.datetime)}",
            style: const TextStyle(
                fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          SizedBox(
            width: screenwidth,
            height: screenheight * 0.2,
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                GoogleMap(
                    markers: Set<Marker>.of(markers.values),
                    myLocationButtonEnabled: false,
                    zoomGesturesEnabled: true,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(widget.event.lat, widget.event.lng),
                        zoom: 15)),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        backgroundColor: Colors.white,
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: screenheight * 0.18,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await Maps.MapLauncher.showMarker(
                                            mapType: Maps.MapType.apple,
                                            coords: Maps.Coords(
                                                widget.event.lat,
                                                widget.event.lng),
                                            title: widget.event.address);
                                      },
                                      child: RichText(
                                        text: const TextSpan(
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w300),
                                            children: [
                                              TextSpan(text: "Open in "),
                                              TextSpan(
                                                  text: "Apple Maps",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Color.fromARGB(
                                                          255, 255, 48, 117),
                                                      fontWeight:
                                                          FontWeight.w300)),
                                            ]),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 0.05)),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await Maps.MapLauncher.showMarker(
                                            mapType: Maps.MapType.google,
                                            coords: Maps.Coords(
                                                widget.event.lat,
                                                widget.event.lng),
                                            title: widget.event.address);
                                      },
                                      child: RichText(
                                        text: const TextSpan(
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w300),
                                            children: [
                                              TextSpan(text: "Open in "),
                                              TextSpan(
                                                  text: "Google Maps",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Color.fromARGB(
                                                          255, 255, 48, 117),
                                                      fontWeight:
                                                          FontWeight.w300)),
                                            ]),
                                      ),
                                    ),
                                  ]),
                            ),
                          );
                        });
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Text(
            widget.event.description,
            style: const TextStyle(
                fontSize: 15, color: Colors.black, fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Text(
            widget.event.participants.length != widget.event.maxparticipants
                ? "${widget.event.participants.length}/${widget.event.maxparticipants} participants"
                : "Participant number reached",
            style: const TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: screenheight * 0.005,
          ),
          SizedBox(
            height: screenheight * 0.09 * widget.participants.length,
            width: screenwidth,
            child: Column(
              children: [
                UnAuthUserListView(
                  userres: widget.participants,
                  screenwidth: screenwidth,
                  presentparticipants: widget.event.presentparticipants,
                  onTap: usernavigate,
                ),
              ],
            ),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          InkWell(
              onTap: () async {
                interactevent();
              },
              child: joinedval == "Finished"
                  ? Container(
                      height: 50,
                      width: screenwidth,
                      color: Colors.white,
                      child: Text(
                        joinedval,
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor),
                        textScaleFactor: 1.1,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : PrimaryButton(
                      screenwidth: screenwidth,
                      buttonpressed: buttonpressed,
                      text: joinedval,
                      buttonwidth: screenwidth * 0.5,
                      bold: false,
                    ))
        ]),
      ),
    );
  }
}
