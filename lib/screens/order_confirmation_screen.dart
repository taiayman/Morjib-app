import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final FirestoreService _firestoreService = FirestoreService();

  OrderConfirmationScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Confirmation'),
      ),
      body: FutureBuilder(
        future: _firestoreService.getOrderDetails(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No order data found'));
          }

          var orderData = snapshot.data!.data() as Map<String, dynamic>;
          int pointsEarned = (orderData['total_amount'] / 10).floor();

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thank you for your order!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text('Order ID: $orderId', style: TextStyle(fontSize: 18)),
                Text('Status: ${orderData['status']}', style: TextStyle(fontSize: 18)),
                Text('Total Amount: ${orderData['total_amount'].toStringAsFixed(2)} MAD', style: TextStyle(fontSize: 18)),
                Text('Points Earned: $pointsEarned', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                SizedBox(height: 20),
                Text('Order Items:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: (orderData['items'] as List).length,
                    itemBuilder: (ctx, index) {
                      var item = (orderData['items'] as List)[index];
                      return ListTile(
                        title: Text(item['product_name']),
                        subtitle: Text('Quantity: ${item['quantity']}'),
                        trailing: Text('${(item['price'] * item['quantity']).toStringAsFixed(2)} MAD'),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  child: Text('Back to Home'),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}