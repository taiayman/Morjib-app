import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/custom_user.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.orange.shade300, Colors.deepOrange.shade600],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 60),
                    Icon(
                      Icons.local_shipping,
                      size: 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                                color: Colors.white70,
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
                            ? CircularProgressIndicator(color: Colors.deepOrange)
                            : Text(
                                'Login',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      onPressed: _isLoading ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          _formKey.currentState!.save();
                          try {
                            final CustomUser? user = await authService.signInWithEmailAndPassword(_email, _password); 
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
                        style: TextStyle(color: Colors.white),
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
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
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
        ],
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
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: suffixIcon,
        ),
        style: TextStyle(color: Colors.white),
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}