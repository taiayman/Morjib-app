import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_delivery_app/screens/add_review_screen.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/review_service.dart';
import '../widgets/review_list_item.dart';
import 'package:easy_localization/easy_localization.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  ProductDetailsScreen({required this.productId});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ReviewService _reviewService = ReviewService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: CarrefourColors.background,
      appBar: AppBar(
        title: Text(
          'product_details'.tr(),
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
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestoreService.getProductDetails(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CarrefourColors.primary)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('error_message'.tr(args: [snapshot.error.toString()]), style: GoogleFonts.poppins(color: Colors.red, fontSize: 16)));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('product_not_found'.tr()));
          }

          var productData = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(productData['image_url'], height: 200, width: double.infinity, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productData['name'],
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: CarrefourColors.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${productData['price']} MAD',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CarrefourColors.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: CarrefourColors.accent),
                          Text(
                            ' ${(productData['averageRating'] ?? 0).toStringAsFixed(1)} ',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CarrefourColors.textDark,
                            ),
                          ),
                          Text(
                            '(${productData['numberOfReviews'] ?? 0} ${'reviews'.tr()})',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: CarrefourColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        productData['description'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: CarrefourColors.textDark,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'reviews'.tr(),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CarrefourColors.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      FutureBuilder<List<Review>>(
                        future: _reviewService.getProductReviews(widget.productId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CarrefourColors.primary)));
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('error_loading_reviews'.tr(), style: GoogleFonts.poppins(color: Colors.red, fontSize: 16)));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('no_reviews_yet'.tr(), style: GoogleFonts.poppins(color: CarrefourColors.textLight, fontSize: 16));
                          }
                          return Column(
                            children: snapshot.data!.map((review) => ReviewListItem(review: review)).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: userId != null
          ? FloatingActionButton(
              child: Icon(Icons.rate_review, color: Colors.white),
              backgroundColor: CarrefourColors.primary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddReviewScreen(productId: widget.productId),
                  ),
                );
              },
            )
          : null,
    );
  }
}

class CarrefourColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}
