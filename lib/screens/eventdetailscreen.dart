import 'package:clout/components/chat.dart';
import 'package:clout/components/event.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/chatroomscreen.dart';
import 'package:clout/screens/editeventscreen.dart';
import 'package:clout/screens/loading.dart';
import 'package:clout/screens/profilescreen.dart';

import 'package:clout/services/db.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart' as Maps;
import 'package:share_plus/share_plus.dart';

class EventDetailScreen extends StatefulWidget {
  EventDetailScreen(
      {super.key,
      required this.event,
      required this.curruser,
      required this.participants,
      required this.interactfav});
  Event event;
  AppUser curruser;
  List<AppUser> participants;
  final Function(Event event) interactfav;
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  db_conn db = db_conn();
  bool joined = false;
  String joinedval = "Join";
  bool buttonpressed = false;
  bool gotochatbuttonpressed = false;

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
    await Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (_) => ChatRoomScreen(
                  chatinfo: chat,
                  curruser: widget.curruser,
                )));
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
      List<AppUser> temp = [
        for (String x in widget.event.participants) await db.getUserFromUID(x)
      ];
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
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => LoadingScreen(
                    uid: widget.curruser.uid,
                  ),
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

  Future<String> createShareLink() async {
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://outwithclout.com/${widget.event.docid}"),
      uriPrefix: "https://outwithclout.page.link",
    );
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);
    return dynamicLink.toString();
  }

  @override
  void initState() {
    checkifjoined();
    _addMarker(LatLng(widget.event.lat, widget.event.lng));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    Future<void> usernavigate(AppUser user, int index) async {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (_) => ProfileScreen(
                    user: user,
                    curruser: widget.curruser,
                    visit: true,
                  )));
    }

    Future<void> remuser(AppUser user, int index) async {
      try {
        await db.removeparticipant(user, widget.event);
        updatescreen(widget.event.docid);
      } catch (e) {
        displayErrorSnackBar("Could not remove participant, please try again");
      }
    }

    void shareevent(String text) async {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        text,
        subject: "Join this event on Clout!",
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
              await widget.interactfav(widget.event);
              updatecurruser();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
              child: Icon(
                widget.curruser.favorites.contains(widget.event.docid)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                  backgroundColor: Colors.white,
                  context: context,
                  builder: (BuildContext context) {
                    return SizedBox(
                        height: screenheight * 0.3,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              20, screenheight * 0.01, 20, 20),
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
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        String link = await createShareLink();
                                        //print(link);
                                        String text =
                                            "Join ${widget.event.title} on Clout!\n\n$link";
                                        shareevent(text);
                                      },
                                      child: Container(
                                        height: screenheight * 0.1,
                                        width: screenwidth * 0.4,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20)),
                                        ),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.ios_share,
                                                  color: Colors.white,
                                                  size: 30),
                                              SizedBox(
                                                height: screenheight * 0.01,
                                              ),
                                              const Text(
                                                "Share Event",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white),
                                                textScaleFactor: 1.0,
                                              )
                                            ]),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: gotochatbuttonpressed
                                          ? null
                                          : () async {
                                              setState(() {
                                                gotochatbuttonpressed = true;
                                              });
                                              try {
                                                if (widget.event.participants
                                                    .contains(
                                                        widget.curruser.uid)) {
                                                  Chat chat =
                                                      await db.getChatfromDocId(
                                                          widget.event.chatid);
                                                  chatnavigate(chat);
                                                } else {
                                                  displayErrorSnackBar(
                                                      "Please join event first");
                                                }
                                              } catch (e) {
                                                displayErrorSnackBar(
                                                    "Could not display chat");
                                              }
                                              setState(() {
                                                gotochatbuttonpressed = false;
                                              });
                                            },
                                      child: Container(
                                        height: screenheight * 0.1,
                                        width: screenwidth * 0.4,
                                        decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(20))),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.chat_bubble_outline_rounded,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            SizedBox(
                                              height: screenheight * 0.01,
                                            ),
                                            const Text(
                                              "Go to Chat",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white),
                                              textScaleFactor: 1.0,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                              SizedBox(
                                height: screenheight * 0.02,
                              ),
                              GestureDetector(
                                onTap: widget.curruser.uid ==
                                        widget.event.hostdocid
                                    ? () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                EditEventScreen(
                                                    curruser: widget.curruser,
                                                    allowbackarrow: true,
                                                    event: widget.event),
                                          ),
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
                                  child: Center(
                                    child: Text(
                                      widget.curruser.uid ==
                                              widget.event.hostdocid
                                          ? "Edit Event"
                                          : "Report Event",
                                      style: const TextStyle(
                                          fontSize: 25, color: Colors.white),
                                      textScaleFactor: 1.0,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ));
                  });
            },
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 16.0, 0),
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
              Text(
                widget.event.interest,
                style: TextStyle(
                    fontSize: 25,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
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
                UserListView(
                  userres: widget.participants,
                  curruser: widget.curruser,
                  onTap: usernavigate,
                  screenwidth: screenwidth,
                  showcloutscore: false,
                  showrembutton:
                      (widget.curruser.uid == widget.event.hostdocid) &&
                          (joinedval != "Finished"),
                  removeUser: remuser,
                ),
              ],
            ),
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
                      width: screenwidth * 0.5,
                      color: Colors.white,
                      child: Text(
                        joinedval,
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).primaryColor),
                        textScaleFactor: 1.1,
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
