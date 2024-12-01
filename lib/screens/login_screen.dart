import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../models/custom_user.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatefulWidget {
  final String initialEmail;
  final String initialPassword;

  LoginScreen({this.initialEmail = '', this.initialPassword = ''});

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
  void initState() {
    super.initState();
    _email = widget.initialEmail;
    _password = widget.initialPassword;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = FirestoreService();
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    return Scaffold(
      backgroundColor: Color(0xFFE0D5B7), // Light Gold background
      appBar: AppBar(
        backgroundColor: Color(0xFFD9251D), // Red AppBar
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                Text(
                  'app_name'.tr(),
                  style: GoogleFonts.playfairDisplay(
                    textStyle: TextStyle(
                      color: Color(0xFFD9251D), // Red text
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Text(
                  'welcome_back'.tr(),
                  style: GoogleFonts.playfairDisplay(
                    textStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3333), // Dark text color
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
                        hintText: 'email'.tr(),
                        initialValue: _email,
                        onSaved: (value) => _email = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_email'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        icon: Icons.lock,
                        hintText: 'password'.tr(),
                        initialValue: _password,
                        obscureText: !_isPasswordVisible,
                        onSaved: (value) => _password = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_password'.tr();
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Color(0xFF585C5C), // Light text color 
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/forgot-password');
                          },
                          child: Text(
                            'forgot_password_question'.tr(),
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: Color(0xFFD9251D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFD9B382).withOpacity(0.5), // Gold shadow
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'login'.tr(),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFD9251D), // Red button
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
                            Navigator.of(context).pushReplacementNamed('/welcome');
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('failed_to_sign_in'.tr(args: [e.toString()])),
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
                ),
                SizedBox(height: 16),
                TextButton(
                  child: Text(
                    'dont_have_account'.tr(),
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(color: Color(0xFFD9251D), fontWeight: FontWeight.w500), // Red text
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
                      'skip_login'.tr(),
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(fontSize: 16, color: Color(0xFF2E3333), fontWeight: FontWeight.w500), // Dark text
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFFD9251D)), // Red border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/welcome');
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
    String? initialValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF585C5C).withOpacity(0.5)), // Light text color for border
      ),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFFD9251D)), // Red icon
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(textStyle: TextStyle(color: Color(0xFF585C5C))), // Light text color for hint
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: suffixIcon,
        ),
        style: GoogleFonts.poppins(textStyle: TextStyle(color: Color(0xFF2E3333))), // Dark text color
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}