import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:business_management_app/models/user.dart' as app_user;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _storage.write(key: 'userId', value: userCredential.user?.uid);
      return userCredential.user != null;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user != null;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _storage.delete(key: 'userId');
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<app_user.User> getUserDetails(String userId) async {
    try {
      DocumentSnapshot doc = await _userCollection.doc(userId).get();
      if (doc.exists) {
        return app_user.User.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Error getting user details: $e');
    }
  }
}
