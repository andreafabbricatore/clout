import 'dart:io';

import 'package:clout/components/datatextfield.dart';
import 'package:clout/components/loadingoverlay.dart';
import 'package:clout/components/updateinterests.dart';
import 'package:clout/components/user.dart';
import 'package:clout/services/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen(
      {super.key, required this.curruser, required this.interests});
  AppUser curruser;
  List interests;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  db_conn db = db_conn();
  ImagePicker picker = ImagePicker();
  var imagepath;
  var compressedimgpath;
  TextEditingController fullnamecontroller = TextEditingController();
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController biocontroller = TextEditingController();
  //DateTime birthday = DateTime(0, 0, 0);
  bool buttonpressed = false;

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
  String gender = "";
  String nationality = "";
  String bio = "";

  void displayErrorSnackBar(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 400));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

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

  @override
  void initState() {
    setState(() {
      fullnamecontroller.text = widget.curruser.fullname;
      usernamecontroller.text = widget.curruser.username;
      biocontroller.text = widget.curruser.bio;
      gender = widget.curruser.gender;
      nationality = widget.curruser.nationality;

      //birthday = widget.curruser.birthday;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return buttonpressed
        ? LoadingOverlay(
            text: "Updating your info...",
            color: Colors.black,
          )
        : Scaffold(
            resizeToAvoidBottomInset: true,
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
                  color: Colors.black,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(children: [
                Center(
                  child: InkWell(
                    onTap: () async {
                      try {
                        XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            imagepath = File(image.path);
                          });
                          //print(imagepath);
                        }
                      } catch (e) {
                        displayErrorSnackBar("Error with profile picture");
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: imagepath == null
                          ? Image.network(
                              widget.curruser.pfpurl,
                              height: screenheight * 0.2,
                              width: screenheight * 0.2,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              imagepath,
                              height: screenheight * 0.2,
                              width: screenheight * 0.2,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenheight * 0.02,
                ),
                const Text(
                  "Change Profile Picture",
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(
                  height: screenheight * 0.02,
                ),
                textdatafield(screenwidth, "fullname", fullnamecontroller),
                SizedBox(
                  height: screenheight * 0.02,
                ),
                textdatafield(screenwidth, "username", usernamecontroller),
                SizedBox(
                  height: screenheight * 0.02,
                ),
                textdatafield(
                    screenwidth, "bio: socials, intro ...", biocontroller),
                SizedBox(
                  height: screenheight * 0.02,
                ),
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
                SizedBox(
                  height: screenheight * 0.02,
                ),
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
                SizedBox(
                  height: screenheight * 0.02,
                ),
                InkWell(
                  onTap: () async {
                    List updatedinterests = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => UpdateInterests(
                                  curruser: widget.curruser,
                                  interests: widget.interests,
                                )));
                    setState(() {
                      widget.interests = updatedinterests;
                    });
                    //print(widget.interests);
                  },
                  child: Container(
                    height: screenwidth * 0.13,
                    width: screenwidth * 0.6,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.black)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Interests",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          )
                        ]),
                  ),
                ),
                SizedBox(
                  height: screenheight * 0.02,
                ),
                InkWell(
                  onTap: buttonpressed
                      ? null
                      : () async {
                          setState(() {
                            buttonpressed = true;
                          });
                          try {
                            if (imagepath != null) {
                              compressedimgpath =
                                  await CompressAndGetFile(imagepath);
                              await db.changepfp(
                                  compressedimgpath, widget.curruser.uid);
                            }
                            bool unique = await db
                                .usernameUnique(usernamecontroller.text.trim());
                            if (unique &&
                                usernamecontroller.text.isNotEmpty &&
                                RegExp(r'^[a-zA-Z0-9&%=]+$')
                                    .hasMatch(usernamecontroller.text.trim())) {
                              await db.changeusername(
                                  usernamecontroller.text.trim(),
                                  widget.curruser.uid);
                            }
                            if (fullnamecontroller.text.isNotEmpty) {
                              await db.changeattribute(
                                  'fullname',
                                  fullnamecontroller.text.trim(),
                                  widget.curruser.uid);
                            }
                            await db.changeattribute(
                                'gender', gender, widget.curruser.uid);
                            await db.changeattribute('nationality', nationality,
                                widget.curruser.uid);
                            await db.changeinterests('interests',
                                widget.interests, widget.curruser.uid);
                            await db.changeattribute('bio',
                                biocontroller.text.trim(), widget.curruser.uid);
                          } catch (e) {
                            displayErrorSnackBar("Could not update profile");
                          } finally {
                            setState(() {
                              buttonpressed = false;
                            });
                            Navigator.pop(context);
                          }
                        },
                  child: SizedBox(
                      height: 50,
                      width: screenwidth * 0.6,
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 255, 48, 117),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: const Center(
                            child: Text(
                          "Update Profile",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )),
                      )),
                )
              ]),
            ),
          );
  }
}
