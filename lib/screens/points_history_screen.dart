import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class PointsHistoryScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      body: userId == null
          ? _buildLoginPrompt()
          : _buildPointsHistory(context, userId),
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Points History', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: 64, color: Colors.grey[600]),
            SizedBox(height: 16),
            Text(
              'Please log in to view points history',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement login navigation
              },
              child: Text('Log In', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsHistory(BuildContext context, String userId) {
    return FutureBuilder(
      future: Future.wait([
        _firestoreService.getUserPoints(userId),
        _firestoreService.getPointTransactions(userId),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data![1].isEmpty) {
          return _buildEmptyStateWidget();
        }

        int currentPoints = snapshot.data![0] as int;
        List<dynamic> transactions = snapshot.data![1];

        return CustomScrollView(
          slivers: [
            _buildSilverAppBar(currentPoints),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  'Transaction History',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildTransactionCard(transactions[index]),
                childCount: transactions.length,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSilverAppBar(int currentPoints) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Points History',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        background: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Current Balance',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$currentPoints pts',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

  Widget _buildTransactionCard(dynamic transaction) {
    var data = transaction.data() as Map<String, dynamic>;
    bool isEarned = data['type'] == 'earned';
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildTransactionIcon(isEarned),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data['points'].abs()} points ${isEarned ? 'earned' : 'spent'}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy - HH:mm').format(data['timestamp'].toDate()),
                  style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            '${isEarned ? '+' : '-'}${data['points'].abs()}',
            style: GoogleFonts.poppins(
              color: isEarned ? Colors.green[700] : Colors.red[700],
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionIcon(bool isEarned) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isEarned ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isEarned ? Icons.add : Icons.remove,
        color: isEarned ? Colors.green[700] : Colors.red[700],
        size: 24,
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.poppins(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement retry functionality
              },
              child: Text('Retry', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Points History', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No transaction history yet',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 8),
            Text(
              'Start earning or spending points to see your history here!',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}