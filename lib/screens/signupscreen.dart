import 'dart:io';
import 'package:clout/components/datatextfield.dart';
import 'package:clout/components/loadingoverlay.dart';
import 'package:clout/components/user.dart';
import 'package:clout/main.dart';
import 'package:clout/services/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final pswController = TextEditingController();
  db_conn db = db_conn();
  AppUser curruser = AppUser(
      username: "",
      uid: "",
      pfpurl: "",
      nationality: "",
      joinedEvents: [],
      hostedEvents: [],
      interests: [],
      gender: "",
      fullname: "",
      email: "",
      birthday: DateTime(0, 0, 0),
      followers: [],
      following: [],
      favorites: [],
      docid: "",
      clout: 0,
      bio: "");

  void displayErrorSnackBar(String error) async {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    await Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Clout",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontFamily: "Kristi",
              fontWeight: FontWeight.w500,
              fontSize: 50),
          textScaleFactor: 1.0,
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 48, 117))),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: screenheight * 0.2,
            ),
            const Center(
                child: Text(
              "Email Address",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 20),
            )),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenwidth * 0.2),
                child: TextField(
                  decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 48, 117))),
                      hintText: 'e.g. timcook@gmail.com',
                      hintStyle: TextStyle(color: Color.fromARGB(39, 0, 0, 0))),
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  enableSuggestions: false,
                  autocorrect: false,
                ),
              ),
            ),
            SizedBox(height: screenheight * 0.02),
            const Center(
                child: Text(
              "Password",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 20),
            )),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenwidth * 0.2),
                child: TextField(
                  decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 255, 48, 117))),
                      hintText: 'e.g. supersecret',
                      hintStyle: TextStyle(color: Color.fromARGB(39, 0, 0, 0))),
                  controller: pswController,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  textAlign: TextAlign.center,
                  enableSuggestions: false,
                  autocorrect: false,
                ),
              ),
            ),
            SizedBox(height: screenheight * 0.02),
            InkWell(
              onTap: () async {
                if (emailController.text.isNotEmpty &&
                    pswController.text.isNotEmpty) {
                  setState(() {
                    curruser.email = emailController.text.trim();
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => PicandNameScreen(
                          curruser: curruser, psw: pswController.text),
                    ),
                  );
                } else {
                  displayErrorSnackBar("Invalid email and/or password");
                }
              },
              child: SizedBox(
                  height: 50,
                  width: screenwidth * 0.5,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 48, 117),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: const Center(
                        child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
                  )),
            ),
            SizedBox(height: screenheight * 0.02),
          ],
        ),
      ),
    );
  }
}

class PicandNameScreen extends StatefulWidget {
  PicandNameScreen({super.key, required this.curruser, required this.psw});
  AppUser curruser;
  String psw;
  @override
  State<PicandNameScreen> createState() => _PicandNameScreenState();
}

class _PicandNameScreenState extends State<PicandNameScreen> {
  final fullnamecontroller = TextEditingController();
  ImagePicker picker = ImagePicker();
  var imagepath;
  db_conn db = db_conn();
  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    //print(imagepath == null);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Who are you",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Row(
              children: [
                Container(
                  width: screenwidth * 0.25,
                  color: const Color.fromARGB(255, 255, 48, 117),
                  height: 4.0,
                ),
                SizedBox(
                  width: screenwidth * 0.75,
                  height: 4.0,
                )
              ],
            )),
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: screenheight * 0.1),
          const Center(
            child: Text(
              "Upload Profile Picture",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              textScaleFactor: 1.0,
            ),
          ),
          SizedBox(
            height: screenheight * 0.03,
          ),
          Center(
              child: InkWell(
                  onTap: () async {
                    XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() {
                        imagepath = File(image.path);
                      });
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: imagepath != null
                        ? Image.file(
                            imagepath,
                            fit: BoxFit.cover,
                            height: screenheight * 0.2,
                            width: screenheight * 0.2,
                          )
                        : Container(
                            color: const Color.fromARGB(255, 255, 48, 117),
                            height: screenheight * 0.2,
                            width: screenheight * 0.2,
                            child: Icon(
                              Icons.upload_rounded,
                              color: Colors.white,
                              size: screenheight * 0.18,
                            ),
                          ),
                  ))),
          SizedBox(height: screenheight * 0.05),
          textdatafield(screenwidth, "Full Name", fullnamecontroller),
          SizedBox(
            height: screenheight * 0.02,
          ),
        ],
      )),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () async {
            if (imagepath != null && fullnamecontroller.text.isNotEmpty) {
              setState(() {
                widget.curruser.fullname = fullnamecontroller.text.trim();
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => UsernameScreen(
                      curruser: widget.curruser,
                      imagepath: imagepath,
                      psw: widget.psw),
                ),
              );
            } else {
              displayErrorSnackBar("Error with profile picture or full name");
            }
          },
          backgroundColor: const Color.fromARGB(255, 255, 48, 117),
          child: const Icon(
            Icons.arrow_circle_right_outlined,
            size: 60,
          ),
        ),
      ),
    );
  }
}

