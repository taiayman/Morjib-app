import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ProductCard extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String unit;
  final bool isFavorite;
  final double averageRating;
  final String description;

  const ProductCard({
    Key? key,
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.unit,
    this.isFavorite = false,
    this.averageRating = 0,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: FavoriteButton(
                  productId: id,
                  initialIsFavorite: isFavorite,
                ),
              ),
              if (averageRating > 0)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${price.toStringAsFixed(2)} MAD',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                    Text(
                      '/$unit',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    cart.addItem(id, name, price);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$name added to cart'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: Text('Add to Cart', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    minimumSize: Size(double.infinity, 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final String productId;
  final bool initialIsFavorite;

  const FavoriteButton({
    Key? key,
    required this.productId,
    required this.initialIsFavorite,
  }) : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorite;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.deepOrange,
        ),
        onPressed: () async {
          final userId = authService.currentUser?.uid;
          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please log in to add favorites')),
            );
            return;
          }

          setState(() {
            _isFavorite = !_isFavorite;
          });

          try {
            if (_isFavorite) {
              await _firestoreService.addToFavorites(userId, widget.productId);
            } else {
              await _firestoreService.removeFromFavorites(userId, widget.productId);
            }
          } catch (e) {
            print('Error updating favorite: $e');
            setState(() {
              _isFavorite = !_isFavorite;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update favorite')),
            );
          }
        },
      ),
    );
  }
}