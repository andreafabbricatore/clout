import 'package:clout/screens/authscreen.dart';
import 'package:clout/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: InkWell(
          onTap: () async {
            await context.read<AuthenticationService>().signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => AuthScreen(),
              ),
            );
          },
          child: Text("Signed in")),
    ));
  }
}
