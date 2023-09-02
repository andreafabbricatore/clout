part of 'loadingbloc_bloc.dart';

class LoadingblocEvent extends Equatable {
  const LoadingblocEvent();

  @override
  List<Object> get props => [];
}

class Loading extends LoadingblocEvent {
  Loading({required this.uid, required this.analytics});
  String uid;
  FirebaseAnalytics analytics;
}
