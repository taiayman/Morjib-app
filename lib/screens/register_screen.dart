import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/custom_user.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  String _phone = '';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

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
                    SizedBox(height: 40),
                    Icon(
                      Icons.local_shipping,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                            hintText: 'Name',
                            onSaved: (value) => _name = value!,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            icon: Icons.email,
                            hintText: 'Email',
                            onSaved: (value) => _email = value!,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              // You can add more sophisticated email validation here
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            icon: Icons.phone,
                            hintText: 'Phone',
                            onSaved: (value) => _phone = value!,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
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
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters long';
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
                                'Register',
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
        final CustomUser? user = await authService.registerWithEmailAndPassword(
          _email,
          _password,
          _name,
          _phone
        );
        if (user != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register: ${e.toString()}'),
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
                        'Already have an account? Login',
                        style: TextStyle(color: Colors.white),
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