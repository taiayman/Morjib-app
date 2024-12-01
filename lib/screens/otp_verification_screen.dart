import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_delivery_app/screens/cart_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String email;
  final String name;
  final String phone;
  final String password;

  OTPVerificationScreen({
    required this.verificationId,
    required this.email,
    required this.name,
    required this.phone,
    required this.password,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: CarrefourColors.background,
      appBar: AppBar(
        title: Text(
          'otp_verification'.tr(),
          style: GoogleFonts.playfairDisplay(
            textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        backgroundColor: CarrefourColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'enter_otp'.tr(),
              style: GoogleFonts.poppins(
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'enter_6_digit_code'.tr(),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'verify'.tr(),
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: CarrefourColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _isLoading ? null : () async {
                setState(() {
                  _isLoading = true;
                });
                try {
                  // Verify OTP
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: widget.verificationId,
                    smsCode: _otpController.text,
                  );
                  await FirebaseAuth.instance.signInWithCredential(credential);

                  // Register user
                  await authService.registerWithEmailAndPassword(
                    widget.email,
                    widget.password,
                    widget.name,
                    widget.phone,
                    context,
                  );

                  // Navigate to home screen
                  Navigator.of(context).pushReplacementNamed('/home');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('verification_failed'.tr(args: [e.toString()]))),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}