class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final int rating;
  final int ratingCount;
  final String cuisine;
  final String address;
  final int discount;
  final String promotion;
  final int estimatedDeliveryTime;
  final bool hasCocaColaDeal;
  final List<String> tags;
  final String url;  // New field

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.ratingCount,
    required this.cuisine,
    required this.address,
    this.discount = 0,
    this.promotion = '',
    this.estimatedDeliveryTime = 30,
    this.hasCocaColaDeal = false,
    this.tags = const [],
    required this.url,  // New required parameter
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: map['rating'] ?? 0,
      ratingCount: map['ratingCount'] ?? 0,
      cuisine: map['cuisine'] ?? '',
      address: map['address'] ?? '',
      discount: map['discount'] ?? 0,
      promotion: map['promotion'] ?? '',
      estimatedDeliveryTime: map['estimatedDeliveryTime'] ?? 30,
      hasCocaColaDeal: map['hasCocaColaDeal'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      url: map['url'] ?? '',  // New field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'ratingCount': ratingCount,
      'cuisine': cuisine,
      'address': address,
      'discount': discount,
      'promotion': promotion,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'hasCocaColaDeal': hasCocaColaDeal,
      'tags': tags,
      'url': url,  // New field
    };
  }

  Restaurant copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? rating,
    int? ratingCount,
    String? cuisine,
    String? address,
    int? discount,
    String? promotion,
    int? estimatedDeliveryTime,
    bool? hasCocaColaDeal,
    List<String>? tags,
    String? url,  // New parameter
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      cuisine: cuisine ?? this.cuisine,
      address: address ?? this.address,
      discount: discount ?? this.discount,
      promotion: promotion ?? this.promotion,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      hasCocaColaDeal: hasCocaColaDeal ?? this.hasCocaColaDeal,
      tags: tags ?? this.tags,
      url: url ?? this.url,  // New field
    );
  }
}