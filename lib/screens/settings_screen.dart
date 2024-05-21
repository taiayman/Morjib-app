import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_management_app/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final bool isDarkTheme;

  SettingsScreen({required this.onThemeChanged, required this.isDarkTheme});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    // Here, you would also update the notification settings
  }

  void _logout() async {
    await _authService.logout();
    await _storage.delete(key: 'userToken');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkTheme ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: widget.isDarkTheme ? Color(0xFF2C2B28) : Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.nunito(color: Colors.white)),
        backgroundColor: Color(0xFFD97757),
        automaticallyImplyLeading: false, // Remove the back icon
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text(
                'Dark Theme',
                style: GoogleFonts.nunito(fontSize: 18, color: textColor),
              ),
              trailing: Switch(
                value: widget.isDarkTheme,
                onChanged: (value) {
                  widget.onThemeChanged();
                },
                activeColor: Color(0xFFD97757),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Enable Notifications',
                style: GoogleFonts.nunito(fontSize: 18, color: textColor),
              ),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: Color(0xFFD97757),
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Account',
                style: GoogleFonts.nunito(fontSize: 18, color: textColor),
              ),
              onTap: () {
                // Navigate to account management screen
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Privacy Policy',
                style: GoogleFonts.nunito(fontSize: 18, color: textColor),
              ),
              onTap: () {
                // Navigate to privacy policy screen
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Logout',
                style: GoogleFonts.nunito(fontSize: 18, color: textColor),
              ),
              trailing: Icon(Icons.logout, color: Color(0xFFD97757)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
