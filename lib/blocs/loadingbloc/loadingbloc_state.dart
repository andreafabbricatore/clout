part of 'loadingbloc_bloc.dart';

class LoadingblocState extends Equatable {
  const LoadingblocState();

  @override
  List<Object> get props => [];
}

class LoadingblocLoading extends LoadingblocState {}

class LoadingblocLoaded extends LoadingblocState {
  LoadingblocLoaded(
      {required this.curruser,
      required this.analytics,
      required this.curruserlocation});
  AppUser curruser;
  FirebaseAnalytics analytics;
  AppLocation curruserlocation;
}

class LoadingblocSetNameAndPfp extends LoadingblocState {
  LoadingblocSetNameAndPfp({required this.analytics, required this.curruser});
  FirebaseAnalytics analytics;
  AppUser curruser;
}

class LoadingblocSetUsername extends LoadingblocState {
  LoadingblocSetUsername({required this.analytics, required this.curruser});
  FirebaseAnalytics analytics;
  AppUser curruser;
}

class LoadingblocSetMisc extends LoadingblocState {
  LoadingblocSetMisc({required this.analytics});
  FirebaseAnalytics analytics;
}

class LoadingblocIncompleteWeb extends LoadingblocState {
  LoadingblocIncompleteWeb({required this.analytics});
  FirebaseAnalytics analytics;
}

class LoadingblocSetInterests extends LoadingblocState {
  LoadingblocSetInterests({required this.analytics});
  FirebaseAnalytics analytics;
}

class LoadingblocEmailNotVerified extends LoadingblocState {
  LoadingblocEmailNotVerified({required this.analytics});
  FirebaseAnalytics analytics;
}

class LoadingblocLinkAuth extends LoadingblocState {
  LoadingblocLinkAuth({
    required this.analytics,
  });
  FirebaseAnalytics analytics;
  bool updatephonenumber = false;
}

class LoadingblocMaintenance extends LoadingblocState {}

class LoadingblocUpdateNeeded extends LoadingblocState {}

class LoadingblocError extends LoadingblocState {
  LoadingblocError({required this.error});
  String error;
}
