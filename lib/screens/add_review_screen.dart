import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/review_service.dart';

class AddReviewScreen extends StatefulWidget {
  final String productId;

  AddReviewScreen({required this.productId});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final ReviewService _reviewService = ReviewService();
  double _rating = 0;
  String _comment = '';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Review'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rate this product:', style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Your Review',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your review';
                  }
                  return null;
                },
                onSaved: (value) {
                  _comment = value!;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  child: Text('Submit Review'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && _rating > 0) {
                      _formKey.currentState!.save();
                      try {
                        Review review = Review(
                          id: '',
                          userId: userId,
                          productId: widget.productId,
                          rating: _rating,
                          comment: _comment,
                          createdAt: DateTime.now(),
                        );
                        await _reviewService.addReview(review);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Review submitted successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to submit review: ${e.toString()}')),
                        );
                      }
                    } else if (_rating == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a rating')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

