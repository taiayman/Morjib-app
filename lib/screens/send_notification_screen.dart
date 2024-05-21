import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:business_management_app/models/notification.dart' as CustomNotification;
import 'package:business_management_app/services/notification_service.dart';
import 'package:business_management_app/services/user_service.dart';

class SendNotificationScreen extends StatefulWidget {
  final String ceoName;
  final String companyName;

  SendNotificationScreen({required this.ceoName, required this.companyName});

  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _notificationController = TextEditingController();
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();

  void _sendNotification() async {
    final notificationMessage = _notificationController.text;
    print('Sending notification from ${widget.ceoName} of ${widget.companyName}');

    final currentUser = await _userService.getCurrentUser();

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found')),
      );
      return;
    }

    final senderId = currentUser.id; // Assuming getCurrentUser() returns a User object with an id field

    final notification = CustomNotification.Notification(
      id: Uuid().v4(),
      ceoName: widget.ceoName,
      companyName: widget.companyName,
      date: DateTime.now(),
      message: notificationMessage,
      senderId: senderId, // Automatically get the senderId from the current user
    );

    await _notificationService.addNotification(notification);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('Send a Notification', style: GoogleFonts.nunito()),
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
                labelStyle: GoogleFonts.nunito(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 5,
              style: GoogleFonts.nunito(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97757),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                textStyle: GoogleFonts.nunito(fontSize: 18),
              ),
              child: Text('Send Notification', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
