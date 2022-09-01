import 'package:clout/components/location.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchLocation extends StatefulWidget {
  SearchLocation({Key? key}) : super(key: key);

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  TextEditingController searchcontroller = TextEditingController();
  String accessToken = dotenv.get('MAPBOX_ACCESS_TOKEN');
  Dio _dio = Dio();
  List<AppLocation> res = [];
  AppLocation chosenLocation =
      AppLocation(address: "", city: "", country: "", center: [0.0, 0.0]);

  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _listviewitem(AppLocation location) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16.0, 8.0, 0),
      child: InkWell(
        onTap: () {
          setState(() {
            chosenLocation = location;
          });
          Navigator.pop(context, chosenLocation);
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
                    "${location.city}, ${location.country}",
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Search Location",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context, chosenLocation);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 255, 48, 117),
          ),
        ),
      ),
      body: SizedBox(
        height: screenheight,
        width: screenwidth,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            TextField(
              controller: searchcontroller,
              onChanged: (String searchquery) async {
                String url =
                    'https://api.mapbox.com/geocoding/v5/mapbox.places/$searchquery.json?limit=10&types=poi%2Caddress&access_token=$accessToken';
                url = Uri.parse(url).toString();
                //print(url);
                try {
                  _dio.options.contentType = Headers.jsonContentType;
                  final responseData = await _dio.get(url);
                  List<AppLocation> response =
                      (responseData.data['features'] as List)
                          .map((e) => AppLocation.fromJson(e))
                          .toList();
                  setState(() {
                    res = response;
                  });
                } catch (e) {
                  displayErrorSnackBar("Could not search location");
                }
              },
              decoration: InputDecoration(
                  hintText: 'Search Location',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.all(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  )),
            ),
            Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 16, 0, 0),
                  shrinkWrap: true,
                  itemCount: res.length,
                  itemBuilder: (_, index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 5),
                        child: _listviewitem(res[index]));
                  }),
            )
          ]),
        ),
      ),
    );
  }
}
