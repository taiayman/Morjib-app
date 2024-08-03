import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryStatus {
  final String orderId;
  final String status;
  final DateTime timestamp;
  final String? description;
  final GeoPoint? location;

  DeliveryStatus({
    required this.orderId,
    required this.status,
    required this.timestamp,
    this.description,
    this.location,
  });

  factory DeliveryStatus.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return DeliveryStatus(
      orderId: data['order_id'] ?? '',
      status: data['status'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      description: data['description'],
      location: data['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
      'location': location,
    };
  }
}