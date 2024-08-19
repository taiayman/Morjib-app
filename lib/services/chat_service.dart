import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getChatMessages(String orderId) {
    return _firestore
        .collection('chats')
        .doc(orderId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'text': data['message'],
          'sender': data['senderName'],
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
          'isUser': data['senderId'] == _auth.currentUser?.uid,
        };
      }).toList();
    });
  }

  Future<void> sendMessage(String orderId, String message) async {
    final user = _auth.currentUser;
    if (user != null) {
      final messageData = {
        'senderId': user.uid,
        'senderName': user.displayName ?? 'User',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('chats').doc(orderId).collection('messages').add(messageData);

      await _firestore.collection('chats').doc(orderId).update({
        'lastMessage': message,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadCount': FieldValue.increment(1),
      });
    }
  }

  Future<String> getLastMessage(String chatId) async {
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['message'];
    } else {
      return 'No messages yet';
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount': 0,
    });
  }
}