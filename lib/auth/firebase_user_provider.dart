import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class TeachYourSelfFirebaseUser {
  TeachYourSelfFirebaseUser(this.user);
  final User user;
  bool get loggedIn => user != null;
  // int get pageLimit => user.pageLimit;
}

TeachYourSelfFirebaseUser currentUser;
bool get loggedIn => currentUser?.loggedIn ?? false;
Stream<TeachYourSelfFirebaseUser> teachYourSelfFirebaseUserStream() =>
    FirebaseAuth.instance
        .authStateChanges()
        .debounce((user) => user == null && !loggedIn
            ? TimerStream(true, const Duration(seconds: 1))
            : Stream.value(user))
        .map<TeachYourSelfFirebaseUser>(
            (user) => currentUser = TeachYourSelfFirebaseUser(user));
