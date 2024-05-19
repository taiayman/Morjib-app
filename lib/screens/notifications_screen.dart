import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.rubik(fontSize: 20)),
        backgroundColor: Color(0xFFD97757),
        // Remove the back button
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          'Notifications Screen Placeholder',
          style: GoogleFonts.rubik(fontSize: 24),
        ),
      ),
    );
  }
}