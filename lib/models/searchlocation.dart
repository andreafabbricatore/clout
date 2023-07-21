import 'package:clout/defs/location.dart';
import 'package:clout/services/logic.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchLocation extends StatefulWidget {
  SearchLocation(
      {Key? key,
      required this.locationchosen,
      required this.startlocation,
      required this.curruserLatLng})
      : super(key: key);
  bool locationchosen;
  AppLocation startlocation;
  List curruserLatLng;
  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  TextEditingController searchcontroller = TextEditingController();
  String accessToken = dotenv.get('GOOGLE_MAPS_TOKEN');
  Dio _dio = Dio();
  List<AppLocation> res = [];
  late AppLocation chosenLocation;
  List LatLngs = [];
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  applogic logic = applogic();
  GoogleMapController? mapController;

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
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(latlang, 17.0));
  }

  Widget _listviewitem(AppLocation location, int index, int length) {
    BorderRadius border = BorderRadius.zero;
    if (index == 0 && length == 1) {
      border = const BorderRadius.all(Radius.circular(10));
    } else if (index == 0) {
      border = const BorderRadius.only(
          topLeft: Radius.circular(10), topRight: Radius.circular(10));
    } else if (index == (length - 1)) {
      border = const BorderRadius.only(
          bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10));
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: border,
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16.0, 8.0, 0),
        child: InkWell(
          onTap: () async {
            String url =
                'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.center[0]},${location.center[1]}&result_type=country&key=AIzaSyAR9bmRxpCYai5b2k6AKtc4f7Es9w1307w';
            url = Uri.parse(url).toString();
            _dio.options.contentType = Headers.jsonContentType;
            final responseData = await _dio.get(url);
            String country = responseData.data['results'][0]
                    ['address_components'][0]['long_name']
                .toString()
                .toLowerCase();
            setState(() {
              widget.locationchosen = true;
              chosenLocation = AppLocation(
                  address: location.address,
                  city: location.city,
                  country: country,
                  center: location.center);
            });
            _addMarker(LatLng(location.center[0], location.center[1]));
            searchcontroller.clear();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.address,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      location.city,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void setup() async {
    setState(() {
      LatLngs = widget.curruserLatLng;
      chosenLocation = widget.startlocation;
    });
    if (widget.locationchosen) {
      await _addMarker(
          LatLng(chosenLocation.center[0], chosenLocation.center[1]));
    }
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Search Locations Around You",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context, chosenLocation);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      body: SizedBox(
        height: screenheight,
        width: screenwidth,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Stack(children: [
            GoogleMap(
              //Map widget from google_maps_flutter package
              myLocationButtonEnabled: false,
              zoomGesturesEnabled: true, //enable Zoom in, out on map
              initialCameraPosition: !widget.locationchosen
                  ? CameraPosition(
                      //innital position in map
                      target: LatLng(LatLngs[0], LatLngs[1]), //initial position
                      zoom: 14.0, //initial zoom level
                    )
                  : CameraPosition(
                      target: LatLng(widget.startlocation.center[0],
                          widget.startlocation.center[1]),
                      zoom: 14),
              mapType: MapType.normal, //map type
              markers: Set<Marker>.of(markers.values),
              onMapCreated: (controller) {
                //method called when map is created
                setState(() {
                  mapController = controller;
                });
              },
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
                  child: TextField(
                    controller: searchcontroller,
                    onChanged: (String searchquery) async {
                      searchquery.replaceAll(" ", "%20");
                      String url =
                          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${LatLngs[0]},${LatLngs[1]}&radius=15000&keyword=$searchquery&key=AIzaSyAR9bmRxpCYai5b2k6AKtc4f7Es9w1307w';
                      //String url =
                      //    'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchquery&inputtype=textquery&key=AIzaSyAR9bmRxpCYai5b2k6AKtc4f7Es9w1307w';
                      url = Uri.parse(url).toString();
                      try {
                        _dio.options.contentType = Headers.jsonContentType;
                        final responseData = await _dio.get(url);
                        List<AppLocation> response =
                            (responseData.data['results'] as List)
                                .map((e) => AppLocation(
                                        address: e['name'],
                                        city: e['vicinity']
                                            .toString()
                                            .split(", ")
                                            .last,
                                        country: "",
                                        center: [
                                          e['geometry']['location']['lat'],
                                          e['geometry']['location']['lng']
                                        ]))
                                .toList();
                        setState(() {
                          res = response;
                        });
                      } catch (e) {
                        logic.displayErrorSnackBar("Could not search", context);
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search Location',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.all(20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.white, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                  ),
                ),
                searchcontroller.text.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            shrinkWrap: true,
                            itemCount: res.length,
                            itemBuilder: (_, index) {
                              return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 0),
                                  child: _listviewitem(
                                      res[index], index, res.length));
                            }),
                      )
                    : Container(),
              ],
            ),
            widget.locationchosen
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context, chosenLocation);
                        },
                        child: SizedBox(
                            height: 50,
                            width: screenwidth * 0.5,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: const Center(
                                  child: Text(
                                "Choose Location",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              )),
                            )),
                      ),
                    ),
                  )
                : Container()
          ]),
        ),
      ),
    );
  }
}
