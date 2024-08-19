import 'package:cloud_firestore/cloud_firestore.dart';

class TraditionalMarketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all categories
  Stream<QuerySnapshot> getCategories() {
    return _firestore.collection('categories').snapshots();
  }

  // Fetch products for a specific category
  Stream<QuerySnapshot> getProductsByCategory(String categoryId) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: categoryId)
        .snapshots();
  }

  // Add a new category
  Future<void> addCategory(String name, String description) {
    return _firestore.collection('categories').add({
      'name': name,
      'description': description,
    });
  }

  // Add a new product
  Future<void> addProduct(Map<String, dynamic> productData) {
    return _firestore.collection('products').add(productData);
  }

  // Update a category
  Future<void> updateCategory(String categoryId, Map<String, dynamic> data) {
    return _firestore.collection('categories').doc(categoryId).update(data);
  }

  // Update a product
  Future<void> updateProduct(String productId, Map<String, dynamic> data) {
    return _firestore.collection('products').doc(productId).update(data);
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) {
    return _firestore.collection('categories').doc(categoryId).delete();
  }

  // Delete a product
  Future<void> deleteProduct(String productId) {
    return _firestore.collection('products').doc(productId).delete();
  }
}