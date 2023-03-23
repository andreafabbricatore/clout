class Event {
  String title;
  String description;
  String interest;
  String image;
  String country;
  String address;
  List city;
  double lat;
  double lng;
  DateTime datetime;
  int maxparticipants;
  String host;
  String hostdocid;
  String docid;
  String chatid;
  bool isinviteonly;
  bool customimage;

  Event(
      {required this.title,
      required this.description,
      required this.interest,
      required this.image,
      required this.address,
      required this.country,
      required this.city,
      required this.host,
      required this.hostdocid,
      required this.maxparticipants,
      required this.datetime,
      required this.docid,
      required this.lat,
      required this.lng,
      required this.chatid,
      required this.isinviteonly,
      required this.customimage});

  factory Event.fromJson(dynamic json, String docid) {
    return Event(
        title: json['title'],
        description: json['description'],
        interest: json['interest'],
        image: json['image'],
        address: json['address'],
        country: json['country'],
        city: json['city'] as List,
        host: json['host'],
        hostdocid: json['hostdocid'],
        maxparticipants: json['maxparticipants'] as int,
        datetime: json['time'].toDate(),
        docid: docid,
        lat: json['lat'],
        lng: json['lng'],
        chatid: json['chatid'],
        isinviteonly: json['isinviteonly'] as bool,
        customimage: json['custom_image'] as bool);
  }
}
