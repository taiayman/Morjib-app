import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/payment_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class CheckoutScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final PaymentService _paymentService = PaymentService();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: CircleAvatar(
                  child: FittedBox(
                    child: Text('${cart.items.values.toList()[i].price}'),
                  ),
                ),
                title: Text(cart.items.values.toList()[i].name),
                subtitle: Text('Total: ${(cart.items.values.toList()[i].price * cart.items.values.toList()[i].quantity).toStringAsFixed(2)} MAD'),
                trailing: Text('${cart.items.values.toList()[i].quantity} x'),
              ),
            ),
          ),
          Material(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '${cart.totalAmount.toStringAsFixed(2)} MAD',
                      style: TextStyle(
                       color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                    child: Text('PAY NOW'),
                    onPressed: () async {
                      if (auth.currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please log in to place an order')),
                        );
                        return;
                      }

                      try {
                        // Process payment
                        final paymentResult = await _paymentService.processPayment(
                          cart.totalAmount,
                          'MAD', // Moroccan Dirham
                        );

                        if (paymentResult.status == PaymentIntentsStatus.Succeeded) {
                          // Payment successful, create order
                          List<Map<String, dynamic>> orderItems = cart.items.entries.map((entry) {
                            return {
                              'product_id': entry.key,
                              'product_name': entry.value.name,
                              'quantity': entry.value.quantity,
                              'price': entry.value.price,
                            };
                          }).toList();

                          String orderId = await _firestoreService.createOrder(
                            auth.currentUser!.uid,
                            cart.totalAmount,
                            orderItems,
                            status: 'Paid',
                            paymentIntentId: paymentResult.id,
                          );

                          cart.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Payment successful and order placed!')),
                          );

                          // Navigate to order confirmation screen
                          Navigator.pushReplacementNamed(context, '/order_confirmation', arguments: orderId);
                        } else {
                          throw Exception('Payment failed');
                        }
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Payment failed: ${error.toString()}')),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}