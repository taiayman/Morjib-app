import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: FutureBuilder(
        future: _firestoreService.getUser(authService.currentUser!.uid),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No user data found'));
          }

          var userData = snapshot.data!;

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${userData['name']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Email: ${userData['email']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Phone: ${userData['phone']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Points: ${userData['points']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 24),
                ElevatedButton(
                  child: Text('Edit Profile'),
                  onPressed: () {
                    // TODO: Implement edit profile functionality
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Logout'),
                  onPressed: () async {
                    await authService.signOut();
                    Navigator.of(context).pushReplacementNamed('/login');
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