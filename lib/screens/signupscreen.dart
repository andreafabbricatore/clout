import 'dart:io';
import 'package:clout/components/datatextfield.dart';
import 'package:clout/components/datetextfield.dart';
import 'package:clout/components/user.dart';
import 'package:clout/screens/loading.dart';
import 'package:clout/screens/mainscreen.dart';
import 'package:clout/services/auth.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
  String? error = "";
  Color errorcolor = Colors.white;
  AppUser curruser = AppUser(
      username: "",
      uid: "",
      pfp_url: "",
      nationality: "",
      joined_events: [],
      hosted_events: [],
      interests: [],
      gender: "",
      fullname: "",
      email: "",
      birthday: "",
      followers: [],
      following: [],
      clout: 0);
  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "CLOUT",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 48, 117))),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: screenheight * 0.2,
            ),
            Center(
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
                  decoration: InputDecoration(
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
            Center(
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
                  decoration: InputDecoration(
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
                    error = "";
                    errorcolor = Colors.white;
                  });
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
                  setState(() {
                    error = "Invalid email and/or password";
                    errorcolor = Colors.red;
                  });
                }
              },
              child: SizedBox(
                  height: 50,
                  width: screenwidth * 0.5,
                  child: Container(
                    child: Center(
                        child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 48, 117),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  )),
            ),
            SizedBox(height: screenheight * 0.02),
            Center(
              child: Text(
                error.toString(),
                style: TextStyle(color: errorcolor),
              ),
            )
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
  String error = "";
  Color errorcolor = Colors.white;
  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
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
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: screenheight * 0.15),
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
                            color: Color.fromARGB(255, 255, 48, 117),
                            child: Icon(
                              Icons.account_circle_outlined,
                              color: Colors.white,
                              size: screenheight * 0.18,
                            ),
                            height: screenheight * 0.2,
                            width: screenheight * 0.2),
                  ))),
          SizedBox(height: screenheight * 0.05),
          textdatafield(screenwidth, "Full Name", fullnamecontroller),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Center(
            child: Text(
              error,
              style: TextStyle(color: errorcolor),
            ),
          )
        ],
      )),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () async {
            if (imagepath.toString().isNotEmpty &&
                fullnamecontroller.text.isNotEmpty) {
              setState(() {
                error = "";
                errorcolor = Colors.white;
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
              setState(() {
                error = "Invalid email and/or password";
                errorcolor = Colors.red;
              });
            }
          },
          backgroundColor: Color.fromARGB(255, 255, 48, 117),
          child: Icon(
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
  String error = "";
  Color errorcolor = Colors.white;
  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
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
          Center(
            child: Text(
              error,
              style: TextStyle(color: errorcolor),
            ),
          )
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
                error = "Username already taken";
                errorcolor = Colors.red;
              });
            } else if (usernamecontroller.text.isEmpty) {
              setState(() {
                error = "Invalid Username";
                errorcolor = Colors.red;
              });
            } else {
              setState(() {
                error = "";
                errorcolor = Colors.white;
                widget.curruser.username = usernamecontroller.text.trim();
              });
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
          },
          backgroundColor: Color.fromARGB(255, 255, 48, 117),
          child: Icon(
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
  final birthdaycontroller = TextEditingController();
  String gender = 'Male';
  String nationality = 'Australia';
  db_conn db = db_conn();
  String error = "";
  Color errorcolor = Colors.white;
  var maskFormatter = new MaskTextInputFormatter(
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
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
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
      ),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: screenheight * 0.2),
          SizedBox(
            width: screenwidth * 0.6,
            child: DropdownButtonFormField(
              decoration: InputDecoration(
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
              decoration: InputDecoration(
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
          datetextfield(
              screenwidth, "dd/mm/yyyy", birthdaycontroller, maskFormatter),
          SizedBox(
            height: screenheight * 0.02,
          ),
          Center(
            child: Text(
              error,
              style: TextStyle(color: errorcolor),
            ),
          ),
        ],
      )),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () async {
            if (birthdaycontroller.text.isNotEmpty) {
              setState(() {
                error = "";
                errorcolor = Colors.white;
                widget.curruser.birthday = birthdaycontroller.text;
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
              setState(() {
                error = "Please fill all fields";
                errorcolor = Colors.red;
              });
            }
          },
          backgroundColor: Color.fromARGB(255, 255, 48, 117),
          child: Icon(
            Icons.arrow_circle_right_outlined,
            size: 60,
          ),
        ),
      ),
    );
  }
}

class InterestScreen extends StatefulWidget {
  InterestScreen(
      {Key? key,
      required this.curruser,
      required this.imagepath,
      required this.psw})
      : super(key: key);
  AppUser curruser;
  String psw;
  var imagepath;
  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  List interests = [
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
  List<Color> textcolors = List.filled(10, Color.fromARGB(255, 255, 48, 117));
  List<Color> cardcolors = List.filled(10, Colors.white);
  List selectedinterests = [];
  db_conn db = db_conn();
  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Interests",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 48, 117),
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
        bottom: PreferredSize(
          child: Text(
            "Choose at least 3",
            style: TextStyle(color: Color.fromARGB(255, 255, 48, 117)),
          ),
          preferredSize: Size.zero,
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: GridView.builder(
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemCount: interests.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                if (textcolors[index] == Colors.white) {
                  setState(() {
                    cardcolors[index] = Colors.white;
                    textcolors[index] = Color.fromARGB(255, 255, 48, 117);
                  });
                  selectedinterests
                      .removeWhere((item) => item == interests[index]);
                } else {
                  setState(() {
                    cardcolors[index] = Color.fromARGB(255, 255, 48, 117);
                    textcolors[index] = Colors.white;
                  });
                  selectedinterests.add(interests[index]);
                }
              },
              child: Card(
                color: cardcolors[index],
                shadowColor: Colors.black,
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Color.fromARGB(255, 255, 48, 117), width: 1.0),
                    borderRadius: BorderRadius.circular(40)),
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 10, right: 10),
                  child: Center(
                    child: Text(
                      interests[index],
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textcolors[index]),
                    ),
                  ),
                ),
              ),
            );
          }),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () async {
            if (selectedinterests.length >= 3) {
              setState(() {
                widget.curruser.interests = selectedinterests;
              });

              await context
                  .read<AuthenticationService>()
                  .signUp(email: widget.curruser.email, password: widget.psw);
              String uid =
                  context.read<AuthenticationService>().getuid().toString();
              await db.createuserinstance(widget.curruser.email, uid);
              await db.changepfp(widget.imagepath, uid);
              await db.changeusername(widget.curruser.username, uid);
              await db.changeattribute(
                  'fullname', widget.curruser.fullname, uid);
              await db.changeattribute('gender', widget.curruser.gender, uid);
              await db.changeattribute(
                  'nationality', widget.curruser.nationality, uid);
              await db.changeattribute(
                  'birthday', widget.curruser.birthday, uid);
              await db.changeinterests(
                  'interests', widget.curruser.interests, uid);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      LoadingScreen(uid: uid, signup: true),
                ),
              );
            }
          },
          backgroundColor: Color.fromARGB(255, 255, 48, 117),
          child: Icon(
            Icons.arrow_circle_right_outlined,
            size: 60,
          ),
        ),
      ),
    );
  }
}
