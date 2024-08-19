import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../models/custom_user.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class DeliverooColors {
  static const Color primary = Color(0xFF00CCBC);
  static const Color secondary = Color(0xFF2E3333);
  static const Color background = Color(0xFFF9FAFA);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = FirestoreService();
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    return Scaffold(
      backgroundColor: DeliverooColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60),
                Text(
                  'FoodDash',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: DeliverooColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: DeliverooColors.textDark,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        icon: Icons.email,
                        hintText: 'Email',
                        onSaved: (value) => _email = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        icon: Icons.lock,
                        hintText: 'Password',
                        obscureText: !_isPasswordVisible,
                        onSaved: (value) => _password = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: DeliverooColors.textLight,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: DeliverooColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      _formKey.currentState!.save();
                      try {
                        final CustomUser? user = await authService.signInWithEmailAndPassword(_email, _password, context);
                        if (user != null) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to sign in: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                ),
                SizedBox(height: 16),
                TextButton(
                  child: Text(
                    'Don\'t have an account? Register',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(color: DeliverooColors.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/register');
                  },
                ),
                SizedBox(height: 24),
                OutlinedButton(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Skip Login',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(fontSize: 16, color: DeliverooColors.textDark, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: DeliverooColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DeliverooColors.textLight.withOpacity(0.5)),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: DeliverooColors.primary),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(textStyle: TextStyle(color: DeliverooColors.textLight)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: suffixIcon,
        ),
        style: GoogleFonts.poppins(textStyle: TextStyle(color: DeliverooColors.textDark)),
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}