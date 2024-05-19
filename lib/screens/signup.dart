import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_management_app/services/auth_service.dart';
import 'package:business_management_app/services/user_service.dart';
import 'package:business_management_app/models/user.dart';
import 'package:business_management_app/models/company.dart';
import 'package:business_management_app/services/company_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _profileImageController = TextEditingController(); // Assume URL for simplicity
  final CompanyService _companyService = CompanyService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  String _selectedCompanyId = '';
  List<Company> _companies = [];

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    List<Company> companies = await _companyService.getAllCompanies();
    setState(() {
      _companies = companies;
    });
  }

  void _signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;
    final whatsapp = _whatsappController.text;
    final description = _descriptionController.text;
    final profileImage = _profileImageController.text;

    if (_selectedCompanyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a company')),
      );
      return;
    }

    bool success = await _authService.signUp(email, password);
    if (success) {
      User newUser = User(
        id: _authService.getCurrentUser()!.uid,
        name: name,
        email: email,
        role: 'CEO',
        companyId: _selectedCompanyId,
        whatsapp: whatsapp,
        description: description,
        profileImage: profileImage,
      );
      await _userService.addUser(newUser);
      // Navigate to CEO Dashboard
      Navigator.pushReplacementNamed(context, '/ceo_dashboard');
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('Sign Up', style: GoogleFonts.rubik()),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_emailController, 'Email'),
              _buildTextField(_passwordController, 'Password', obscureText: true),
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_whatsappController, 'WhatsApp'),
              _buildTextField(_descriptionController, 'Description'),
              _buildTextField(_profileImageController, 'Profile Image URL'),
              _buildDropdown(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD97757),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  textStyle: GoogleFonts.rubik(fontSize: 18),
                ),
                child: Text('Sign Up', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
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

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCompanyId.isNotEmpty ? _selectedCompanyId : null,
        hint: Text('Select Company', style: GoogleFonts.rubik()),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: _companies.map((Company company) {
          return DropdownMenuItem<String>(
            value: company.id,
            child: Text(company.name, style: GoogleFonts.rubik()),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCompanyId = newValue!;
          });
        },
      ),
    );
  }
}
