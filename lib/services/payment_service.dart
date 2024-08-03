import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String _backendUrl = 'https://backend-url.com';
  Future<void> initializeStripe() async {
    Stripe.publishableKey = 'publishable_key_here'; 
  }

  Future<PaymentIntent> processPayment(double amount, String currency) async {
    try {
      
      final response = await http.post(
        Uri.parse('$_backendUrl/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (amount * 100).toInt(), 
          'currency': currency,
        }),
      );

      final paymentIntentData = json.decode(response.body);
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          merchantDisplayName: 'My delivery',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      return PaymentIntent(
        id: paymentIntentData['id'],
        status: paymentIntentData['status'],
      );
    } catch (e) {
      print('Error processing payment: $e');
      rethrow;
    }
  }
}

class PaymentIntent {
  final String id;
  final String status;

  PaymentIntent({required this.id, required this.status});
}