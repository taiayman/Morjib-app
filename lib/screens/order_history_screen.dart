import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class OrderHistoryScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: userId == null
          ? Center(child: Text('Please log in to view order history'))
          : FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _firestoreService.getOrderHistory(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No orders found'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx, i) {
                    var order = snapshot.data![i].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text('Order #${snapshot.data![i].id}'),
                        subtitle: Text('Status: ${order['status']}'),
                        trailing: Text('${order['total_amount'].toStringAsFixed(2)} MAD'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsScreen(orderId: snapshot.data![i].id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final FirestoreService _firestoreService = FirestoreService();

  OrderDetailsScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestoreService.getOrderStatusStream(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Order not found'));
          }

          var order = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #$orderId', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Status: ${order['status']}'),
                Text('Total Amount: ${order['total_amount'].toStringAsFixed(2)} MAD'),
                Text('Date: ${(order['created_at'] as Timestamp).toDate().toString()}'),
                SizedBox(height: 20),
                Text('Order Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: snapshot.data!.reference.collection('order_items').get(),
                    builder: (context, itemsSnapshot) {
                      if (itemsSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (itemsSnapshot.hasError) {
                        return Center(child: Text('Error: ${itemsSnapshot.error}'));
                      }
                      if (!itemsSnapshot.hasData || itemsSnapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No items found'));
                      }

                      return ListView.builder(
                        itemCount: itemsSnapshot.data!.docs.length,
                        itemBuilder: (ctx, i) {
                          var item = itemsSnapshot.data!.docs[i].data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(item['product_name']),
                            subtitle: Text('Quantity: ${item['quantity']}'),
                            trailing: Text('${item['price'].toStringAsFixed(2)} MAD'),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}