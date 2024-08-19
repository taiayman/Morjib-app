import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final chatService = Provider.of<ChatService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Chats'),
        backgroundColor: Colors.teal,
      ),
      body: userId == null
          ? Center(child: Text('Please log in to view your chats'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('userId', isEqualTo: userId)
                  .orderBy('lastMessageTimestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No active chats'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var chatData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    var chatId = snapshot.data!.docs[index].id;
                    return _buildChatListItem(context, chatData, chatId, chatService);
                  },
                );
              },
            ),
    );
  }

  Widget _buildChatListItem(BuildContext context, Map<String, dynamic> chatData, String chatId, ChatService chatService) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(Icons.chat, color: Colors.white),
        ),
        title: Text('Order #${chatData['orderId']}'),
        subtitle: FutureBuilder<String>(
          future: chatService.getLastMessage(chatId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            }
            return Text(
              snapshot.data ?? 'No messages yet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        trailing: chatData['unreadCount'] > 0
            ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  '${chatData['unreadCount']}',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(orderId: chatData['orderId']),
            ),
          );
        },
      ),
    );
  }
}