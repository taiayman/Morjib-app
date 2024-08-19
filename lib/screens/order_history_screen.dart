import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import './order_tracking_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Order History',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: userId == null
          ? Center(
              child: Text(
                'Please log in to view order history',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            )
          : FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _firestoreService.getOrderHistory(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00CCBC))));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No orders found',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16),
                  itemBuilder: (ctx, i) {
                    var order = snapshot.data![i].data() as Map<String, dynamic>;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Order #${_truncateOrderId(snapshot.data![i].id)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 8),
                                _buildStatusChip(order['status']),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Date: ${_formatDate(order['created_at'].toDate())}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${order['total_amount'].toStringAsFixed(2)} MAD',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00CCBC),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderTrackingScreen(orderId: snapshot.data![i].id),
                                  ),
                                );
                              },
                              child: Text(
                                'View Details',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF00CCBC),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'processing':
        chipColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'shipped':
        chipColor = Colors.amber[100]!;
        textColor = Colors.amber[800]!;
        statusIcon = Icons.local_shipping;
        break;
      case 'delivered':
        chipColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        chipColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        statusIcon = Icons.cancel;
        break;
      default:
        chipColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: textColor),
          SizedBox(width: 4),
          Text(
            status,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _truncateOrderId(String orderId) {
    return (orderId.length <= 8) ? orderId : '${orderId.substring(0, 8)}...';
  }
}