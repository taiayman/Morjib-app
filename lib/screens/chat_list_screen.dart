import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class CarrefourColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final chatService = Provider.of<ChatService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: CarrefourColors.background,
      appBar: AppBar(
        title: Text(
          'my_chats'.tr(),
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: CarrefourColors.primary,
        elevation: 0,
      ),
      body: userId == null
          ? _buildLoginPrompt()
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('userId', isEqualTo: userId)
                  .orderBy('lastMessageTimestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: CarrefourColors.primary));
                }
                if (snapshot.hasError) {
                  return _buildErrorMessage(snapshot.error.toString());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildNoChatsMessage();
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

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: CarrefourColors.accent),
          SizedBox(height: 20),
          Text(
            'login_to_view_chats'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: CarrefourColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: CarrefourColors.accent),
          SizedBox(height: 20),
          Text(
            'error'.tr(args: [error]),
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: CarrefourColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoChatsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: CarrefourColors.accent),
          SizedBox(height: 20),
          Text(
            'no_active_chats'.tr(),
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              color: CarrefourColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'chat_history_appear_here'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: CarrefourColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListItem(BuildContext context, Map<String, dynamic> chatData, String chatId, ChatService chatService) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: CarrefourColors.accent,
          child: Icon(Icons.chat, color: Colors.white),
        ),
        title: Text(
          'order_number'.tr(args: [chatData['orderId']]),
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CarrefourColors.textDark,
          ),
        ),
        subtitle: FutureBuilder<String>(
          future: chatService.getLastMessage(chatId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                'loading'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: CarrefourColors.textLight,
                ),
              );
            }
            return Text(
              snapshot.data ?? 'no_messages_yet'.tr(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: CarrefourColors.textLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        trailing: chatData['unreadCount'] > 0
            ? Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CarrefourColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${chatData['unreadCount']}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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