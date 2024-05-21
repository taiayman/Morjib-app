import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_management_app/models/user.dart';
import 'package:url_launcher/url_launcher.dart';

class CEOProfileScreen extends StatelessWidget {
  final User ceo;
  final bool isDarkTheme;

  CEOProfileScreen({required this.ceo, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkTheme ? Color(0xFF2C2B28) : Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('CEO Profile', style: GoogleFonts.nunito(color: Colors.white)),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(ceo.profileImage),
              ),
            ),
            SizedBox(height: 16),
            Text(
              ceo.name,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Email: ${ceo.email}',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'WhatsApp: ${ceo.whatsapp}',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: isDarkTheme ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _sendEmail(ceo.email);
              },
              icon: Icon(Icons.email, color: Colors.white),
              label: Text('Email', style: GoogleFonts.nunito(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97757),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                textStyle: GoogleFonts.nunito(fontSize: 18),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _openWhatsApp(ceo.whatsapp);
              },
              icon: Icon(Icons.message, color: Colors.white),
              label: Text('WhatsApp', style: GoogleFonts.nunito(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97757),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                textStyle: GoogleFonts.nunito(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmail(String email) {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    launch(emailUri.toString());
  }

  void _openWhatsApp(String phone) {
    final Uri whatsappUri = Uri(
      scheme: 'https',
      path: 'api.whatsapp.com/send',
      queryParameters: {'phone': phone},
    );
    launch(whatsappUri.toString());
  }
}
