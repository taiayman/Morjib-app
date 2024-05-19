import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_management_app/services/auth_service.dart';
import 'package:business_management_app/services/user_service.dart';
import 'package:business_management_app/models/user.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  String? _role;

  // Hardcoded credentials for the boss
  final String _bossEmail = 'boss@example.com';
  final String _bossPassword = 'boss1234';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _role = ModalRoute.of(context)!.settings.arguments as String?;
  }

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Check if the entered credentials match the hardcoded boss credentials
    if (email == _bossEmail && password == _bossPassword) {
      Navigator.pushReplacementNamed(context, '/boss_dashboard');
      return;
    }

    // Proceed with normal authentication for other users
    bool success = await _authService.login(email, password);
    if (success) {
      User? user = await _userService.getCurrentUser();
      if (user != null) {
        if (user.role == 'Boss' || _role == 'Boss') {
          Navigator.pushReplacementNamed(context, '/boss_dashboard');
        } else if (user.role == 'CEO' || _role == 'CEO') {
          Navigator.pushReplacementNamed(context, '/ceo_dashboard');
        }
      } else {
        // Handle the case where user is null
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('Login', style: GoogleFonts.rubik()),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_emailController, 'Email'),
            _buildTextField(_passwordController, 'Password', obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97757),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                textStyle: GoogleFonts.rubik(fontSize: 18),
              ),
              child: Text('Login', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.rubik(),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.rubik(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
