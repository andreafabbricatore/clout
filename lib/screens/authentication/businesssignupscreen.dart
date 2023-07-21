import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class BusinessSignUpScreen extends StatefulWidget {
  BusinessSignUpScreen({super.key, required this.analytics});
  FirebaseAnalytics analytics;
  @override
  State<BusinessSignUpScreen> createState() => _BusinessSignUpScreenState();
}

class _BusinessSignUpScreenState extends State<BusinessSignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    );
  }
}
