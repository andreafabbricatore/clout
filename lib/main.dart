import 'package:clout/screens/authscreen.dart';
import 'package:clout/screens/emailverificationscreen.dart';
import 'package:clout/screens/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: "assets/.env");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  PendingDynamicLinkData? initialLink;
  MyApp({super.key, initialLink});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'clout',
      debugShowCheckedModeBanner: false,
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            //print(FirebaseAuth.instance.currentUser!);
            if (FirebaseAuth.instance.currentUser!.emailVerified) {
              return LoadingScreen(uid: FirebaseAuth.instance.currentUser!.uid);
            } else {
              return const EmailVerificationScreen();
            }
          } else {
            //print("auth");
            return AuthScreen();
          }
        }),
      ),
    );
  }
}
