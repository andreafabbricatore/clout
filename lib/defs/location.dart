class AppLocation {
  String address;
  String city;
  String country;
  List center;

  AppLocation(
      {required this.address,
      required this.city,
      required this.country,
      required this.center});

  factory AppLocation.fromJson(dynamic json) {
    List splitaddress = json['place_name'].toString().split(', ');
    return AppLocation(
        address: splitaddress[0],
        city: splitaddress[splitaddress.length - 2],
        country: splitaddress[splitaddress.length - 1],
        center: json['center'] as List);
  }
}
