import 'package:clout/main.dart';
import 'package:clout/screens/loading.dart';
import 'package:clout/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetttingsScreen extends StatelessWidget {
  const SetttingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Center(
          child: InkWell(
            onTap: () async {
              await context.read<AuthenticationService>().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => LoadingScreen(uid: ""),
                ),
              );
            },
            child: SizedBox(
                height: 50,
                width: screenwidth * 0.6,
                child: Container(
                  child: Center(
                      child: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  )),
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 48, 117),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                )),
          ),
        ),
      ]),
    );
  }
}
