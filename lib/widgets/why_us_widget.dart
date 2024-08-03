import 'package:flutter/material.dart';

class WhyUsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeature(Icons.monetization_on, 'Competitive Pricing', 'Pay less, get more'),
        _buildFeature(Icons.star, 'Points System', 'Earn points with every purchase'),
        _buildFeature(Icons.delivery_dining, 'Fast Delivery', 'Quick and reliable service'),
      ],
    );
  }

  Widget _buildFeature(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.green),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}