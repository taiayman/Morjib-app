import 'package:flutter/material.dart';
import 'package:business_management_app/models/user.dart';

class UserProfile extends StatelessWidget {
  final User user;

  UserProfile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(user.name, style: Theme.of(context).textTheme.headline6),
        subtitle: Text('Email: ${user.email}'),
        trailing: Text(user.role),
        onTap: () {
          // Handle card tap
        },
      ),
    );
  }
}
