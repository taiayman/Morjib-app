import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Favorites'),
      ),
      body: userId == null
          ? Center(child: Text('Please log in to view favorites'))
          : FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _firestoreService.getFavorites(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No favorites found'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx, i) {
                    final product = snapshot.data![i].data() as Map<String, dynamic>;
                   return ProductCard(
  id: snapshot.data![i].id,
  name: product['name'] ?? 'Unknown Product',
  price: (product['price'] ?? 0).toDouble(),
  imageUrl: product['image'] ?? '',
  unit: product['unit'] ?? 'item',
  description: product['description'] ?? 'No description available',  // Added description field
  isFavorite: true,
  averageRating: (product['averageRating'] ?? 0).toDouble(),  // Added averageRating field
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
    );
  }
}