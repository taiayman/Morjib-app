import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

class CarrefourColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class PhoneAuthScreen extends StatefulWidget {
  final String email;
  final String password;

  PhoneAuthScreen({required this.email, required this.password});

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  bool _codeSent = false;
  bool _isLoading = false;

  String _formatPhoneNumber(String number) {
    number = number.replaceAll(RegExp(r'\D'), '');
    if (number.startsWith('0') && number.length == 10) {
      return '+212${number.substring(1)}';
    } else if (number.length == 9 && !number.startsWith('0')) {
      return '+212$number';
    }
    return number;
  }

  void _verifyPhoneNumber() async {
    setState(() {
      _isLoading = true;
    });

    final formattedNumber = _formatPhoneNumber(_phoneController.text);

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _checkEmailVerificationAndProceed();
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Failed to verify phone number: ${e.message}');
        setState(() {
          _codeSent = false;
          _isLoading = false;
        });
        _showErrorSnackBar(e.message ?? 'an_error_occurred'.tr());
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
      },
    );
  }

  void _signInWithPhoneNumber() async {
    setState(() {
      _isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text,
      );

      await _auth.signInWithCredential(credential);
      _checkEmailVerificationAndProceed();
    } catch (e) {
      print('Failed to sign in: ${e.toString()}');
      _showErrorSnackBar('invalid_verification_code'.tr());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkEmailVerificationAndProceed() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _showErrorSnackBar('please_verify_email'.tr());
        await Future.delayed(Duration(seconds: 2));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(
              initialEmail: widget.email,
              initialPassword: widget.password,
            ),
          ),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            initialEmail: widget.email,
            initialPassword: widget.password,
          ),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarrefourColors.background,
      appBar: AppBar(
        title: Text(
          'phone_authentication'.tr(),
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: CarrefourColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Text(
                'verify_your_phone'.tr(),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CarrefourColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                'enter_phone_number'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: CarrefourColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'moroccan_number_format'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: CarrefourColors.textLight,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              _buildTextField(
                controller: _phoneController,
                labelText: 'phone_number'.tr(),
                keyboardType: TextInputType.phone,
                hintText: '0612345678',
              ),
              SizedBox(height: 24),
              _buildButton(
                onPressed: _codeSent ? null : _verifyPhoneNumber,
                text: 'send_verification_code'.tr(),
              ),
              if (_codeSent) ...[
                SizedBox(height: 24),
                _buildTextField(
                  controller: _codeController,
                  labelText: 'verification_code'.tr(),
                  keyboardType: TextInputType.number,
                  hintText: '123456',
                ),
                SizedBox(height: 24),
                _buildButton(
                  onPressed: _signInWithPhoneNumber,
                  text: 'verify_and_sign_in'.tr(),
                ),
              ],
              SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(
                        initialEmail: widget.email,
                        initialPassword: widget.password,
                      ),
                    ),
                  );
                },
                child: Text(
                  'skip_for_now'.tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: CarrefourColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: GoogleFonts.poppins(color: CarrefourColors.textLight),
        hintStyle: GoogleFonts.poppins(color: CarrefourColors.textLight.withOpacity(0.5)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CarrefourColors.primary, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CarrefourColors.textLight, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: CarrefourColors.textDark),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    );
  }

  Widget _buildButton({required VoidCallback? onPressed, required String text}) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      child: _isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: CarrefourColors.primary,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }
}