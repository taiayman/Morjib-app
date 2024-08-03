import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';

class TraditionalMarketScreen extends StatefulWidget {
  @override
  _TraditionalMarketScreenState createState() => _TraditionalMarketScreenState();
}

class _TraditionalMarketScreenState extends State<TraditionalMarketScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traditional Market'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<QueryDocumentSnapshot>>(
            future: _firestoreService.getTraditionalMarketCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No categories found'));
              }

              return Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx, index) {
                    var category = snapshot.data![index];
                    return CategoryCard(
                      title: category['name'],
                      imageUrl: category['image'],
                      color: Colors.primaries[index % Colors.primaries.length], // Add this line
                      onTap: () {
                        setState(() {
                          _selectedCategory = category['name'];
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),

          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _firestoreService.getProducts(
                category: _selectedCategory,
                sellerType: 'traditional_market',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No products found'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx, i) {
                    var product = snapshot.data![i];
                   return ProductCard(
  id: product.id,
  name: product['name'] ?? 'Unknown Product',
  price: (product['price'] ?? 0).toDouble(),
  imageUrl: product['image'] ?? '',
  unit: product['unit'] ?? 'item',
  description: product['description'] ?? 'No description available',
  isFavorite: product['isFavorite'] ?? false,
  averageRating: (product['averageRating'] ?? 0).toDouble(),
);
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}