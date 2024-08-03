import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Support'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return MessageBubble(
                      message: data['message'],
                      isMe: data['senderId'] == _chatService.getCurrentUserId(),
                      senderName: data['senderName'],
                    );
                  }).toList(),
                );
              },
            ),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream: _chatService.getChatStatus(widget.chatId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                var chatData = snapshot.data!.data() as Map<String, dynamic>;
                if (chatData['status'] == 'closed') {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('This chat has been closed by the support team.',
                      style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                    ),
                  );
                }
              }
              return Container();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _chatService.sendMessage(widget.chatId, _messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String senderName;

  MessageBubble({required this.message, required this.isMe, required this.senderName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(senderName, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Material(
            color: isMe ? Colors.blue[200] : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Text(message),
            ),
          ),
        ],
      ),
    );
  }
}