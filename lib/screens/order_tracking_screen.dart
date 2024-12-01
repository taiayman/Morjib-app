import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/order_service.dart';
import '../services/chat_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:timeline_tile/timeline_tile.dart';

class CarrefourColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  OrderTrackingScreen({required this.orderId});

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarrefourColors.background,
      appBar: AppBar(
        backgroundColor: CarrefourColors.primary,
        elevation: 0,
        title: Text(
          'order_tracking'.tr(),
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _orderService.getOrderStream(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: CarrefourColors.primary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'error_message'.tr(args: [snapshot.error.toString()]),
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'order_not_found'.tr(),
                style: GoogleFonts.poppins(fontSize: 18, color: CarrefourColors.textDark),
              ),
            );
          }

          final orderData = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildStatusTimeline(orderData['status']),
                _buildOrderInfoCard(orderData),
                _buildQRCodeSection(orderData),
                _buildChatSection(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildMessageInput(),
    );
  }

  Widget _buildStatusTimeline(String status) {
    final List<String> statuses = ['Pending', 'Preparing', 'On the Way', 'Delivered'];
    final int currentIndex = statuses.indexOf(status);

    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width / 4,
            child: TimelineTile(
              axis: TimelineAxis.horizontal,
              alignment: TimelineAlign.center,
              isFirst: index == 0,
              isLast: index == statuses.length - 1,
              indicatorStyle: IndicatorStyle(
                width: 20,
                color: index <= currentIndex ? CarrefourColors.primary : Colors.grey,
                padding: EdgeInsets.all(6),
              ),
              endChild: _buildTimelineContent(statuses[index], index <= currentIndex),
              beforeLineStyle: LineStyle(
                color: index < currentIndex ? CarrefourColors.primary : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineContent(String title, bool isActive) {
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: isActive ? CarrefourColors.primary : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOrderInfoCard(Map<String, dynamic> orderData) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Details',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CarrefourColors.textDark,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow(Icons.confirmation_number, 'Order ID', widget.orderId),
            _buildInfoRow(Icons.attach_money, 'Total Amount', '${orderData['total_amount'] ?? 'N/A'} MAD'),
            _buildInfoRow(Icons.location_on, 'Delivery Address', orderData['address'] ?? 'Not provided'),
            _buildInfoRow(Icons.access_time, 'Order Date', _formatTimestamp(orderData['created_at'])),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: CarrefourColors.primary, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: CarrefourColors.textLight,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CarrefourColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection(Map<String, dynamic> orderData) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'order_qr_code'.tr(),
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CarrefourColors.textDark,
              ),
            ),
            SizedBox(height: 16),
            FutureBuilder<String>(
              future: _orderService.generateOrderQR(widget.orderId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(color: CarrefourColors.primary);
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text('error_generating_qr'.tr());
                }
                return QrImageView(
                  data: snapshot.data!,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'show_qr_to_delivery_person'.tr(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: CarrefourColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSection() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 300,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Chat with Support',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CarrefourColors.textDark,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _chatService.getChatMessages(widget.orderId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('error_message'.tr(args: [snapshot.error.toString()])));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: CarrefourColors.primary));
                  }
                  final messages = snapshot.data ?? [];
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(messages[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'];
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(
          color: isUser ? CarrefourColors.primary : CarrefourColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message['text'],
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isUser ? Colors.white : CarrefourColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: CarrefourColors.primary,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'unknown';
    return DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _chatService.sendMessage(widget.orderId, _messageController.text);
      _messageController.clear();
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}