import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';

class CartService with ChangeNotifier {
  Map<String, CartItem> _items = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  CartService();

  void updateUserId(String? userId) {
    _userId = userId;
    if (_userId != null) {
      loadCartFromFirestore();
    } else {
      _items.clear();
      notifyListeners();
    }
  }

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> loadCartFromFirestore() async {
    if (_userId == null) return;

    try {
      final snapshot = await _firestore.collection('users').doc(_userId).collection('cart').get();
      _items = {
        for (var doc in snapshot.docs)
          doc.id: CartItem.fromMap(doc.data())
      };
      notifyListeners();
    } catch (e) {
      print('Error loading cart from Firestore: $e');
    }
  }

  Future<void> saveCartToFirestore() async {
    if (_userId == null) return;

    try {
      final batch = _firestore.batch();
      final cartRef = _firestore.collection('users').doc(_userId).collection('cart');

      // Delete existing cart items
      final snapshot = await cartRef.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      // Add current cart items
      _items.forEach((key, item) {
        final docRef = cartRef.doc(key);
        batch.set(docRef, item.toMap());
      });

      await batch.commit();
    } catch (e) {
      print('Error saving cart to Firestore: $e');
    }
  }

  void addItem(String productId, String name, double price, String imageUrl, String sellerType, {int quantity = 1}) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
          sellerType: existingCartItem.sellerType,
          quantity: existingCartItem.quantity + quantity,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          name: name,
          price: price,
          imageUrl: imageUrl,
          sellerType: sellerType,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
    saveCartToFirestore();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
    saveCartToFirestore();
  }

  void clear() {
    _items = {};
    notifyListeners();
    saveCartToFirestore();
  }

  void decrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items.update(
          productId,
          (existingCartItem) => CartItem(
            id: existingCartItem.id,
            name: existingCartItem.name,
            price: existingCartItem.price,
            imageUrl: existingCartItem.imageUrl,
            sellerType: existingCartItem.sellerType,
            quantity: existingCartItem.quantity - 1,
          ),
        );
      } else {
        _items.remove(productId);
      }
      notifyListeners();
      saveCartToFirestore();
    }
  }

  void incrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
          sellerType: existingCartItem.sellerType,
          quantity: existingCartItem.quantity + 1,
        ),
      );
      notifyListeners();
      saveCartToFirestore();
    }
  }
}