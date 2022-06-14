import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key, required this.name});
  String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Text(name)),
    );
  }
}
