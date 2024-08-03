import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(String chatId, String message) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': user.uid,
        'senderName': user.displayName ?? 'User',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<String> createNewChat() async {
    final user = _auth.currentUser;
    if (user != null) {
      final chatDoc = await _firestore.collection('chats').add({
        'userId': user.uid,
        'userEmail': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'open',
      });
      return chatDoc.id;
    }
    throw Exception('User not authenticated');
  }

  Stream<DocumentSnapshot> getChatStatus(String chatId) {
    return _firestore.collection('chats').doc(chatId).snapshots();
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}