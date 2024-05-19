import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_management_app/models/user.dart' as AppUser;
import 'package:business_management_app/services/user_service.dart';
import 'package:business_management_app/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  AppUser.User? _user;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _profileImageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    AppUser.User? user = await _userService.getCurrentUser();
    setState(() {
      _user = user;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _whatsappController.text = user.whatsapp ?? '';
        _descriptionController.text = user.description ?? '';
        _profileImageController.text = user.profileImage ?? '';
      }
    });
  }

  void _saveProfile() async {
    if (_user != null) {
      AppUser.User updatedUser = AppUser.User(
        id: _user!.id,
        name: _nameController.text,
        email: _emailController.text,
        role: _user!.role,
        companyId: _user!.companyId,
        whatsapp: _whatsappController.text,
        description: _descriptionController.text,
        profileImage: _profileImageController.text,
      );
      await _userService.updateUser(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.rubik()),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_emailController, 'Email', readOnly: true),
              _buildTextField(_whatsappController, 'WhatsApp'),
              _buildTextField(_descriptionController, 'Description'),
              _buildTextField(_profileImageController, 'Profile Image URL'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD97757),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  textStyle: GoogleFonts.rubik(fontSize: 18),
                ),
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
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
