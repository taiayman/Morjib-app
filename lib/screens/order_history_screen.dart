import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import './order_tracking_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class CarrefourColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class OrderHistoryScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: CarrefourColors.background,
      appBar: AppBar(
        title: Text(
          'Order History',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: CarrefourColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: userId == null
          ? Center(
              child: Text(
                'Please log in',
                style: GoogleFonts.poppins(fontSize: 16, color: CarrefourColors.textDark),
              ),
            )
          : FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _firestoreService.getOrderHistory(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CarrefourColors.primary)));
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
                      style: GoogleFonts.poppins(fontSize: 16, color: CarrefourColors.textDark),
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
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CarrefourColors.secondary.withOpacity(0.1),
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
                                    'Order #${snapshot.data![i].id}',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: CarrefourColors.textDark,
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
                              _formatDate(order['created_at'].toDate()),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: CarrefourColors.textLight,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${order['total_amount'].toStringAsFixed(2)} MAD',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: CarrefourColors.primary,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: CarrefourColors.accent.withOpacity(0.5),
                                    offset: Offset(0, 4),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
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
                                  backgroundColor: CarrefourColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  minimumSize: Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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
        chipColor = CarrefourColors.primary.withOpacity(0.1);
        textColor = CarrefourColors.primary;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'shipped':
        chipColor = CarrefourColors.accent.withOpacity(0.1);
        textColor = CarrefourColors.accent;
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
    return DateFormat('dd/MM/yyyy').format(date);
  }
}