class UsernameScreen extends StatefulWidget {
  UsernameScreen(
      {Key? key,
      required this.curruser,
      required this.imagepath,
      required this.psw})
      : super(key: key);
  AppUser curruser;
  var imagepath;
  String psw;
  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final usernamecontroller = TextEditingController();
  db_conn db = db_conn();
  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void gotomiscscreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => MiscScreen(
            curruser: widget.curruser,
            imagepath: widget.imagepath,
            psw: widget.psw),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Username",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Row(
              children: [
                Container(
                  width: screenwidth * 0.5,
                  color: const Color.fromARGB(255, 255, 48, 117),
                  height: 4.0,
                ),
                SizedBox(
                  width: screenwidth * 0.5,
                  height: 4.0,
                )
              ],
            )),
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: screenheight * 0.3),
          textdatafield(screenwidth, "Username", usernamecontroller),
          SizedBox(
            height: screenheight * 0.02,
          ),
        ],
      )),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () async {
            bool uniqueness = await db.usernameUnique(usernamecontroller.text);
            if (!uniqueness && usernamecontroller.text.isNotEmpty) {
              setState(() {
                displayErrorSnackBar("Username already taken");
              });
            } else if (usernamecontroller.text.isEmpty) {
              displayErrorSnackBar("Invalid Username");
            } else if (!RegExp(r'^[a-zA-Z0-9&%=]+$')
                .hasMatch(usernamecontroller.text.trim())) {
              displayErrorSnackBar("Please only enter alphanumeric characters");
            } else {
              setState(() {
                widget.curruser.username =
                    usernamecontroller.text.trim().toLowerCase();
              });
              gotomiscscreen();
            }
          },
          backgroundColor: const Color.fromARGB(255, 255, 48, 117),
          child: const Icon(
            Icons.arrow_circle_right_outlined,
            size: 60,
          ),
        ),
      ),
    );
  }
}

class MiscScreen extends StatefulWidget {
  MiscScreen(
      {super.key,
      required this.curruser,
      required this.imagepath,
      required this.psw});
  AppUser curruser;
  var imagepath;
  String psw;
  @override
  State<MiscScreen> createState() => _MiscScreenState();
}

