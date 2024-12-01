import 'package:cloud_firestore/cloud_firestore.dart';

class TraditionalMarket {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final String location;
  final GeoPoint coordinates;
  final double rating;
  final int ratingCount;
  final String openingHours;
  final List<String> specialties;
  final bool isOpen;
  final int estimatedDeliveryTime;
  final String coverImage;
  final List<String> marketPhotos;

  TraditionalMarket({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.location,
    required this.coordinates,
    required this.rating,
    required this.ratingCount,
    required this.openingHours,
    required this.specialties,
    required this.isOpen,
    required this.estimatedDeliveryTime,
    required this.coverImage,
    this.marketPhotos = const [],
  });

  factory TraditionalMarket.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TraditionalMarket(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      coordinates: data['coordinates'] ?? const GeoPoint(0, 0),
      rating: (data['rating'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      openingHours: data['openingHours'] ?? '',
      specialties: List<String>.from(data['specialties'] ?? []),
      isOpen: data['isOpen'] ?? false,
      estimatedDeliveryTime: data['estimatedDeliveryTime'] ?? 30,
      coverImage: data['coverImage'] ?? '',
      marketPhotos: List<String>.from(data['marketPhotos'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'location': location,
      'coordinates': coordinates,
      'rating': rating,
      'ratingCount': ratingCount,
      'openingHours': openingHours,
      'specialties': specialties,
      'isOpen': isOpen,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'coverImage': coverImage,
      'marketPhotos': marketPhotos,
    };
  }
}