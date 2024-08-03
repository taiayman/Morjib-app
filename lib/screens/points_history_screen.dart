import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class PointsHistoryScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Points History'),
      ),
      body: userId == null
          ? Center(child: Text('Please log in to view points history'))
          : FutureBuilder(
              future: Future.wait([
                _firestoreService.getUserPoints(userId),
                _firestoreService.getPointTransactions(userId),
              ]),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: Text('No points data found'));
                }

                int currentPoints = snapshot.data![0] as int;
                List<dynamic> transactions = snapshot.data![1];

                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      color: Theme.of(context).primaryColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Points Balance:',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            '$currentPoints',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          var transaction = transactions[index].data() as Map<String, dynamic>;
                          return ListTile(
                            leading: Icon(
                              transaction['type'] == 'earned' ? Icons.add_circle : Icons.remove_circle,
                              color: transaction['type'] == 'earned' ? Colors.green : Colors.red,
                            ),
                            title: Text('${transaction['points'].abs()} points ${transaction['type']}'),
                            subtitle: Text(transaction['timestamp'].toDate().toString()),
                            trailing: Text(
                              '${transaction['type'] == 'earned' ? '+' : '-'}${transaction['points'].abs()}',
                              style: TextStyle(
                                color: transaction['type'] == 'earned' ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}