class _MiscScreenState extends State<MiscScreen> {
  DateTime birthday = DateTime(0, 0, 0);
  String gender = 'Male';
  String nationality = 'Australia';
  db_conn db = db_conn();
  List allinterests = [
    "Sports",
    "Nature",
    "Music",
    "Dance",
    "Movies",
    "Acting",
    "Singing",
    "Drinking",
    "Food",
    "Art"
  ];
  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  var maskFormatter = MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  var genders = ['Male', 'Female', 'Non-Binary'];
  var nations = [
    'Afghanistan',
    'Aland Islands',
    'Albania',
    'Algeria',
    'American Samoa',
    'Andorra',
    'Angola',
    'Anguilla',
    'Antarctica',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Aruba',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bermuda',
    'Bhutan',
    'Bolivia, Plurinational State of',
    'Bonaire, Sint Eustatius and Saba',
    'Bosnia and Herzegovina',
    'Botswana',
    'Bouvet Island',
    'Brazil',
    'British Indian Ocean Territory',
    'Brunei Darussalam',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Cape Verde',
    'Cayman Islands',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Christmas Island',
    'Cocos (Keeling) Islands',
    'Colombia',
    'Comoros',
    'Congo',
    'Congo, The Democratic Republic of the',
    'Cook Islands',
    'Costa Rica',
    "Côte d'Ivoire",
    'Croatia',
    'Cuba',
    'Curaçao',
    'Cyprus',
    'Czech Republic',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Ethiopia',
    'Falkland Islands (Malvinas)',
    'Faroe Islands',
    'Fiji',
    'Finland',
    'France',
    'French Guiana',
    'French Polynesia',
    'French Southern Territories',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Gibraltar',
    'Greece',
    'Greenland',
    'Grenada',
    'Guadeloupe',
    'Guam',
    'Guatemala',
    'Guernsey',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Heard Island and McDonald Islands',
    'Holy See (Vatican City State)',
    'Honduras',
    'Hong Kong',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran, Islamic Republic of',
    'Iraq',
    'Ireland',
    'Isle of Man',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jersey',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    "Korea, Democratic People's Republic of",
    'Korea, Republic of',
    'Kuwait',
    'Kyrgyzstan',
    "Lao People's Democratic Republic",
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Macao',
    'Macedonia, Republic of',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Martinique',
    'Mauritania',
    'Mauritius',
    'Mayotte',
    'Mexico',
    'Micronesia, Federated States of',
    'Moldova, Republic of',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Montserrat',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Caledonia',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'Niue',
    'Norfolk Island',
    'Northern Mariana Islands',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Palestinian Territory, Occupied',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Pitcairn',
    'Poland',
    'Portugal',
    'Puerto Rico',
    'Qatar',
    'Réunion',
    'Romania',
    'Russian Federation',
    'Rwanda',
    'Saint Barthélemy',
    'Saint Helena, Ascension and Tristan da Cunha',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Martin (French part)',
    'Saint Pierre and Miquelon',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Sint Maarten (Dutch part)',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Georgia and the South Sandwich Islands',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'South Sudan',
    'Svalbard and Jan Mayen',
    'Swaziland',
    'Sweden',
    'Switzerland',
    'Syrian Arab Republic',
    'Taiwan, Province of China',
    'Tajikistan',
    'Tanzania, United Republic of',
    'Thailand',
    'Timor-Leste',
    'Togo',
    'Tokelau',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Turks and Caicos Islands',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'United States Minor Outlying Islands',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Venezuela, Bolivarian Republic of',
    'Viet Nam',
    'Virgin Islands, British',
    'Virgin Islands, U.S.',
    'Wallis and Futuna',
    'Yemen',
    'Zambia',
    'Zimbabwe'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Other info",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Row(
              children: [
                Container(
                  width: screenwidth * 0.75,
                  color: const Color.fromARGB(255, 255, 48, 117),
                  height: 4.0,
                ),
                SizedBox(
                  width: screenwidth * 0.25,
                  height: 4.0,
                )
              ],
            )),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: screenheight * 0.2),
            SizedBox(
              width: screenwidth * 0.6,
              child: DropdownButtonFormField(
                decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 255, 48, 117)))),
                value: gender,
                onChanged: (String? newValue) {
                  setState(() {
                    gender = newValue!;
                  });
                },
                onSaved: (String? newValue) {
                  setState(() {
                    gender = newValue!;
                  });
                },
                items: genders.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: screenheight * 0.02),
            SizedBox(
              width: screenwidth * 0.6,
              child: DropdownButtonFormField(
                decoration: const InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 255, 48, 117)))),
                value: nationality,
                onChanged: (String? newValue) {
                  setState(() {
                    nationality = newValue!;
                  });
                },
                onSaved: (String? newValue) {
                  setState(() {
                    nationality = newValue!;
                  });
                },
                items: nations.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                isExpanded: true,
              ),
            ),
            SizedBox(height: screenheight * 0.02),
            InkWell(
              onTap: () {
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(1950, 1, 1),
                    maxTime: DateTime(
                        DateTime.now().year - 16, DateTime.december, 31),
                    onChanged: (date) {}, onConfirm: (date) {
                  setState(() {
                    birthday = date;
                  });
                  //print(birthday);
                }, currentTime: DateTime.now());
              },
              child: Container(
                height: screenwidth * 0.13,
                width: screenwidth * 0.6,
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black)),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    birthday == DateTime(0, 0, 0)
                        ? "Enter birthday"
                        : DateFormat('dd MMMM yyyy').format(birthday),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Icon(
                    Icons.date_range,
                    size: 15,
                  )
                ]),
              ),
            ),
            SizedBox(
              height: screenheight * 0.02,
            ),
          ],
        ),
      )),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            if (birthday != DateTime(0, 0, 0)) {
              setState(() {
                widget.curruser.birthday = birthday;
                widget.curruser.nationality = nationality;
                widget.curruser.gender = gender;
              });
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => InterestScreen(
                      curruser: widget.curruser,
                      imagepath: widget.imagepath,
                      psw: widget.psw),
                ),
              );
            } else {
              displayErrorSnackBar("Please fill all fields correctly");
            }
          },
          backgroundColor: const Color.fromARGB(255, 255, 48, 117),
          child: const Icon(
            Icons.arrow_circle_right_outlined,
            size: 60,
          ),
        ),
      ),
    );
  }
}

