import 'package:cloud_firestore/cloud_firestore.dart';

class Supermarket {
  final String id;
  final String name;
  final String imageUrl;

  Supermarket({required this.id, required this.name, required this.imageUrl});

  factory Supermarket.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Supermarket(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
