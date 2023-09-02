import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clout/defs/location.dart';
import 'package:clout/defs/user.dart';
import 'package:clout/services/db.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

part 'loadingbloc_event.dart';
part 'loadingbloc_state.dart';

class LoadingblocBloc extends Bloc<LoadingblocEvent, LoadingblocState> {
  LoadingblocBloc() : super(LoadingblocLoading()) {
    on<Loading>(_loading);
  }

  late Position _locationData;
  db_conn db = db_conn();
  Dio _dio = Dio();

  FutureOr<void> _loading(Loading event, Emitter<LoadingblocState> emit) async {
    emit(LoadingblocLoading());
    try {
      bool gotlocation = await getlocation();
      if (!gotlocation) {
        throw Exception("Need location services enabled to continue");
      }
      bool maintenance = await undermaintenance();
      if (maintenance) {
        emit(LoadingblocMaintenance());
        return;
      }
      bool needupdate = await checkneedupdate(event.uid);
      if (needupdate) {
        emit(LoadingblocUpdateNeeded());
        return;
      }
      await event.analytics.setUserId(id: event.uid);
      AppUser curruser = await getuser(event.uid);
      if (curruser.plan != "business") {
        List providers = getallproviders(event.uid);
        if (!providers.contains("phone")) {
          emit(LoadingblocLinkAuth(analytics: event.analytics));
        } else {
          LoadingblocState finalstate =
              await finishloading(curruser, event.analytics);
          emit(finalstate);
        }
      } else {
        LoadingblocState finalstate =
            await finishloading(curruser, event.analytics);
        emit(finalstate);
      }
    } catch (e) {
      emit(LoadingblocError(error: e.toString()));
    }
  }

  Future<bool> getlocation() async {
    bool _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      return false;
    }

    // Check if permission is granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    _locationData = await Geolocator.getCurrentPosition();
    return true;
  }

  Future<bool> undermaintenance() async {
    try {
      bool maint = await db.undermaintenance();
      return maint;
    } catch (e) {
      throw Exception("Check your internet connection and try again.");
    }
  }

  Future<bool> checkneedupdate(String uid) async {
    try {
      bool upd = await db.checkversionandneedupdate(uid);
      return upd;
    } catch (e) {
      throw Exception("Check your internet connection and try again.");
    }
  }

  Future<AppUser> getuser(String uid) async {
    try {
      AppUser curruser = await db.getUserFromUID(uid);
      return curruser;
    } catch (e) {
      throw Exception("Check your internet connection and try again.");
    }
  }

  List getallproviders(String uid) {
    List<UserInfo>? providersdata =
        FirebaseAuth.instance.currentUser?.providerData;
    List providers = [];
    for (int i = 0; i < providersdata!.length; i++) {
      providers.add(providersdata[i].providerId);
    }
    return providers;
  }

  Future<LoadingblocState> finishloading(
      AppUser curruser, FirebaseAnalytics analytics) async {
    try {
      if (!curruser.setnameandpfp) {
        return LoadingblocSetNameAndPfp(
            analytics: analytics, curruser: curruser);
      } else if (!curruser.setusername) {
        return LoadingblocSetUsername(analytics: analytics, curruser: curruser);
      } else if (!curruser.setmisc) {
        return LoadingblocSetMisc(analytics: analytics);
      } else if (curruser.incompletewebsignup) {
        return LoadingblocIncompleteWeb(analytics: analytics);
      } else if (curruser.plan != "business" && !curruser.setinterests) {
        return LoadingblocSetInterests(analytics: analytics);
      } else if (curruser.plan == "business" &&
          !FirebaseAuth.instance.currentUser!.emailVerified) {
        return LoadingblocEmailNotVerified(analytics: analytics);
      } else {
        AppLocation curruserlocation = await getUserAppLocation();
        await db.updatelastuserlocandusage(curruser.uid,
            curruserlocation.center[1], curruserlocation.center[0], curruser);
        return LoadingblocLoaded(
            curruser: curruser,
            analytics: analytics,
            curruserlocation: curruserlocation);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<AppLocation> getUserAppLocation() async {
    try {
      String url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${_locationData?.latitude},${_locationData?.longitude}&result_type=country&key=AIzaSyAR9bmRxpCYai5b2k6AKtc4f7Es9w1307w';
      url = Uri.parse(url).toString();

      _dio.options.contentType = Headers.jsonContentType;
      final responseData = await _dio.get(url);
      String country = responseData.data['results'][0]['address_components'][0]
              ['long_name']
          .toString()
          .toLowerCase();
      return AppLocation(
          address: "",
          city: "",
          country: country,
          center: [_locationData?.longitude, _locationData?.latitude]);
    } catch (e) {
      throw Exception("Could not get location, please try again.");
    }
  }
}
