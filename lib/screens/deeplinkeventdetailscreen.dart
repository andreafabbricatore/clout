import 'package:clout/components/event.dart';
import 'package:clout/components/user.dart';
import 'package:clout/components/userlistview.dart';
import 'package:clout/screens/editeventscreen.dart';
import 'package:clout/screens/loading.dart';
import 'package:clout/screens/profilescreen.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:latlong2/latlong.dart';

class DeepLinkEventDetailScreen extends StatefulWidget {
  DeepLinkEventDetailScreen({
    super.key,
    required this.event,
    required this.curruser,
    required this.participants,
  });
  Event event;
  AppUser curruser;
  List<AppUser> participants;
  @override
  State<DeepLinkEventDetailScreen> createState() =>
      _DeepLinkEventDetailScreenState();
}

class _DeepLinkEventDetailScreenState extends State<DeepLinkEventDetailScreen> {
  db_conn db = db_conn();
  bool joined = false;
  String joinedval = "Join";
  bool buttonpressed = false;

  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> updatecurruser() async {
    try {
      AppUser updateduser = await db.getUserFromDocID(widget.curruser.docid);
      setState(() {
        widget.curruser = updateduser;
      });
    } catch (e) {
      displayErrorSnackBar("Could not update user");
    }
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
        for (String x in widget.event.participants) await db.getUserFromDocID(x)
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

  Future interactfav(Event event) async {
    try {
      if (widget.curruser.favorites.contains(event.docid)) {
        await db.remFromFav(widget.curruser.docid, event.docid);
      } else {
        await db.addToFav(widget.curruser.docid, event.docid);
      }
    } catch (e) {
      displayErrorSnackBar("Could not update favorites");
    } finally {
      updatecurruser();
    }
  }

  @override
  void initState() {
    checkifjoined();
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
                    interests: const [],
                  )));
    }

    return Scaffold(
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
            color: Color.fromARGB(255, 255, 48, 117),
          ),
        ),
        actions: [
          widget.curruser.username == widget.event.host
              ? GestureDetector(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => EditEventScreen(
                            curruser: widget.curruser,
                            allowbackarrow: true,
                            event: widget.event),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                    child: Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
                  ),
                )
              : Container(),
          GestureDetector(
            onTap: () async {
              await interactfav(widget.event);
              updatecurruser();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
              child: Icon(
                widget.curruser.favorites.contains(widget.event.docid)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: Colors.black,
              ),
            ),
          )
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
                fontSize: 40,
                color: Colors.black,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: screenheight * 0.005,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.event.interest,
                style: const TextStyle(
                    fontSize: 25,
                    color: Color.fromARGB(255, 255, 48, 117),
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () async {
                  try {
                    String hostdocid =
                        await db.getUserDocIDfromUsername(widget.event.host);
                    AppUser eventhost = await db.getUserFromDocID(hostdocid);
                    usernavigate(eventhost, 0);
                  } catch (e) {
                    displayErrorSnackBar("Could not retrieve host information");
                  }
                },
                child: Text(
                  "@${widget.event.host}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 255, 48, 117),
                    fontFamily: "Poppins",
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
                fontSize: 15,
                color: Colors.black,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold),
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
                FlutterMap(
                  options: MapOptions(
                    center: LatLng(widget.event.lat, widget.event.lng),
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
                          point: LatLng(widget.event.lat, widget.event.lng),
                          builder: ((context) => const Icon(
                                Icons.location_pin,
                                color: Color.fromARGB(255, 255, 48, 117),
                                size: 18,
                              )))
                    ])
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: SizedBox(
                    height: screenheight * 0.05,
                    width: screenheight * 0.05,
                    child: FloatingActionButton(
                      backgroundColor: const Color.fromARGB(255, 255, 48, 117),
                      child: const Center(child: Icon(Icons.map_rounded)),
                      onPressed: () {
                        MapsLauncher.launchQuery(
                            "${widget.event.lat},${widget.event.lng}");
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Text(
            widget.event.description,
            style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Text(
            widget.event.participants.length != widget.event.maxparticipants
                ? "${widget.event.participants.length}/${widget.event.maxparticipants} participants"
                : "Participant number reached",
            style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold),
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
            child: SizedBox(
                height: 50,
                width: screenwidth * 0.5,
                child: Container(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 48, 117),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Center(
                      child: Text(
                    joinedval,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  )),
                )),
          )
        ]),
      ),
    );
  }
}
