import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/custom_user.dart';
import 'cart_service.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CustomUser? _user;

  CustomUser? get currentUser => _user;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      _user = await _getUserFromFirestore(firebaseUser);
      await _saveLoginState(true);
    }
    notifyListeners();
  }

  Future<CustomUser?> _getUserFromFirestore(User firebaseUser) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists) {
      return CustomUser.fromFirebaseUser(firebaseUser, points: doc['points'] ?? 0);
    }
    return CustomUser.fromFirebaseUser(firebaseUser);
  }

  Future<bool> isUserLoggedIn() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return true;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> _saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<CustomUser?> signInWithEmailAndPassword(String email, String password, BuildContext context) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        _user = await _getUserFromFirestore(user);
        await _saveLoginState(true);
        notifyListeners();
        return _user;
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in: ${e.toString()}')),
      );
    }
    return null;
  }

  Future<CustomUser?> registerWithEmailAndPassword(String email, String password, String name, String phone) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'phone': phone,
          'points': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _user = CustomUser.fromFirebaseUser(user, points: 0);
        await _saveLoginState(true);
        notifyListeners();
        return _user;
      }
    } catch (e) {
      print('Error in registerWithEmailAndPassword: ${e.toString()}');
      rethrow;
    }
    return null;
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await _saveLoginState(false);
      _user = null;
      notifyListeners();
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
      );
    }
  }

  Future<bool> userHasAddress() async {
    if (_user == null) return false;
    DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
    return doc['hasSetAddress'] ?? false;
  }

  Future<void> updateUserInfo(String uid, String name, String phone, String address) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'phone': phone,
      'address': address,
      'hasSetAddress': true,
    });
    notifyListeners();
  }

  Future<void> updateUserPoints(String uid, int points) async {
    await _firestore.collection('users').doc(uid).update({
      'points': FieldValue.increment(points),
    });
    if (_user != null) {
      _user = CustomUser(
        uid: _user!.uid,
        email: _user!.email,
        displayName: _user!.displayName,
        points: (_user!.points ?? 0) + points,
      );
    }
    notifyListeners();
  }

  Future<void> loadUserCart(BuildContext context) async {
    if (_user != null) {
      final cartService = Provider.of<CartService>(context, listen: false);
      await cartService.loadCartFromFirestore();
    }
  }
}