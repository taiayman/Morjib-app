import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:business_management_app/models/notification.dart';

class NotificationService {
  final CollectionReference _notificationCollection = FirebaseFirestore.instance.collection('notifications');
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');

  Future<List<Notification>> getAllNotifications() async {
    QuerySnapshot querySnapshot = await _notificationCollection.get();
    return querySnapshot.docs.map((doc) => Notification.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationCollection.doc(notificationId).update({'isRead': true});
  }

  Future<Map<String, String>?> getSenderDetails(String senderId) async {
    DocumentSnapshot senderDoc = await _userCollection.doc(senderId).get();
    if (senderDoc.exists) {
      var data = senderDoc.data() as Map<String, dynamic>;
      return {
        'name': data['name'] ?? 'Unknown',
        'company': data['company'] ?? 'Unknown',
      };
    } else {
      return null;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationCollection.doc(notificationId).delete();
  }

  Future<void> addNotification(Notification notification) async {
    await _notificationCollection.doc(notification.id).set(notification.toMap());
  }
}
