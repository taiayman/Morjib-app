import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview(Review review) async {
    await _firestore.collection('reviews').add(review.toMap());
    await updateProductRating(review.productId);
  }

  Future<List<Review>> getProductReviews(String productId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
  }

  Future<void> updateProductRating(String productId) async {
    QuerySnapshot reviewsSnapshot = await _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .get();

    if (reviewsSnapshot.docs.isEmpty) {
      await _firestore.collection('products').doc(productId).update({
        'averageRating': 0,
        'numberOfReviews': 0,
      });
      return;
    }

    double totalRating = 0;
    reviewsSnapshot.docs.forEach((doc) {
      totalRating += (doc.data() as Map<String, dynamic>)['rating'] as double;
    });

    double averageRating = totalRating / reviewsSnapshot.docs.length;
    int numberOfReviews = reviewsSnapshot.docs.length;

    await _firestore.collection('products').doc(productId).update({
      'averageRating': averageRating,
      'numberOfReviews': numberOfReviews,
    });
  }
}
