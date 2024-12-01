import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import 'package:easy_localization/easy_localization.dart';

class CarrefourColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final FirestoreService _firestoreService = FirestoreService();

  OrderConfirmationScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarrefourColors.background,
      appBar: AppBar(
        title: Text(
          'order_confirmation'.tr(),
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: CarrefourColors.primary,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _firestoreService.getOrderDetails(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: CarrefourColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('error_message'.tr(args: [snapshot.error.toString()]), style: GoogleFonts.poppins(color: Colors.red)));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('no_order_data'.tr(), style: GoogleFonts.poppins(color: CarrefourColors.textDark)));
          }

          var orderData = snapshot.data!.data() as Map<String, dynamic>;
          int pointsEarned = (orderData['total_amount'] / 10).floor();

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'thank_you'.tr(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: CarrefourColors.primary,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInfoCard(
                    title: 'order_details'.tr(),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('order_id'.tr(), orderId),
                        _buildInfoRow('status'.tr(), orderData['status']),
                        _buildInfoRow('total_amount'.tr(), '${orderData['total_amount'].toStringAsFixed(2)} MAD'),
                        _buildInfoRow('points_earned'.tr(), '$pointsEarned', isHighlighted: true),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'order_items'.tr(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CarrefourColors.textDark,
                    ),
                  ),
                  SizedBox(height: 10),
                  ...(orderData['items'] as List).map((item) => _buildOrderItemCard(item)).toList(),
                  SizedBox(height: 20),
                  _buildBackToHomeButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget content}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CarrefourColors.primary,
              ),
            ),
            Divider(color: CarrefourColors.accent, thickness: 1),
            SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 16, color: CarrefourColors.textLight)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? CarrefourColors.accent : CarrefourColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        title: Text(
          item['product_name'],
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: CarrefourColors.textDark),
        ),
        subtitle: Text(
          'quantity'.tr(args: [item['quantity'].toString()]),
          style: GoogleFonts.poppins(color: CarrefourColors.textLight),
        ),
        trailing: Text(
          '${(item['price'] * item['quantity']).toStringAsFixed(2)} MAD',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: CarrefourColors.primary),
        ),
      ),
    );
  }

  Widget _buildBackToHomeButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        child: Text(
          'back_to_home'.tr(),
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: CarrefourColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/');
        },
      ),
    );
  }
}