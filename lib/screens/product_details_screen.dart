import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_delivery_app/screens/add_review_screen.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/review_service.dart';
import '../widgets/review_list_item.dart';

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
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestoreService.getProductDetails(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Product not found'));
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
                      Text(productData['name'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('${productData['price']} MAD', style: TextStyle(fontSize: 18, color: Colors.green)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          Text(
                            ' ${(productData['averageRating'] ?? 0).toStringAsFixed(1)} ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '(${productData['numberOfReviews'] ?? 0} reviews)',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(productData['description']),
                      SizedBox(height: 24),
                      Text('Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      FutureBuilder<List<Review>>(
                        future: _reviewService.getProductReviews(widget.productId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error loading reviews'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No reviews yet');
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
              child: Icon(Icons.rate_review),
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
