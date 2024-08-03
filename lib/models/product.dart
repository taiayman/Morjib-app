class Product {
  final String id;
  final String name;
  final String description;  // New field
  final double price;
  final String imageUrl;
  final String category;
  final String sellerId;
  final String sellerType;
  final String unit;
  final int popularity;

  Product({
    required this.id,
    required this.name,
    required this.description,  // New field
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.sellerId,
    required this.sellerType,
    required this.unit,
    this.popularity = 0,
  });

  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',  // New field
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['image_url'] ?? '',
      category: data['category'] ?? '',
      sellerId: data['seller_id'] ?? '',
      sellerType: data['seller_type'] ?? '',
      unit: data['unit'] ?? '',
      popularity: data['popularity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,  // New field
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'seller_id': sellerId,
      'seller_type': sellerType,
      'unit': unit,
      'popularity': popularity,
    };
  }
}