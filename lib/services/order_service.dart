import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>> getOrderStream(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((snapshot) => snapshot.data() as Map<String, dynamic>);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDeliveryLocation(String orderId, GeoPoint location) async {
    await _firestore.collection('orders').doc(orderId).update({
      'delivery_location': location,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> assignDeliveryPerson(String orderId, String deliveryPersonId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'delivery_person_id': deliveryPersonId,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    DocumentSnapshot orderSnapshot = await _firestore.collection('orders').doc(orderId).get();
    return orderSnapshot.data() as Map<String, dynamic>;
  }

  Stream<List<Map<String, dynamic>>> getUserOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  Future<String> generateOrderQR(String orderId) async {
    DocumentSnapshot orderDoc = await _firestore.collection('orders').doc(orderId).get();
    
    if (!orderDoc.exists) {
      throw Exception('Order not found');
    }

    Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
    
    // Generate a unique code for this order if it doesn't exist
    if (!orderData.containsKey('qr_code')) {
      String qrCode = Uuid().v4();
      await _firestore.collection('orders').doc(orderId).update({'qr_code': qrCode});
      return qrCode;
    }

    return orderData['qr_code'];
  }
  

}