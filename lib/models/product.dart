import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String sellerId;
  final String sellerType;
  final String unit;
  final int popularity;
  final double averageRating;
  final int numberOfRatings;
  final String url;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.sellerId,
    required this.sellerType,
    required this.unit,
    this.popularity = 0,
    this.averageRating = 0,
    this.numberOfRatings = 0,
    required this.url,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['image_url'] ?? '',
      category: data['category'] ?? '',
      sellerId: data['seller_id'] ?? '',
      sellerType: data['seller_type'] ?? '',
      unit: data['unit'] ?? '',
      popularity: data['popularity'] ?? 0,
      averageRating: (data['averageRating'] ?? 0).toDouble(),
      numberOfRatings: data['numberOfRatings'] ?? 0,
      url: data['url'] ?? '',
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product.fromMap({...data, 'id': doc.id});
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'seller_id': sellerId,
      'seller_type': sellerType,
      'unit': unit,
      'popularity': popularity,
      'averageRating': averageRating,
      'numberOfRatings': numberOfRatings,
      'url': url,
    };
  }
}