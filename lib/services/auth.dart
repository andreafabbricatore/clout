import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future? signOut() async {
    try {
      return _firebaseAuth.signOut();
    } catch (e) {
      throw Exception("Could not sign out");
    }
  }

  Future? signIn({required String email, required String password}) async {
    try {
      return _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw Exception("could not sign in");
    }
  }

  Future? verifyEmail() {
    try {
      return _firebaseAuth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw Exception("Could not send verification email");
    }
  }

  Future? signUp({required String email, required String password}) async {
    try {
      return _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      throw Exception("Could not signup");
    }
  }

  String? getuid() {
    return _firebaseAuth.currentUser?.uid;
  }
}
