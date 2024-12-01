import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/traditional_market.dart';
import 'dart:math' as math;


class TraditionalMarketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all traditional markets
  Stream<List<TraditionalMarket>> getTraditionalMarkets() {
    return _firestore
        .collection('traditional_markets')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TraditionalMarket.fromFirestore(doc))
            .toList());
  }

  // Get a specific market
  Future<TraditionalMarket?> getMarketById(String marketId) async {
    DocumentSnapshot doc = await _firestore
        .collection('traditional_markets')
        .doc(marketId)
        .get();
    if (doc.exists) {
      return TraditionalMarket.fromFirestore(doc);
    }
    return null;
  }

  // Fetch categories for a specific market
  Stream<QuerySnapshot> getMarketCategories(String marketId) {
    return _firestore
        .collection('traditional_markets')
        .doc(marketId)
        .collection('categories')
        .snapshots();
  }

  // Fetch products for a specific category in a market
  Stream<QuerySnapshot> getMarketProductsByCategory(
      String marketId, String categoryId) {
    return _firestore
        .collection('market_products')
        .where('marketId', isEqualTo: marketId)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots();
  }

  // Search products across all markets
  Future<List<QueryDocumentSnapshot>> searchMarketProducts(String query) async {
    QuerySnapshot querySnapshot = await _firestore
        .collectionGroup('products')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();
    return querySnapshot.docs;
  }

  // Get featured markets
  Stream<List<TraditionalMarket>> getFeaturedMarkets() {
    return _firestore
        .collection('traditional_markets')
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TraditionalMarket.fromFirestore(doc))
            .toList());
  }

  // Get markets by location
  Future<List<TraditionalMarket>> getMarketsByLocation(
      GeoPoint location, double radiusInKm) async {
    // Note: This is a simple implementation. For production, 
    // you should use geohashing or a proper geospatial query
    QuerySnapshot querySnapshot = await _firestore
        .collection('traditional_markets')
        .get();

    List<TraditionalMarket> nearbyMarkets = [];
    for (var doc in querySnapshot.docs) {
      TraditionalMarket market = TraditionalMarket.fromFirestore(doc);
      double distance = _calculateDistance(
        location.latitude,
        location.longitude,
        market.coordinates.latitude,
        market.coordinates.longitude,
      );
      if (distance <= radiusInKm) {
        nearbyMarkets.add(market);
      }
    }
    return nearbyMarkets;
  }

  // Helper method to calculate distance between two points
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // Implementation of Haversine formula
    // Returns distance in kilometers
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  // Rate a market
  Future<void> rateMarket(
      String marketId, String userId, double rating, String? comment) async {
    await _firestore
        .collection('traditional_markets')
        .doc(marketId)
        .collection('ratings')
        .doc(userId)
        .set({
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update market's average rating
    await _updateMarketAverageRating(marketId);
  }

  Future<void> _updateMarketAverageRating(String marketId) async {
    QuerySnapshot ratingsSnapshot = await _firestore
        .collection('traditional_markets')
        .doc(marketId)
        .collection('ratings')
        .get();

    if (ratingsSnapshot.docs.isEmpty) return;

    double totalRating = 0;
    ratingsSnapshot.docs.forEach((doc) {
      totalRating += (doc.data() as Map<String, dynamic>)['rating'] as double;
    });

    double averageRating = totalRating / ratingsSnapshot.docs.length;

    await _firestore.collection('traditional_markets').doc(marketId).update({
      'rating': averageRating,
      'ratingCount': ratingsSnapshot.docs.length,
    });
  }

  Stream<QuerySnapshot> getCategories() {
    return FirebaseFirestore.instance
        .collection('categories')
        .orderBy('name')
        .snapshots();
  }

  Stream<QuerySnapshot> getMarketProducts(String marketId) {
    return _firestore
        .collection('market_products')
        .where('marketId', isEqualTo: marketId)
        .snapshots();
  }

  Future<void> addProductToMarket(String marketId, Map<String, dynamic> productData) async {
    await _firestore.collection('market_products').add({
      ...productData,
      'marketId': marketId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMarketProduct(String productId, Map<String, dynamic> productData) async {
    await _firestore
        .collection('market_products')
        .doc(productId)
        .update(productData);
  }

  Future<void> deleteMarketProduct(String productId) async {
    await _firestore
        .collection('market_products')
        .doc(productId)
        .delete();
  }
}