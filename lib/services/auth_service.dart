import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/custom_user.dart';

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
        if (!user.emailVerified) {
          await signOut();
          _showEnhancedSnackBar(
            context: context,
            message: 'Please verify your email before logging in. Check your inbox for the verification link.',
            icon: Icons.mark_email_unread,
            backgroundColor: Colors.orange,
          );
          return null;
        }
        _user = await _getUserFromFirestore(user);
        await _saveLoginState(true);
        notifyListeners();
        return _user;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      IconData errorIcon = Icons.error_outline;
      Color backgroundColor = Colors.red;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email. Please check your email or sign up.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          errorIcon = Icons.lock_outline;
          backgroundColor = Colors.orange;
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format. Please enter a valid email address.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled. Please contact support.';
          break;
        default:
          errorMessage = 'An error occurred while signing in. Please try again later.';
      }
      _showEnhancedSnackBar(
        context: context,
        message: errorMessage,
        icon: errorIcon,
        backgroundColor: backgroundColor,
      );
    } catch (e) {
      _showEnhancedSnackBar(
        context: context,
        message: 'An unexpected error occurred. Please try again later.',
        icon: Icons.error,
        backgroundColor: Colors.red,
      );
    }
    return null;
  }

  Future<void> registerWithEmailAndPassword(String email, String password, String name, String phone, BuildContext context) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await user.sendEmailVerification();
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'phone': phone,
          'name': name,
          'points': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _showEnhancedSnackBar(
          context: context,
          message: 'Account created successfully! Please check your email to verify your account.',
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email. Please sign in or use a different email.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format. Please enter a valid email address.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak. Please use a stronger password.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Account creation is currently disabled. Please try again later.';
          break;
        default:
          errorMessage = 'An error occurred while creating your account. Please try again later.';
      }
      _showEnhancedSnackBar(
        context: context,
        message: errorMessage,
        icon: Icons.error_outline,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      _showEnhancedSnackBar(
        context: context,
        message: 'An unexpected error occurred. Please try again later.',
        icon: Icons.error,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _saveLoginState(false);
      _user = null;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  Future<void> sendPasswordResetEmail(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showEnhancedSnackBar(
        context: context,
        message: 'Password reset email sent. Please check your inbox.',
        icon: Icons.mail,
        backgroundColor: Colors.blue,
      );
    } catch (e) {
      _showEnhancedSnackBar(
        context: context,
        message: 'Failed to send password reset email: ${e.toString()}',
        icon: Icons.error,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<bool> userHasAddress() async {
    if (_user == null) return false;
    DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
    return doc['hasSetAddress'] ?? false;
  }

  Future<void> updateUserInfo(String uid, String name, String email, String address) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name,
      'email': email,
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

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signInWithPhoneAuthCredential(PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    _user = await _getUserFromFirestore(userCredential.user!);
    notifyListeners();
    return userCredential;
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      // Track the password reset attempt
      await _firestore.collection('password_resets').add({
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'requested',
      });

      _showEnhancedSnackBar(
        context: context,
        message: 'reset_email_sent'.tr(),
        icon: Icons.mail_outline,
        backgroundColor: Colors.green,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'invalid_email_format'.tr();
          break;
        case 'user-not-found':
          errorMessage = 'no_user_found'.tr();
          break;
        default:
          errorMessage = 'reset_password_error'.tr();
      }
      _showEnhancedSnackBar(
        context: context,
        message: errorMessage,
        icon: Icons.error_outline,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      _showEnhancedSnackBar(
        context: context,
        message: 'unexpected_error'.tr(),
        icon: Icons.error_outline,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<bool> verifyResetCode(String code) async {
    try {
      return await _auth.verifyPasswordResetCode(code) != null;
    } catch (e) {
      return false;
    }
  }

  void _showEnhancedSnackBar({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}