import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_management_app/services/auth_service.dart';
import 'package:business_management_app/services/user_service.dart';
import 'package:business_management_app/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  final String? initialRole;

  const LoginScreen({Key? key, this.initialRole}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _role;

  final String _bossEmail = 'boss@example.com';
  final String _bossPassword = 'boss1234';

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email == _bossEmail && password == _bossPassword) {
      await _storage.write(key: 'userRole', value: 'Boss');
      Navigator.pushReplacementNamed(context, '/boss_dashboard');
      return;
    }

    bool success = await _authService.login(email, password);
    if (success) {
      User? user = await _userService.getCurrentUser();
      if (user != null) {
        if (user.role == 'Boss' || _role == 'Boss') {
          await _storage.write(key: 'userRole', value: 'Boss');
          Navigator.pushReplacementNamed(context, '/boss_dashboard');
        } else if (user.role == 'CEO' || _role == 'CEO') {
          await _storage.write(key: 'userRole', value: 'CEO');
          Navigator.pushReplacementNamed(context, '/ceo_dashboard');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
      }
    } else {
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
        title: Text('Login', style: GoogleFonts.nunito(color: Colors.white)),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/manager.png', height: 250, width: 250),
                SizedBox(height: 20),
                _buildTextField(_emailController, 'Email'),
                SizedBox(height: 16),
                _buildTextField(_passwordController, 'Password', obscureText: true),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD97757),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    textStyle: GoogleFonts.nunito(fontSize: 18),
                  ),
                  child: Text('Login', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.nunito(),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.nunito(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
