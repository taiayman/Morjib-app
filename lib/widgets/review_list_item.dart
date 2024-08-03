import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewListItem extends StatelessWidget {
  final Review review;

  ReviewListItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Rating: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(review.comment),
            SizedBox(height: 8),
            Text(
              'Posted on ${review.createdAt.toString().substring(0, 10)}',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
