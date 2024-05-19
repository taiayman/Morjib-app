import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SendNotificationScreen extends StatefulWidget {
  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _notificationController = TextEditingController();

  void _sendNotification() {
    final notification = _notificationController.text;
    // Implement notification sending logic here
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('Send a Notification', style: GoogleFonts.rubik()),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _notificationController,
              decoration: InputDecoration(
                labelText: 'Notification message',
                labelStyle: GoogleFonts.rubik(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 5,
              style: GoogleFonts.rubik(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97757),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                textStyle: GoogleFonts.rubik(fontSize: 18),
              ),
              child: Text('Send Notification', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
