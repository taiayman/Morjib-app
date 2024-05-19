import 'package:flutter/material.dart';
import 'package:business_management_app/models/user.dart';

class CEOCard extends StatelessWidget {
  final User user;

  CEOCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.profileImage ?? 'https://via.placeholder.com/150'),
          radius: 40,
        ),
        SizedBox(height: 8),
        Container(
          width: 80, // Set a fixed width for the text
          child: Text(
            user.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1, // Limit to 1 line with ellipsis if the text is too long
          ),
        ),
      ],
    );
  }
}
