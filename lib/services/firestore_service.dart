import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_delivery_app/models/product.dart';
import 'package:my_delivery_app/models/restaurant.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   Future<void> createUser(String uid, String email, String name, String phone) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'phone': phone,
      'points': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>> getUser(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return doc.data() as Map<String, dynamic>;
  }


  Future<List<QueryDocumentSnapshot>> searchProducts(String query) async {
    QuerySnapshot querySnapshot = await _firestore.collection('products')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();
    return querySnapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getSupermarkets() async {
    QuerySnapshot querySnapshot = await _firestore.collection('supermarkets').get();
    return querySnapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getShops() async {
    QuerySnapshot querySnapshot = await _firestore.collection('shops').get();
    return querySnapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getTraditionalMarketCategories() async {
    QuerySnapshot querySnapshot = await _firestore.collection('traditional_market_categories').get();
    return querySnapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getProducts({String? category, required String sellerType}) async {
    Query query = _firestore.collection('products').where('sellerType', isEqualTo: sellerType);
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs;
  }

  Future<String> createOrder(String userId, double totalAmount, List<Map<String, dynamic>> orderItems, {required String status, String? paymentIntentId}) async {
    DocumentReference orderRef = await _firestore.collection('orders').add({
      'user_id': userId,
      'total_amount': totalAmount,
      'status': status,
      'payment_intent_id': paymentIntentId,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
      'items': orderItems,
    });

    // Calculate and add loyalty points (1 point per 10 MAD spent)
    int pointsEarned = (totalAmount / 10).floor();
    await addPoints(userId, pointsEarned);

    return orderRef.id;
  }

  // Favorites methods
  Future<void> addToFavorites(String userId, String productId) async {
    await _firestore.collection('users').doc(userId).collection('favorites').doc(productId).set({
      'added_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFromFavorites(String userId, String productId) async {
    await _firestore.collection('users').doc(userId).collection('favorites').doc(productId).delete();
  }

  Future<List<QueryDocumentSnapshot>> getFavorites(String userId) async {
    QuerySnapshot favoritesSnapshot = await _firestore.collection('users').doc(userId).collection('favorites').get();
    List<String> favoriteProductIds = favoritesSnapshot.docs.map((doc) => doc.id).toList();
    
    if (favoriteProductIds.isEmpty) {
      return [];
    }

    QuerySnapshot productsSnapshot = await _firestore.collection('products')
        .where(FieldPath.documentId, whereIn: favoriteProductIds)
        .get();
    
    return productsSnapshot.docs;
  }

  Future<bool> isFavorite(String userId, String productId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).collection('favorites').doc(productId).get();
    return doc.exists;
  }

  // Order history methods
  Future<List<QueryDocumentSnapshot>> getOrderHistory(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('orders')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();
    return querySnapshot.docs;
  }

  Future<DocumentSnapshot> getOrderDetails(String orderId) async {
    return await _firestore.collection('orders').doc(orderId).get();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Fetch the user ID associated with this order
    DocumentSnapshot orderDoc = await _firestore.collection('orders').doc(orderId).get();
    String userId = orderDoc['user_id'];

    // Fetch the user's FCM tokens
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    List<String> fcmTokens = List<String>.from(userDoc['fcm_tokens'] ?? []);

    // Send notifications to all user devices
    for (String token in fcmTokens) {
      await sendNotification(token, 'Order Update', 'Your order status has been updated to: $status');
    }
  }

  Stream<DocumentSnapshot> getOrderStatusStream(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots();
  }

  // Review methods
  Future<void> addReview(String productId, String userId, double rating, String comment) async {
    await _firestore.collection('products').doc(productId).collection('reviews').add({
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': FieldValue.serverTimestamp(),
    });

    // Update the average rating of the product
    await updateProductAverageRating(productId);
  }

  Future<void> updateProductAverageRating(String productId) async {
    QuerySnapshot reviewsSnapshot = await _firestore.collection('products').doc(productId).collection('reviews').get();
    
    if (reviewsSnapshot.docs.isEmpty) {
      await _firestore.collection('products').doc(productId).update({'average_rating': 0});
      return;
    }

    double totalRating = 0;
    reviewsSnapshot.docs.forEach((doc) {
      totalRating += (doc.data() as Map<String, dynamic>)['rating'] as double;
    });

    double averageRating = totalRating / reviewsSnapshot.docs.length;

    await _firestore.collection('products').doc(productId).update({'average_rating': averageRating});
  }

  Future<List<QueryDocumentSnapshot>> getProductReviews(String productId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('created_at', descending: true)
        .get();
    return querySnapshot.docs;
  }

    Future<void> saveUserAddress(String userId, String address, double latitude, double longitude) async {
    await _firestore.collection('users').doc(userId).update({
      'address': address,
      'location': GeoPoint(latitude, longitude),
      'hasSetAddress': true,
    });
  }
  
Future<bool> userHasAddress(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
    return userData?['hasSetAddress'] ?? false;
  }


  // FCM Token methods
  Future<void> saveUserFCMToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcm_tokens': FieldValue.arrayUnion([token]),
    });
  }

  Future<void> removeUserFCMToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcm_tokens': FieldValue.arrayRemove([token]),
    });
  }

  // Helper method to send FCM notification (you'll need to implement this using a server or cloud function)
  Future<void> sendNotification(String token, String title, String body) async {
    // Implement FCM sending logic here (typically done on the server-side)
    print('Sending notification to token: $token');
    print('Title: $title');
    print('Body: $body');
  }

  // Loyalty points methods
  Future<void> addPoints(String userId, int points) async {
    await _firestore.collection('users').doc(userId).update({
      'points': FieldValue.increment(points),
    });

    await _firestore.collection('users').doc(userId).collection('point_transactions').add({
      'points': points,
      'type': 'earned',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> redeemPoints(String userId, int points) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    int currentPoints = userDoc['points'] ?? 0;

    if (currentPoints < points) {
      throw Exception('Insufficient points');
    }

    await _firestore.collection('users').doc(userId).update({
      'points': FieldValue.increment(-points),
    });

    await _firestore.collection('users').doc(userId).collection('point_transactions').add({
      'points': -points,
      'type': 'redeemed',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<int> getUserPoints(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc['points'] ?? 0;
  }

  Future<List<QueryDocumentSnapshot>> getPointTransactions(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('point_transactions')
        .orderBy('timestamp', descending: true)
        .get();
    return querySnapshot.docs;
  }

  // Chat-related methods
  Future<List<QueryDocumentSnapshot>> getUserChats(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs;
  }

  Future<void> closeChatSession(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'status': 'closed',
      'closedAt': FieldValue.serverTimestamp(),
    });
  }
 
  // User interaction methods
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

  Future<DocumentSnapshot> getProductDetails(String productId) async {
    return await _firestore.collection('products').doc(productId).get();
  }

 

  Future<void> updateUserPoints(String uid, int points) async {
    await _firestore.collection('users').doc(uid).update({
      'points': points,
    });
  }

  

  
}