class InterestScreen extends StatefulWidget {
  InterestScreen({
    Key? key,
    required this.curruser,
    required this.imagepath,
    required this.psw,
  }) : super(key: key);
  AppUser curruser;
  String psw;
  var imagepath;
  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  List allinterests = [
    "Sports",
    "Nature",
    "Music",
    "Dance",
    "Movies",
    "Acting",
    "Singing",
    "Drinking",
    "Food",
    "Art"
  ];
  List<Color> textcolors =
      List.filled(10, const Color.fromARGB(255, 255, 48, 117));
  List<Color> cardcolors = List.filled(10, Colors.white);
  List selectedinterests = [];
  db_conn db = db_conn();
  bool buttonpressed = false;
  var compressedimgpath;

  Future<File> CompressAndGetFile(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
      var result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 5,
      );

      //print(file.lengthSync());
      //print(result!.lengthSync());

      return result!;
    } catch (e) {
      throw Exception();
    }
  }

  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void donesignup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => AuthenticationWrapper(),
          fullscreenDialog: true),
    );
  }

  Widget _listviewitem(String interest) {
    return GestureDetector(
      onTap: () {
        if (selectedinterests.contains(interest)) {
          setState(() {
            selectedinterests.removeWhere((element) => element == interest);
          });
        } else {
          setState(() {
            selectedinterests.add(interest);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
              width: selectedinterests.contains(interest) ? 2 : 0,
              color: selectedinterests.contains(interest)
                  ? const Color.fromARGB(255, 255, 48, 117)
                  : Colors.black),
          image: DecorationImage(
              opacity: selectedinterests.contains(interest) ? 0.8 : 1,
              image: AssetImage(
                "assets/images/interestbanners/${interest.toLowerCase()}.jpeg",
              ),
              fit: BoxFit.cover),
        ),
        child: Center(
            child: Text(
          interest,
          style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: selectedinterests.contains(interest)
                  ? const Color.fromARGB(255, 255, 48, 117)
                  : Colors.white),
          textScaleFactor: 1.0,
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    return buttonpressed
        ? LoadingOverlay(
            text: "Creating your account...",
            color: const Color.fromARGB(255, 255, 48, 117))
        : Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                "What are your interests?",
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 48, 117),
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(4.0),
                  child: Row(
                    children: [
                      Container(
                        width: screenwidth,
                        color: const Color.fromARGB(255, 255, 48, 117),
                        height: 4.0,
                      ),
                    ],
                  )),
              backgroundColor: Colors.white,
              shadowColor: Colors.white,
              elevation: 0.0,
              automaticallyImplyLeading: false,
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                      shrinkWrap: true,
                      itemCount: allinterests.length,
                      itemBuilder: ((context, index) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: _listviewitem(allinterests[index]),
                        );
                      }),
                    ),
                  )
                ],
              ),
            ),
            floatingActionButton: SizedBox(
              height: 70,
              width: 70,
              child: FloatingActionButton(
                onPressed: buttonpressed
                    ? null
                    : () async {
                        setState(() {
                          buttonpressed = true;
                        });
                        try {
                          if (selectedinterests.length >= 3) {
                            setState(() {
                              widget.curruser.interests = selectedinterests;
                            });

                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: widget.curruser.email,
                                    password: widget.psw);
                            String uid = FirebaseAuth.instance.currentUser!.uid;
                            await db.createuserinstance(
                                widget.curruser.email, uid);
                            compressedimgpath =
                                await CompressAndGetFile(widget.imagepath);
                            await db.changepfp(compressedimgpath, uid);
                            await db.changeusername(
                                widget.curruser.username, uid);
                            await db.changeattribute(
                                'fullname', widget.curruser.fullname, uid);
                            await db.changeattribute(
                                'gender', widget.curruser.gender, uid);
                            await db.changeattribute('nationality',
                                widget.curruser.nationality, uid);
                            await db.changebirthday(
                                widget.curruser.birthday, uid);
                            await db.changeinterests(
                                'interests', widget.curruser.interests, uid);

                            donesignup();
                          } else {
                            displayErrorSnackBar("Choose at least 3 interests");
                            setState(() {
                              buttonpressed = false;
                            });
                          }
                        } catch (e) {
                          displayErrorSnackBar("Could not create user");
                          setState(() {
                            buttonpressed = false;
                          });
                        }
                      },
                backgroundColor: const Color.fromARGB(255, 255, 48, 117),
                child: const Icon(
                  Icons.arrow_circle_right_outlined,
                  size: 60,
                ),
              ),
            ),
          );
  }
}
