import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'phone_auth_screen.dart';

class CarrefourColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _name = '';
  String _phone = '';
  String _password = '';
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: CarrefourColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: CarrefourColors.primary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Text(
                  'app_name'.tr(),
                  style: GoogleFonts.playfairDisplay(
                    textStyle: TextStyle(
                      color: CarrefourColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Text(
                  'create_account'.tr(),
                  style: GoogleFonts.playfairDisplay(
                    textStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: CarrefourColors.textDark,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        icon: Icons.person,
                        hintText: 'name'.tr(),
                        onSaved: (value) => _name = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_name'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        icon: Icons.email,
                        hintText: 'email'.tr(),
                        onSaved: (value) => _email = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_email'.tr();
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'please_enter_valid_email'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        icon: Icons.phone,
                        hintText: 'phone'.tr() + ' (0612345678)',
                        onSaved: (value) {
                          if (value != null && value.isNotEmpty) {
                            _phone = '+212' + value.substring(1);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_phone'.tr();
                          }
                          if (!RegExp(r'^0[567]\d{8}$').hasMatch(value)) {
                            return 'please_enter_valid_moroccan_phone'.tr();
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        icon: Icons.lock,
                        hintText: 'password'.tr(),
                        obscureText: !_isPasswordVisible,
                        onSaved: (value) => _password = value!,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'please_enter_password'.tr();
                          }
                          if (value.length < 6) {
                            return 'password_length'.tr();
                          }
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: CarrefourColors.textLight,
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
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: CarrefourColors.accent.withOpacity(0.5),
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
                              'register'.tr(),
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: CarrefourColors.primary,
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
                          await authService.registerWithEmailAndPassword(_email, _password, _name, _phone, context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'registration_successful'.tr(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'verify_phone'.tr(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              backgroundColor: CarrefourColors.primary,
                              duration: Duration(seconds: 7),
                              action: SnackBarAction(
                                label: 'ok'.tr(),
                                textColor: Colors.white,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                },
                              ),
                            ),
                          );

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => PhoneAuthScreen(email: _email, password: _password),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Icon(Icons.error, color: Colors.white),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'registration_failed'.tr(args: [e.toString()]),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 5),
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
                Text(
                  'already_have_account'.tr(),
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(color: CarrefourColors.textDark),
                  ),
                ),
                TextButton(
                  child: Text(
                    'login'.tr(),
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: CarrefourColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CarrefourColors.textLight.withOpacity(0.5)),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: CarrefourColors.primary),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: CarrefourColors.textLight),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffixIcon,
        ),
        style: GoogleFonts.poppins(textStyle: TextStyle(color: CarrefourColors.textDark)),
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }
}