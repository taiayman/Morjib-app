import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? paymentIntentId;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.paymentIntentId,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: data['user_id'] ?? '',
      items: (data['items'] as List? ?? []).map((item) => OrderItem.fromMap(item)).toList(),
      totalAmount: (data['total_amount'] ?? 0).toDouble(),
      status: data['status'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: data['updated_at'] != null ? (data['updated_at'] as Timestamp).toDate() : null,
      paymentIntentId: data['payment_intent_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'total_amount': totalAmount,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'payment_intent_id': paymentIntentId,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}