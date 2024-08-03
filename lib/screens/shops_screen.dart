import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class ShopsScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shops'),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _firestoreService.getShops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No shops found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) {
              var shop = snapshot.data![index];
              return Card(
                child: ListTile(
                  leading: Image.network(
                    shop['logo'],
                    width: 50,
                    height: 50,
                  ),
                  title: Text(shop['name']),
                  subtitle: Text(shop['type']),
                  onTap: () {
                    // TODO: Navigate to shop product listing
                    print('Tapped on ${shop['name']}');
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