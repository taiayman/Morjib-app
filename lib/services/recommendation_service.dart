import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getRecommendations(String userId) async {
    // Get user's purchase history
    QuerySnapshot purchaseHistory = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    // Get user's viewed products
    QuerySnapshot viewedProducts = await _firestore
        .collection('users')
        .doc(userId)
        .collection('viewed_products')
        .get();

    // Combine and process the data to generate recommendations
    Set<String> recommendedProductIds = await _generateRecommendations(purchaseHistory, viewedProducts);

    // Fetch the actual product details
    List<Product> recommendations = await _fetchProductDetails(recommendedProductIds);

    return recommendations;
  }

  Future<Set<String>> _generateRecommendations(QuerySnapshot purchases, QuerySnapshot viewed) async {
    Set<String> recommendedProductIds = {};
    Map<String, int> categoryScores = {};

    // Process purchase history
    for (var doc in purchases.docs) {
      List<dynamic> items = doc['items'];
      for (var item in items) {
        String category = item['category'];
        categoryScores[category] = (categoryScores[category] ?? 0) + 3; // Higher weight for purchased items
      }
    }

    // Process viewed products
    for (var doc in viewed.docs) {
      String category = doc['category'];
      categoryScores[category] = (categoryScores[category] ?? 0) + 1;
    }

    // Get top categories
    var sortedCategories = categoryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Get products from top categories
    for (var entry in sortedCategories.take(5)) {
      QuerySnapshot categoryProducts = await _firestore
          .collection('products')
          .where('category', isEqualTo: entry.key)
          .orderBy('popularity', descending: true)
          .limit(10)
          .get();
      recommendedProductIds.addAll(categoryProducts.docs.map((doc) => doc.id));
    }

    // Add some popular products across all categories
    QuerySnapshot popularProducts = await _firestore
        .collection('products')
        .orderBy('popularity', descending: true)
        .limit(5)
        .get();
    recommendedProductIds.addAll(popularProducts.docs.map((doc) => doc.id));

    return recommendedProductIds;
  }

  Future<List<Product>> _fetchProductDetails(Set<String> productIds) async {
    List<Product> products = [];
    for (String id in productIds) {
      DocumentSnapshot doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        products.add(Product.fromMap(doc.data() as Map<String, dynamic>));
      }
    }
    return products;
  }

  Future<void> recordProductView(String userId, String productId, String category) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('viewed_products')
        .doc(productId)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
      'category': category,
    });
  }

  Future<void> updateProductPopularity(String productId) async {
    await _firestore.collection('products').doc(productId).update({
      'popularity': FieldValue.increment(1),
    });
  }
}