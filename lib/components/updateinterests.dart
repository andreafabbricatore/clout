import 'package:clout/components/user.dart';
import 'package:flutter/material.dart';

class UpdateInterests extends StatefulWidget {
  UpdateInterests({
    Key? key,
    required this.curruser,
    required this.interests,
  }) : super(key: key);
  List interests;
  AppUser curruser;
  @override
  State<UpdateInterests> createState() => _UpdateInterestsState();
}

class _UpdateInterestsState extends State<UpdateInterests> {
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
  Widget _listviewitem(String interest) {
    Widget thiswidget = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
            width: widget.interests.contains(interest) ? 2 : 0,
            color: widget.interests.contains(interest)
                ? const Color.fromARGB(255, 255, 48, 117)
                : Colors.black),
        image: DecorationImage(
            opacity: widget.interests.contains(interest) ? 0.8 : 1,
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
            color: widget.interests.contains(interest)
                ? const Color.fromARGB(255, 255, 48, 117)
                : Colors.white),
        textScaleFactor: 1.0,
      )),
    );

    return GestureDetector(
      onTap: () {
        if (widget.interests.contains(interest)) {
          setState(() {
            widget.interests.removeWhere((element) => element == interest);
          });
        } else {
          setState(() {
            widget.interests.add(interest);
          });
        }
      },
      child: thiswidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Interests",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
          textScaleFactor: 1.0,
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            if (widget.interests.length >= 3) {
              Navigator.pop(context, widget.interests);
            }
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }
}
