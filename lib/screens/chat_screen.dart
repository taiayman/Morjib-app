import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chat_service.dart';
import 'package:easy_localization/easy_localization.dart';

class CarrefourColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class ChatScreen extends StatefulWidget {
  final String orderId;

  ChatScreen({required this.orderId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'chat_order'.tr(args: [widget.orderId]),
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: CarrefourColors.primary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: CarrefourColors.background,
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: chatService.getChatMessages(widget.orderId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('error_message'.tr(args: [snapshot.error.toString()])));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: CarrefourColors.primary));
                  }
                  final messages = snapshot.data ?? [];
                  return ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(messages[index]);
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(chatService),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isCurrentUser = message['isUser'];
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isCurrentUser ? CarrefourColors.primary.withOpacity(0.2) : CarrefourColors.accent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['sender'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isCurrentUser ? CarrefourColors.primary : CarrefourColors.accent,
              ),
            ),
            SizedBox(height: 4),
            Text(
              message['text'],
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: CarrefourColors.textDark,
              ),
            ),
            SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message['timestamp'].toDate()),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: CarrefourColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(ChatService chatService) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: CarrefourColors.secondary.withOpacity(0.1),
            offset: Offset(0, -2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'type_message'.tr(),
                hintStyle: GoogleFonts.poppins(
                  color: CarrefourColors.textLight,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: CarrefourColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: CarrefourColors.primary, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              style: GoogleFonts.poppins(
                color: CarrefourColors.textDark,
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CarrefourColors.primary,
              boxShadow: [
                BoxShadow(
                  color: CarrefourColors.accent.withOpacity(0.5),
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendMessage(chatService),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatService chatService) {
    if (_messageController.text.isNotEmpty) {
      chatService.sendMessage(widget.orderId, _messageController.text);
      _messageController.clear();
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}