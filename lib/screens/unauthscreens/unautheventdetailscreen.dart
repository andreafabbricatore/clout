import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clout/defs/event.dart';
import 'package:clout/defs/location.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:clout/models/unauthuserlistview.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/screens/authentication/authscreen.dart';
import 'package:clout/screens/unauthscreens/unauthprofilescreen.dart';

import 'package:clout/services/db.dart';
import 'package:clout/services/logic.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart' as Maps;
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
  applogic logic = applogic();
  bool joined = false;
  String joinedval = "Join";
  bool buttonpressed = false;
  bool gotochatbuttonpressed = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? qrcontroller;
  String qrmessage = "";
  bool showqrmessage = false;
  bool authbuttonpressed = false;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

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
      await Future.delayed(Duration(milliseconds: 50));
      setState(() {
        widget.participants = temp;
      });
    } catch (e) {
      logic.displayErrorSnackBar("Could not refresh", context);
    }
  }

  void showauthdialog(screenheight, screenwidth) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  height: screenheight * 0.2,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Column(children: [
                    const Text(
                      "Login or Signup\nto join an event",
                      style: TextStyle(color: Colors.black, fontSize: 25),
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.linear(1.0),
                    ),
                    SizedBox(
                      height: screenheight * 0.02,
                    ),
                    GestureDetector(
                        onTap: authbuttonpressed
                            ? null
                            : () async {
                                setState(() {
                                  authbuttonpressed = true;
                                });
                                goauthscreen();
                                setState(() {
                                  authbuttonpressed = false;
                                });
                              },
                        child: PrimaryButton(
                            screenwidth: screenwidth,
                            buttonpressed: authbuttonpressed,
                            text: "Continue",
                            buttonwidth: screenwidth * 0.6,
                            bold: false)),
                  ]),
                ),
              );
            },
          );
        });
  }

  void goauthscreen() async {
    await widget.analytics
        .logEvent(name: "auth_from_guest_screen", parameters: {});
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
      link: Uri.parse("https://outwithclout.com/#/event/${widget.event.docid}"),
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

  Future<void> usernavigate(AppUser user) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UnAuthProfileScreen(
                analytics: widget.analytics,
                visit: true,
              ),
          fullscreenDialog: true,
          settings: const RouteSettings(name: "UnAuthProfileScreen")),
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

  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

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
                  textScaler: TextScaler.linear(1.0),
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
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 8.0, 0),
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
                child: CachedNetworkImage(
                  imageUrl: widget.event.image,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 10),
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
                    AppUser eventhost =
                        await db.getUserFromUID(widget.event.hostdocid);
                    usernavigate(eventhost);
                  } catch (e) {
                    logic.displayErrorSnackBar(
                        "Could not retrieve host information", context);
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
            widget.event.showlocation
                ? "At ${widget.event.address}, ${DateFormat.MMMd().format(widget.event.datetime)} @ ${DateFormat('hh:mm a').format(widget.event.datetime)}"
                : "At secret location, ${DateFormat.MMMd().format(widget.event.datetime)} @ ${DateFormat('hh:mm a').format(widget.event.datetime)}",
            style: const TextStyle(
                fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          unautheventscreenmapsection(screenwidth, screenheight, context),
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
                ? widget.event.showparticipants
                    ? "${widget.event.participants.length}/${widget.event.maxparticipants} participants"
                    : "?/${widget.event.maxparticipants} participants"
                : "Participant number reached",
            style: const TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
            textScaler: TextScaler.linear(1.0),
          ),
          SizedBox(
            height: screenheight * 0.005,
          ),
          widget.event.showparticipants
              ? SizedBox(
                  height: 16.0 + 60.0 * widget.participants.length,
                  width: screenwidth,
                  child: Column(
                    children: [
                      UnAuthUserListView(
                        userres: widget.participants,
                        screenwidth: screenwidth,
                        presentparticipants: widget.event.presentparticipants,
                        onTap: usernavigate,
                        showaddfriend: false,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  width: screenwidth * 0.8,
                  height: screenheight * 0.2,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock,
                          color: Colors.black,
                          size: 60,
                        ),
                        SizedBox(height: screenheight * 0.02),
                        const Text(
                          "Host has hidden joined participants.",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w200),
                          textScaler: TextScaler.linear(1.0),
                          overflow: TextOverflow.visible,
                        )
                      ]),
                ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          GestureDetector(
              onTap: () async {
                showauthdialog(screenheight, screenwidth);
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

  SizedBox unautheventscreenmapsection(
      double screenwidth, double screenheight, BuildContext context) {
    return SizedBox(
      width: screenwidth,
      height: screenheight * 0.2,
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          widget.event.showlocation
              ? GoogleMap(
                  markers: Set<Marker>.of(markers.values),
                  myLocationButtonEnabled: false,
                  zoomGesturesEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(widget.event.lat, widget.event.lng),
                      zoom: 15))
              : Container(),
          GestureDetector(
            onTap: !widget.event.showlocation
                ? null
                : () {
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
              width: screenwidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: widget.event.showlocation
                    ? Colors.transparent
                    : Color.fromARGB(240, 255, 48, 117),
              ),
              child: widget.event.showlocation
                  ? Container()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          const Icon(
                            Icons.lock,
                            color: Colors.black,
                            size: 60,
                          ),
                          SizedBox(height: screenheight * 0.02),
                          const Text(
                            "Secret location.\nWill be revealed one hour before.",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w200),
                            textScaler: TextScaler.linear(1.0),
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                          ),
                        ]),
            ),
          )
        ],
      ),
    );
  }
}
