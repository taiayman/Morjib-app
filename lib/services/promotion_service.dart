import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promotion.dart';

class PromotionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Promotion>> getActivePromotions() async {
    final now = DateTime.now();
    final snapshot = await _firestore
        .collection('promotions')
        .where('startDate', isLessThanOrEqualTo: now)
        .where('endDate', isGreaterThanOrEqualTo: now)
        .get();

    return snapshot.docs
        .map((doc) => Promotion.fromMap(doc.data(), doc.id))
        .toList();
  }
}
