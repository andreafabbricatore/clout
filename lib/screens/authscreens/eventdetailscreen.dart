import 'dart:async';
import 'dart:io';

import 'package:clout/components/chat.dart';
import 'package:clout/components/event.dart';
import 'package:clout/components/location.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/authscreens/chatroomscreen.dart';
import 'package:clout/screens/authscreens/editeventscreen.dart';
import 'package:clout/screens/authscreens/interestsearchscreen.dart';
import 'package:clout/screens/authscreens/loading.dart';
import 'package:clout/screens/authscreens/profilescreen.dart';

import 'package:clout/services/db.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart' as Maps;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class EventDetailScreen extends StatefulWidget {
  EventDetailScreen(
      {super.key,
      required this.event,
      required this.curruser,
      required this.participants,
      required this.curruserlocation,
      required this.analytics});
  Event event;
  AppUser curruser;
  List<AppUser> participants;
  FirebaseAnalytics analytics;
  AppLocation curruserlocation;
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  db_conn db = db_conn();
  bool joined = false;
  String joinedval = "Join";
  bool buttonpressed = false;
  bool gotochatbuttonpressed = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? qrcontroller;
  String qrmessage = "";
  bool showqrmessage = false;
  bool deletebuttonpressed = false;
  bool expandparticipants = true;
  List selectedsenders = [];
  bool sharebuttonpressed = false;

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

  Future<void> reportevent(Event event) async {
    try {
      await db.reportEvent(event);
      await widget.analytics.logEvent(name: "reported_event", parameters: {
        "interest": widget.event.interest,
        "inviteonly": widget.event.isinviteonly.toString(),
        "maxparticipants": widget.event.maxparticipants,
        "participants": widget.event.participants.length,
        "title": widget.event.title
      });
      displayErrorSnackBar("Reported ${event.title}");
    } catch (e) {
      displayErrorSnackBar("Could not report, please try again");
    }
  }

  Future<void> updatecurruser() async {
    try {
      AppUser updateduser = await db.getUserFromUID(widget.curruser.uid);
      setState(() {
        widget.curruser = updateduser;
      });
    } catch (e) {
      displayErrorSnackBar("Could not update user");
    }
  }

  Future<void> chatnavigate(Chat chat) async {
    await widget.analytics
        .logEvent(name: "opened_chat_from_event_screen", parameters: {
      "interest": widget.event.interest,
      "inviteonly": widget.event.isinviteonly.toString(),
      "maxparticipants": widget.event.maxparticipants,
      "participants": widget.event.participants.length,
      "ishost": (widget.curruser.uid == widget.event.hostdocid).toString()
    });
    await Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (_) => ChatRoomScreen(
                  chatinfo: chat,
                  curruser: widget.curruser,
                  curruserlocation: widget.curruserlocation,
                  analytics: widget.analytics,
                ),
            settings: RouteSettings(name: "ChatRoomScreen")));
    updatescreen(widget.event.docid);
  }

  void checkifjoined() async {
    bool found = false;
    for (int i = 0; i < widget.participants.length; i++) {
      if (widget.participants[i].username == widget.curruser.username) {
        setState(() {
          found = true;
          joined = true;
        });
      }
    }
    if (found) {
      if (widget.curruser.username == widget.event.host) {
        setState(() {
          joinedval = "Delete Event";
        });
      } else {
        setState(() {
          joinedval = "Leave";
        });
      }
    } else {
      setState(() {
        joined = false;
      });
      if (widget.event.maxparticipants == widget.participants.length) {
        setState(() {
          joinedval = "Full";
        });
      } else {
        setState(() {
          joinedval = "Join";
        });
      }
    }

    if (widget.event.datetime.isBefore(DateTime.now())) {
      setState(() {
        joinedval = "Finished";
      });
    }
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
      checkifjoined();
    } catch (e) {
      displayErrorSnackBar("Could not refresh");
    }
  }

  void interactevent(context) async {
    if (!joined && joinedval == "Join") {
      try {
        setState(() {
          buttonpressed = true;
        });
        await db.joinevent(widget.event, widget.curruser, widget.event.docid);
        await widget.analytics.logEvent(name: "joined_event", parameters: {
          "interest": widget.event.interest,
          "inviteonly": widget.event.isinviteonly.toString(),
          "maxparticipants": widget.event.maxparticipants,
          "currentparticipants": widget.event.participants.length
        });
      } catch (e) {
        displayErrorSnackBar("Could not join event");
      } finally {
        setState(() {
          buttonpressed = false;
        });
        updatescreen(widget.event.docid);
      }
    } else if ((!joined && joinedval == "Full") || joinedval == "Finished") {
      //print(joinedval);
    } else if (joined && joinedval == "Delete Event") {
      try {
        setState(() {
          buttonpressed = true;
        });
        await db.deleteevent(widget.event, widget.curruser);
        await widget.analytics.logEvent(name: "deleted_event", parameters: {
          "interest": widget.event.interest,
          "inviteonly": widget.event.isinviteonly.toString(),
          "maxparticipants": widget.event.maxparticipants,
          "currentparticipants": widget.event.participants.length,
          "predeletionstatus": joinedval
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LoadingScreen(
                    uid: widget.curruser.uid,
                    analytics: widget.analytics,
                  ),
              settings: RouteSettings(name: "LoadingScreen"),
              fullscreenDialog: true),
        );
      } catch (e) {
        displayErrorSnackBar("Could not delete event");
        updatescreen(widget.event.docid);
        setState(() {
          buttonpressed = false;
        });
      }
    } else {
      try {
        setState(() {
          buttonpressed = true;
        });
        await db.leaveevent(widget.curruser, widget.event);
        await widget.analytics.logEvent(name: "left_event", parameters: {
          "interest": widget.event.interest,
          "inviteonly": widget.event.isinviteonly.toString(),
          "maxparticipants": widget.event.maxparticipants,
          "currentparticipants": widget.event.participants.length,
        });
      } catch (e) {
        displayErrorSnackBar("Could not leave event");
      } finally {
        updatescreen(widget.event.docid);
        setState(() {
          buttonpressed = false;
        });
      }
    }
  }

  Future<void> validateqr(String? qrcontent) async {
    List contents = qrcontent!.split("/");
    String eventid = contents[0];
    String useruid = contents[1];
    if (eventid == widget.event.docid) {
      if (widget.event.participants.contains(useruid)) {
        if (!widget.event.presentparticipants.contains(useruid)) {
          await db.setpresence(
              widget.event.docid, useruid, widget.curruser.uid);
          await widget.analytics.logEvent(name: "validated_qr", parameters: {
            "interest": widget.event.interest,
            "inviteonly": widget.event.isinviteonly.toString(),
            "maxparticipants": widget.event.maxparticipants,
            "participants": widget.event.participants.length,
            "presentparticipants": widget.event.presentparticipants.length,
          });
          setState(() {
            qrmessage = "QR code Validated!";
          });
          updatescreen(widget.event.docid);
        } else {
          await widget.analytics
              .logEvent(name: "already_validated_qr", parameters: {
            "interest": widget.event.interest,
            "inviteonly": widget.event.isinviteonly.toString(),
            "maxparticipants": widget.event.maxparticipants,
            "participants": widget.event.participants.length,
            "presentparticipants": widget.event.presentparticipants.length,
          });
          setState(() {
            qrmessage = "QR code has already been validated";
          });
        }
      } else {
        await widget.analytics
            .logEvent(name: "non_participant_qr", parameters: {
          "interest": widget.event.interest,
          "inviteonly": widget.event.isinviteonly.toString(),
          "maxparticipants": widget.event.maxparticipants,
          "participants": widget.event.participants.length,
          "presentparticipants": widget.event.presentparticipants.length,
        });
        setState(() {
          qrmessage = "User is not a participant to this event";
        });
      }
    } else {
      await widget.analytics.logEvent(name: "invalid_event_qr", parameters: {
        "interest": widget.event.interest,
        "inviteonly": widget.event.isinviteonly.toString(),
        "maxparticipants": widget.event.maxparticipants,
        "participants": widget.event.participants.length,
        "presentparticipants": widget.event.presentparticipants.length,
      });
      setState(() {
        qrmessage = "Invalid: QR code is not for this event";
      });
    }
  }

  void gotointerestsearchscreen(
      String interest, List<Event> interesteventlist) async {
    await widget.analytics
        .logEvent(name: "visit_interest_screen_from_event", parameters: {
      "interest": widget.event.interest,
      "inviteonly": widget.event.isinviteonly.toString(),
      "maxparticipants": widget.event.maxparticipants,
      "participants": widget.event.participants.length,
      "ishost": (widget.curruser.uid == widget.event.hostdocid).toString()
    });
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

  Future<dynamic> showthreedotbottomsheet(
      BuildContext context, double screenheight, double screenwidth) {
    return showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SizedBox(
                  height: screenheight * 0.3,
                  child: Padding(
                    padding:
                        EdgeInsets.fromLTRB(20, screenheight * 0.01, 20, 20),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 8,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(60, 0, 0, 0),
                          ),
                        ),
                        SizedBox(
                          height: screenheight * 0.015,
                        ),
                        GestureDetector(
                          onTap: widget.curruser.uid == widget.event.hostdocid
                              ? joinedval == "Finished"
                                  ? deletebuttonpressed
                                      ? null
                                      : () async {
                                          setState(() {
                                            deletebuttonpressed = true;
                                          });
                                          await db.deletefutureevent(
                                              widget.event, widget.curruser);
                                          setState(() {
                                            deletebuttonpressed = false;
                                          });
                                          await widget.analytics.logEvent(
                                              name: "deleted_event",
                                              parameters: {
                                                "interest":
                                                    widget.event.interest,
                                                "inviteonly": widget
                                                    .event.isinviteonly
                                                    .toString(),
                                                "maxparticipants": widget
                                                    .event.maxparticipants,
                                                "currentparticipants": widget
                                                    .event.participants.length,
                                                "predeletionstatus": joinedval
                                              });
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoadingScreen(
                                                      uid: widget.curruser.uid,
                                                      analytics:
                                                          widget.analytics,
                                                    ),
                                                settings: RouteSettings(
                                                    name: "LoadingScreen"),
                                                fullscreenDialog: true),
                                          );
                                        }
                                  : () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                EditEventScreen(
                                                  curruser: widget.curruser,
                                                  allowbackarrow: true,
                                                  event: widget.event,
                                                  analytics: widget.analytics,
                                                ),
                                            settings: RouteSettings(
                                                name: "EditEventScreen")),
                                      );
                                    }
                              : () {
                                  reportevent(widget.event);
                                },
                          child: Container(
                            height: screenheight * 0.1,
                            width: screenwidth * 0.85,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.curruser.uid == widget.event.hostdocid
                                      ? joinedval != "Finished"
                                          ? Icons.edit
                                          : Icons.delete
                                      : Icons.flag_outlined,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                SizedBox(
                                  height: screenheight * 0.01,
                                ),
                                Text(
                                  widget.curruser.uid == widget.event.hostdocid
                                      ? joinedval != "Finished"
                                          ? "Edit Event"
                                          : "Delete Event"
                                      : "Report Event",
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                  textScaleFactor: 1.0,
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: screenheight * 0.02,
                        ),
                        GestureDetector(
                          onTap: widget.curruser.uid == widget.event.hostdocid
                              ? joinedval == "Finished"
                                  ? () {
                                      Navigator.pop(context);
                                      showModalBottomSheet(
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                                builder: (context, setState) {
                                              return SizedBox(
                                                height: screenheight * 0.8,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    showqrmessage != false
                                                        ? result != null
                                                            ? Container(
                                                                height:
                                                                    screenheight *
                                                                        0.06,
                                                                width:
                                                                    screenwidth,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                child: Center(
                                                                  child: Text(
                                                                    qrmessage,
                                                                    textScaleFactor:
                                                                        1.0,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w400),
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(
                                                                height:
                                                                    screenheight *
                                                                        0.06,
                                                                width:
                                                                    screenwidth,
                                                              )
                                                        : Container(
                                                            height:
                                                                screenheight *
                                                                    0.06,
                                                            width: screenwidth,
                                                          ),
                                                    SizedBox(
                                                      height:
                                                          screenheight * 0.4,
                                                      child: QRView(
                                                        key: qrKey,
                                                        overlay:
                                                            QrScannerOverlayShape(
                                                                cutOutSize:
                                                                    screenheight *
                                                                        0.35),
                                                        onPermissionSet:
                                                            (p0, permission) {
                                                          if (!permission) {
                                                            Navigator.pop(
                                                                context);
                                                            displayErrorSnackBar(
                                                                "Could not open camera, please ensure Clout has access to camera");
                                                          }
                                                        },
                                                        onQRViewCreated:
                                                            (QRViewController
                                                                controller) async {
                                                          setState(() {
                                                            this.qrcontroller =
                                                                controller;
                                                            showqrmessage =
                                                                false;
                                                            result = null;
                                                          });
                                                          controller
                                                              .scannedDataStream
                                                              .listen(
                                                                  (scanData) async {
                                                            setState(() {
                                                              result = scanData;
                                                            });
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    Container(
                                                      height:
                                                          screenheight * 0.1,
                                                      width: screenwidth,
                                                      color: Colors.white,
                                                      child: Center(
                                                        child: GestureDetector(
                                                          onTap: result == null
                                                              ? null
                                                              : () async {
                                                                  try {
                                                                    await validateqr(
                                                                        result!
                                                                            .code);
                                                                    setState(
                                                                        () {
                                                                      result =
                                                                          null;
                                                                      showqrmessage =
                                                                          true;
                                                                    });
                                                                  } catch (e) {}
                                                                },
                                                          child: SizedBox(
                                                              height: 50 >
                                                                      screenheight *
                                                                          0.1
                                                                  ? screenheight *
                                                                      0.1
                                                                  : 50,
                                                              width:
                                                                  screenwidth *
                                                                      0.5,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: result ==
                                                                            null
                                                                        ? const Color.fromARGB(
                                                                            180,
                                                                            255,
                                                                            48,
                                                                            117)
                                                                        : Theme.of(context)
                                                                            .primaryColor,
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            20))),
                                                                child:
                                                                    const Center(
                                                                        child:
                                                                            Text(
                                                                  "Validate",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800),
                                                                )),
                                                              )),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            });
                                          });
                                    }
                                  : null
                              : joinedval == "Leave" || joinedval == "Finished"
                                  ? () {
                                      Navigator.pop(context);
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              backgroundColor: Colors.white,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 10, 10, 10),
                                                height: screenheight * 0.35,
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: Center(
                                                  child: CustomPaint(
                                                      size: Size.square(
                                                          screenwidth * 0.6),
                                                      painter: QrPainter(
                                                          data:
                                                              "${widget.event.docid}/${widget.curruser.uid}",
                                                          version:
                                                              QrVersions.auto,
                                                          eyeStyle: QrEyeStyle(
                                                              color:
                                                                  Colors.black,
                                                              eyeShape:
                                                                  QrEyeShape
                                                                      .square),
                                                          embeddedImageStyle:
                                                              QrEmbeddedImageStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor))),
                                                ),
                                              ),
                                            );
                                          });
                                    }
                                  : null,
                          child: Container(
                            //if finished works, if joined works,
                            height: screenheight * 0.1,
                            width: screenwidth * 0.85,
                            decoration: BoxDecoration(
                                color: joinedval == "Finished" ||
                                        joinedval == "Leave"
                                    ? Theme.of(context).primaryColor
                                    : const Color.fromARGB(180, 255, 48, 117),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.qr_code,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                SizedBox(
                                  height: screenheight * 0.01,
                                ),
                                Text(
                                  widget.curruser.uid == widget.event.hostdocid
                                      ? "Scan QR"
                                      : "Show QR",
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                  textScaleFactor: 1.0,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
            },
          );
        });
  }

  Future<dynamic> showsharebottomsheet(
      BuildContext context,
      double screenheight,
      double screenwidth,
      List<AppUser> chatusers,
      shareevent) {
    void shareeventfinal() async {
      String link = await createShareLink();
      shareevent("Join ${widget.event.title} on Clout!\n\n$link");
    }

    Future<bool> sendevent() async {
      try {
        for (int i = 0; i < selectedsenders.length; i++) {
          bool userchatexists = await db.checkuserchatexists(
              widget.curruser.uid, selectedsenders[i]);

          if (!userchatexists) {
            await db.createuserchat(widget.curruser, selectedsenders[i]);
          }

          Chat userchat = await db.getUserChatFromParticipants(
              widget.curruser.uid, selectedsenders[i]);

          List temp = userchat.chatname;
          temp.removeWhere((element) => element == widget.curruser.username);
          String chatname = temp[0];
          db.sendmessage(
              widget.event.docid,
              widget.curruser,
              userchat.chatid,
              chatname,
              userchat.type,
              "event",
              widget.event.image,
              widget.event.title,
              widget.event.datetime);
        }
        setState(() {
          selectedsenders = [];
        });
        return true;
      } catch (e) {
        setState(() {
          selectedsenders = [];
        });
        return false;
      }
    }

    return showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              Future<void> selectuser(AppUser user, int index) async {
                if (selectedsenders.contains(user.uid)) {
                  setState(() {
                    selectedsenders.remove(user.uid);
                  });
                } else {
                  setState(() {
                    selectedsenders.add(user.uid);
                  });
                }
              }

              return SizedBox(
                  height: screenheight * 0.6,
                  width: screenwidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 8,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(60, 0, 0, 0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                          child: SizedBox(
                            height: screenheight * 0.4,
                            width: screenwidth,
                            child: widget.curruser.following.isEmpty
                                ? const Center(
                                    child: Text(
                                      "The people you follow\nwill show up here.",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      textScaleFactor: 1.0,
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : UserListView(
                                    userres: chatusers,
                                    onTap: selectuser,
                                    curruser: widget.curruser,
                                    screenwidth: screenwidth,
                                    showcloutscore: false,
                                    showrembutton: false,
                                    showsendbutton: true,
                                    selectedsenders: selectedsenders,
                                  ),
                          ),
                        ),
                        SizedBox(height: screenheight * 0.03),
                        GestureDetector(
                          onTap: sharebuttonpressed
                              ? null
                              : selectedsenders.isEmpty
                                  ? () {
                                      setState(() {
                                        sharebuttonpressed = true;
                                      });
                                      shareeventfinal();
                                      setState(() {
                                        sharebuttonpressed = false;
                                      });
                                    }
                                  : () async {
                                      setState(() {
                                        sharebuttonpressed = true;
                                      });
                                      bool sendres = await sendevent();
                                      setState(() {
                                        sharebuttonpressed = false;
                                      });
                                      Navigator.pop(context);
                                      displayErrorSnackBar(sendres
                                          ? "Sent!"
                                          : "Could not send.");
                                    },
                          child: Container(
                            //if finished works, if joined works,
                            height: screenheight * 0.08,
                            width: screenwidth * 0.85,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 4.0,
                                          selectedsenders.isEmpty ? 4.0 : 0.0),
                                      child: Icon(
                                        selectedsenders.isEmpty
                                            ? Icons.ios_share
                                            : Icons.send,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      selectedsenders.isEmpty
                                          ? !sharebuttonpressed
                                              ? "Share Link"
                                              : "Sharing Link"
                                          : !sharebuttonpressed
                                              ? "Send Event"
                                              : "Sending Event",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal),
                                      textScaleFactor: 1.0,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
            },
          );
        });
  }

  @override
  void initState() {
    checkifjoined();
    _addMarker(LatLng(widget.event.lat, widget.event.lng));
    super.initState();
  }

  @override
  void reassemble() {
    // TODO: implement reassemble
    super.reassemble();
    try {
      if (Platform.isAndroid) {
        qrcontroller!.pauseCamera();
      } else if (Platform.isIOS) {
        qrcontroller!.resumeCamera();
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> usernavigate(AppUser user, int index) async {
      await widget.analytics.logEvent(
          name: "visited_profile_screen_from_event_screen",
          parameters: {
            "interest": widget.event.interest,
            "inviteonly": widget.event.isinviteonly.toString(),
            "maxparticipants": widget.event.maxparticipants,
            "participants": widget.event.participants.length,
            "ishost":
                (widget.event.hostdocid == widget.curruser.uid).toString(),
            "visitinghost": (widget.event.hostdocid == user.uid).toString()
          });
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => ProfileScreen(
                    user: user,
                    curruser: widget.curruser,
                    visit: true,
                    curruserlocation: widget.curruserlocation,
                    analytics: widget.analytics,
                  ),
              settings: RouteSettings(name: "ProfileScreen")));
    }

    Future<void> remuser(AppUser user, int index) async {
      try {
        await db.removeparticipant(user, widget.event);
        await widget.analytics.logEvent(name: "rem_participant", parameters: {
          "interest": widget.event.interest,
          "inviteonly": widget.event.isinviteonly.toString(),
          "maxparticipants": widget.event.maxparticipants,
          "participants": widget.event.participants.length,
          "usernationality": user.nationality,
          "userbio": user.bio,
          "username": user.username,
          "userclout": user.clout,
          "userfollowers": user.followers.length,
          "userfollowing": user.following.length,
          "userfollowersgtfollowing":
              (user.followers.length >= user.following.length).toString()
        });
        updatescreen(widget.event.docid);
      } catch (e) {
        displayErrorSnackBar("Could not remove participant, please try again");
      }
    }

    void shareevent(String text) async {
      final box = context.findRenderObject() as RenderBox?;
      await widget.analytics.logEvent(name: "shared_event", parameters: {
        "interest": widget.event.interest,
        "inviteonly": widget.event.isinviteonly.toString(),
        "maxparticipants": widget.event.maxparticipants,
        "participants": widget.event.participants.length,
        "ishost": (widget.curruser.uid == widget.event.hostdocid).toString(),
        "isfollowinghost": widget.curruser.following
            .contains(widget.event.hostdocid)
            .toString()
      });
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
            onTap: gotochatbuttonpressed
                ? null
                : () async {
                    setState(() {
                      gotochatbuttonpressed = true;
                    });
                    try {
                      if (widget.event.participants
                          .contains(widget.curruser.uid)) {
                        Chat chat =
                            await db.getChatfromDocId(widget.event.chatid);
                        chatnavigate(chat);
                      } else {
                        Navigator.pop(context);
                        displayErrorSnackBar("Please join the event first");
                      }
                    } catch (e) {
                      displayErrorSnackBar("Could not display chat");
                    }
                    setState(() {
                      gotochatbuttonpressed = false;
                    });
                  },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              List<AppUser> chatusers =
                  await db.getfollowinglist(widget.curruser);
              showsharebottomsheet(
                  context, screenheight, screenwidth, chatusers, shareevent);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 3.0, 8),
              child: Icon(
                Icons.ios_share,
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showthreedotbottomsheet(context, screenheight, screenwidth);
            },
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 16.0, 4),
              child: Icon(
                Icons.more_vert_outlined,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
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
                onTap: () async {
                  try {
                    List<Event> interesteventlist = [];
                    interesteventlist = await db.getLngLatEventsByInterest(
                        widget.curruserlocation.center[0],
                        widget.curruserlocation.center[1],
                        widget.event.interest,
                        widget.curruserlocation.country,
                        widget.curruser);
                    gotointerestsearchscreen(
                        widget.event.interest, interesteventlist);
                  } catch (e) {
                    displayErrorSnackBar("Could not go to interest screen");
                  }
                },
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
            widget.event.showlocation
                ? "At ${widget.event.address}, ${DateFormat.MMMd().format(widget.event.datetime)} @ ${DateFormat('hh:mm a').format(widget.event.datetime)}"
                : "At secret location, ${DateFormat.MMMd().format(widget.event.datetime)} @ ${DateFormat('hh:mm a').format(widget.event.datetime)}",
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                                      fontWeight:
                                                          FontWeight.w300),
                                                  children: [
                                                    TextSpan(text: "Open in "),
                                                    TextSpan(
                                                        text: "Apple Maps",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    48,
                                                                    117),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300)),
                                                  ]),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                border:
                                                    Border.all(width: 0.05)),
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
                                                      fontWeight:
                                                          FontWeight.w300),
                                                  children: [
                                                    TextSpan(text: "Open in "),
                                                    TextSpan(
                                                        text: "Google Maps",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    48,
                                                                    117),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300)),
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
                                  textScaleFactor: 1.0,
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.center,
                                ),
                              ]),
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
          Row(
            children: [
              SizedBox(
                width: screenwidth * 0.86,
                child: Text(
                  widget.event.participants.length !=
                          widget.event.maxparticipants
                      ? (widget.event.showparticipants ||
                              widget.curruser.uid == widget.event.hostdocid)
                          ? "${widget.event.participants.length}/${widget.event.maxparticipants} participants"
                          : "?/${widget.event.maxparticipants} participants"
                      : "Participant number reached",
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  textScaleFactor: 1.0,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              (widget.event.showparticipants ||
                      widget.curruser.uid == widget.event.hostdocid)
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          expandparticipants = !expandparticipants;
                        });
                      },
                      child: Transform.flip(
                        child: Icon(Icons.arrow_drop_down_outlined, size: 30),
                        flipY: expandparticipants,
                      ))
                  : Container()
            ],
          ),
          SizedBox(
            height: screenheight * 0.005,
          ),
          (widget.event.showparticipants ||
                  widget.curruser.uid == widget.event.hostdocid)
              ? !expandparticipants
                  ? Container()
                  : SizedBox(
                      height: 16.0 + 60.0 * widget.participants.length,
                      width: screenwidth,
                      child: Column(
                        children: [
                          UserListView(
                            userres: widget.participants,
                            curruser: widget.curruser,
                            onTap: usernavigate,
                            screenwidth: screenwidth,
                            showcloutscore: false,
                            showrembutton: (widget.curruser.uid ==
                                    widget.event.hostdocid) &&
                                (joinedval != "Finished"),
                            removeUser: remuser,
                            presentparticipants:
                                widget.event.presentparticipants,
                            physics: NeverScrollableScrollPhysics(),
                            showsendbutton: false,
                          ),
                        ],
                      ),
                    )
              : Container(
                  width: screenwidth * 0.8,
                  height:
                      widget.event.participants.contains(widget.curruser.uid)
                          ? screenheight * 0.15 + 76
                          : screenheight * 0.2,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        widget.event.participants.contains(widget.curruser.uid)
                            ? UserListView(
                                userres: [widget.curruser],
                                curruser: widget.curruser,
                                onTap: usernavigate,
                                screenwidth: screenwidth,
                                showcloutscore: false,
                                showrembutton: (widget.curruser.uid ==
                                        widget.event.hostdocid) &&
                                    (joinedval != "Finished"),
                                removeUser: remuser,
                                presentparticipants:
                                    widget.event.presentparticipants,
                                physics: NeverScrollableScrollPhysics(),
                                toppadding: false,
                                showsendbutton: false,
                              )
                            : Container(),
                        widget.event.participants.contains(widget.curruser.uid)
                            ? Container()
                            : SizedBox(
                                height: screenheight * 0.05,
                              ),
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
                          textScaleFactor: 1.0,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(
                          height: screenheight * 0.03,
                        ),
                      ]),
                ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          InkWell(
              onTap: () async {
                buttonpressed ? null : interactevent(context);
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
