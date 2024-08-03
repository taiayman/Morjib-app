import 'package:flutter/material.dart';

class HowItWorksWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStep(Icons.login, 'Connect'),
          _buildStep(Icons.shopping_cart, 'Choose Products'),
          _buildStep(Icons.location_on, 'Select Address'),
          _buildStep(Icons.payment, 'Choose Payment'),
        ],
      ),
    );
  }

  Widget _buildStep(IconData icon, String text) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.blue),
          SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}