import 'package:clout/blocs/loadingbloc/loadingbloc_bloc.dart';
import 'package:clout/screens/authentication/emailverificationscreen.dart';
import 'package:clout/screens/authentication/signupflowscreens.dart';
import 'package:clout/screens/authscreens/mainscreen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launch_review/launch_review.dart';

class LoadingScreen extends StatelessWidget {
  LoadingScreen({super.key, required this.uid, required this.analytics});
  String uid;
  FirebaseAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return BlocProvider(
      create: (context) =>
          LoadingblocBloc()..add(Loading(uid: uid, analytics: analytics)),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: BlocConsumer<LoadingblocBloc, LoadingblocState>(
            builder: (context, state) {
          if (state is LoadingblocMaintenance) {
            return LoadingMaintenance(
                screenheight: screenheight,
                uid: uid,
                analytics: analytics,
                screenwidth: screenwidth);
          }
          if (state is LoadingblocUpdateNeeded) {
            return LoadingUpdateNeeded(
                screenheight: screenheight, screenwidth: screenwidth);
          }
          if (state is LoadingblocError) {
            return LoadingError(
              screenheight: screenheight,
              uid: uid,
              analytics: analytics,
              screenwidth: screenwidth,
              state: state,
            );
          }
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: SafeArea(
              child: Center(
                  child: Image.asset("assets/images/logos/cloutlogo.gif")),
            ),
          );
        }, listener: (context, state) {
          if (state is LoadingblocSetNameAndPfp) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => PicandNameScreen(
                        analytics: analytics,
                        business: state.curruser.plan == "business",
                      ),
                  settings: const RouteSettings(name: "PicandNameScreen"),
                  fullscreenDialog: true),
            );
          }
          if (state is LoadingblocSetUsername) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => UsernameScreen(
                        analytics: analytics,
                        business: state.curruser.plan == "business",
                      ),
                  settings: const RouteSettings(name: "UsernameScreen"),
                  fullscreenDialog: true),
            );
          }
          if (state is LoadingblocSetMisc) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MiscScreen(
                        analytics: analytics,
                      ),
                  settings: const RouteSettings(name: "MiscScreen"),
                  fullscreenDialog: true),
            );
          }
          if (state is LoadingblocIncompleteWeb) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => WebFinishScreen(
                        analytics: analytics,
                      ),
                  settings: const RouteSettings(name: "WebFinishScreen"),
                  fullscreenDialog: true),
            );
          }
          if (state is LoadingblocSetInterests) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => InterestScreen(
                        analytics: analytics,
                      ),
                  settings: const RouteSettings(name: "InterestScreen"),
                  fullscreenDialog: true),
            );
          }
          if (state is LoadingblocEmailNotVerified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => EmailVerificationScreen(
                        analytics: analytics,
                      ),
                  settings:
                      const RouteSettings(name: "EmailVerificationScreen"),
                  fullscreenDialog: true),
            );
          }
          if (state is LoadingblocLoaded) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => MainScreen(
                    curruser: state.curruser,
                    curruserlocation: state.curruserlocation,
                    justloaded: true,
                    analytics: analytics),
                fullscreenDialog: true,
              ),
            );
          }
        }),
      ),
    );
  }
}

class LoadingError extends StatelessWidget {
  const LoadingError(
      {super.key,
      required this.screenheight,
      required this.uid,
      required this.analytics,
      required this.screenwidth,
      required this.state});

  final double screenheight;
  final String uid;
  final FirebaseAnalytics analytics;
  final double screenwidth;
  final LoadingblocError state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textScaler: const TextScaler.linear(1.2)),
              SizedBox(
                height: screenheight * 0.02,
              ),
              GestureDetector(
                onTap: () {
                  context
                      .read<LoadingblocBloc>()
                      .add(Loading(uid: uid, analytics: analytics));
                },
                child: SizedBox(
                    height: 50,
                    width: screenwidth * 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      child: const Center(
                          child: Text(
                        "Refresh",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        textScaler: TextScaler.linear(1.2),
                      )),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingMaintenance extends StatelessWidget {
  const LoadingMaintenance({
    super.key,
    required this.screenheight,
    required this.uid,
    required this.analytics,
    required this.screenwidth,
  });

  final double screenheight;
  final String uid;
  final FirebaseAnalytics analytics;
  final double screenwidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Server under maintenance\n\nWe'll be back soon!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
                textScaler: TextScaler.linear(1.2),
              ),
              SizedBox(
                height: screenheight * 0.02,
              ),
              InkWell(
                onTap: () {
                  context
                      .read<LoadingblocBloc>()
                      .add(Loading(uid: uid, analytics: analytics));
                },
                child: SizedBox(
                    height: 50,
                    width: screenwidth * 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      child: const Center(
                          child: Text(
                        "Refresh",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        textScaler: TextScaler.linear(1.2),
                      )),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingUpdateNeeded extends StatelessWidget {
  const LoadingUpdateNeeded({
    super.key,
    required this.screenheight,
    required this.screenwidth,
  });

  final double screenheight;
  final double screenwidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Update available!\n\nUpdate Clout to keep Going Out!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  textScaler: TextScaler.linear(1.2)),
              SizedBox(
                height: screenheight * 0.02,
              ),
              InkWell(
                onTap: () {
                  LaunchReview.launch(
                      iOSAppId: "1642153685",
                      androidAppId: "com.outwithclout.clout",
                      writeReview: false);
                },
                child: SizedBox(
                    height: 50,
                    width: screenwidth * 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      child: const Center(
                          child: Text(
                        "Update",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        textScaler: TextScaler.linear(1.2),
                      )),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
