import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Support'),
      ),
      body: userId == null
          ? Center(child: Text('Please log in to access customer support'))
          : FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _firestoreService.getUserChats(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No chat history'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var chat = snapshot.data![index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text('Chat ${index + 1}'),
                      subtitle: Text('Status: ${chat['status']}'),
                      trailing: Text(chat['createdAt'].toDate().toString().substring(0, 16)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(chatId: snapshot.data![index].id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat),
        onPressed: () async {
          try {
            String chatId = await _chatService.createNewChat();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(chatId: chatId),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating new chat: $e')),
            );
          }
        },
      ),
    );
  }
}