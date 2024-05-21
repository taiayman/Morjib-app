import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_management_app/models/notification.dart' as CustomNotification;
import 'package:business_management_app/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback onNotificationsRead;
  final bool isDarkTheme;

  NotificationsScreen({required this.onNotificationsRead, required this.isDarkTheme});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<CustomNotification.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      List<CustomNotification.Notification> notifications = await _notificationService.getAllNotifications();
      setState(() {
        _notifications = notifications;
      });

      // Mark all notifications as read
      for (var notification in notifications) {
        if (!notification.isRead) {
          await _notificationService.markNotificationAsRead(notification.id);
        }
      }

      // Call the callback to update the boss dashboard state
      widget.onNotificationsRead();
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      setState(() {
        _notifications.removeWhere((notification) => notification.id == notificationId);
      });
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkTheme ? Colors.white : Colors.black;
    final subtitleColor = widget.isDarkTheme ? Colors.grey[400] : Colors.grey;

    return Scaffold(
      appBar: AppBar(
  title: Text('Notifications', style: GoogleFonts.nunito(color: Colors.white)), // Change text color to white
  backgroundColor: Color(0xFFD97757),
  automaticallyImplyLeading: false, // Remove the back icon
),
      backgroundColor: widget.isDarkTheme ? Color(0xFF2c2b28) : Color(0xFFF2F0E8),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Card(
            color: widget.isDarkTheme ? Color(0xFF393937) : Colors.white,
            margin: EdgeInsets.all(8.0),
            child: FutureBuilder(
              future: _notificationService.getSenderDetails(notification.senderId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text('Loading...', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  );
                } else if (snapshot.hasError) {
                  return ListTile(
                    title: Text(
                      'Unknown Sender',
                      style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.message, style: GoogleFonts.nunito(fontSize: 16, color: textColor)),
                        Text(notification.date.toLocal().toString(), style: GoogleFonts.nunito(fontSize: 14, color: subtitleColor)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteNotification(notification.id);
                      },
                    ),
                  );
                } else {
                  var senderDetails = snapshot.data as Map<String, String>?;
                  return Stack(
                    children: [
                      ListTile(
                        title: Text(senderDetails?['name'] ?? 'Unknown', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(senderDetails?['company'] ?? 'Unknown', style: GoogleFonts.nunito(fontSize: 16, color: textColor)),
                            Text(notification.message, style: GoogleFonts.nunito(fontSize: 16, color: textColor)),
                            Text(notification.date.toLocal().toString(), style: GoogleFonts.nunito(fontSize: 14, color: subtitleColor)),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteNotification(notification.id);
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}