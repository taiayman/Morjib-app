import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import '../models/custom_user.dart';
import '../services/firestore_service.dart';

class AuthService extends ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Create CustomUser object based on FirebaseUser
  CustomUser? _userFromFirebaseUser(auth.User? user) {
    if (user == null) {
      return null;
    }
    return CustomUser.fromFirebaseUser(user);
  }

  // Auth change user stream
  Stream<CustomUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Get current user
  CustomUser? get currentUser {
    return _userFromFirebaseUser(_auth.currentUser);
  }

  // Sign in with email & password
  Future<CustomUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      auth.UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      auth.User? user = result.user;
      if (user != null) {
        // Fetch user data from Firestore
        int points = await _firestoreService.getUserPoints(user.uid);
        CustomUser customUser = CustomUser.fromFirebaseUser(user, points: points);
        notifyListeners();
        return customUser;
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<CustomUser?> registerWithEmailAndPassword(String email, String password, String name, String phone) async {
    try {
      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      auth.User? user = result.user;
      if (user != null) {
        // Create a new document for the user with the uid
        await _firestoreService.createUser(user.uid, email, name, phone);
        CustomUser customUser = CustomUser.fromFirebaseUser(user, points: 0);
        notifyListeners();
        return customUser;
      }
      return null;
    } catch (e) {
      print('Error in registerWithEmailAndPassword: ${e.toString()}');
      rethrow; // Rethrow the error so it can be caught and handled in the UI
    }
  }


  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> isUserLoggedIn() async {
    auth.User? user = _auth.currentUser;
    if (user != null) {
      // Optionally, you can perform additional checks here
      // For example, checking if the user's token is still valid
      return true;
    }
    return false;
  }
}