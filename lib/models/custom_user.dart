import 'package:firebase_auth/firebase_auth.dart' as auth;

class CustomUser {
  final String uid;
  final String? email;
  String? displayName; // Change from final to non-final
  final int points;

  CustomUser({
    required this.uid,
    this.email,
    this.displayName,
    this.points = 0,
  });

  factory CustomUser.fromFirebaseUser(auth.User user, {int points = 0}) {
    return CustomUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      points: points,
    );
  }

  String get name {
    return displayName ?? '';
  }

  set name(String value) {
    displayName = value; 
  }
}