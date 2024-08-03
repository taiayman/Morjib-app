import 'package:cloud_firestore/cloud_firestore.dart';

class Promotion {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String linkUrl;
  final DateTime startDate;
  final DateTime endDate;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.linkUrl,
    required this.startDate,
    required this.endDate,
  });

  factory Promotion.fromMap(Map<String, dynamic> data, String id) {
    return Promotion(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      linkUrl: data['linkUrl'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }
}
