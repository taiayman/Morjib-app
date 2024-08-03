import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class SupermarketScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supermarkets'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _firestoreService.getSupermarkets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No supermarkets found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) {
              var supermarket = snapshot.data![index];
              return Card(
                child: ListTile(
                  leading: Image.network(
                    supermarket['logo'],
                    width: 50,
                    height: 50,
                  ),
                  title: Text(supermarket['name']),
                  onTap: () {
                    // TODO: Navigate to supermarket product listing
                    print('Tapped on ${supermarket['name']}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}