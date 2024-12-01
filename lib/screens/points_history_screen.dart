import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class DeliverooColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class PointsHistoryScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userId = authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: DeliverooColors.background,
      body: userId == null
          ? _buildLoginPrompt()
          : _buildPointsHistory(context, userId),
    );
  }

  Widget _buildLoginPrompt() {
    return Scaffold(
      appBar: AppBar(
        title: Text('points_history'.tr(), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 24)),
        elevation: 0,
        backgroundColor: DeliverooColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: 64, color: DeliverooColors.accent),
            SizedBox(height: 16),
            Text(
              'please_log_in_to_view_points_history'.tr(),
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w400, color: DeliverooColors.textDark),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement login navigation
              },
              child: Text('log_in'.tr(), style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: DeliverooColors.primary,
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
          return Center(child: CircularProgressIndicator(strokeWidth: 2, color: DeliverooColors.primary));
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
                  'transaction_history'.tr(),
                  style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: DeliverooColors.textDark),
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
          'points_history'.tr(),
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        background: Container(
          color: DeliverooColors.primary,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'current_balance'.tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$currentPoints pts',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: DeliverooColors.primary,
      foregroundColor: Colors.white,
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
        border: Border.all(color: DeliverooColors.secondary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: DeliverooColors.primary.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
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
                  '${data['points'].abs()} ${isEarned ? 'points_earned'.tr() : 'points_spent'.tr()}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16, color: DeliverooColors.textDark),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy - HH:mm').format(data['timestamp'].toDate()),
                  style: GoogleFonts.poppins(color: DeliverooColors.textLight, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            '${isEarned ? '+' : '-'}${data['points'].abs()}',
            style: GoogleFonts.poppins(
              color: isEarned ? DeliverooColors.primary : Colors.red[700],
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
        color: isEarned ? DeliverooColors.primary.withOpacity(0.1) : Colors.red[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isEarned ? Icons.add : Icons.remove,
        color: isEarned ? DeliverooColors.primary : Colors.red[700],
        size: 24,
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Scaffold(
      appBar: AppBar(
        title: Text('error'.tr(), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 24)),
        elevation: 0,
        backgroundColor: DeliverooColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: DeliverooColors.accent),
            SizedBox(height: 16),
            Text(
              'oops_something_went_wrong'.tr(),
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w400, color: DeliverooColors.textDark),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.poppins(color: DeliverooColors.textLight),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement retry functionality
              },
              child: Text('retry'.tr(), style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: DeliverooColors.primary,
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
        title: Text('points_history'.tr(), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 24)),
        elevation: 0,
        backgroundColor: DeliverooColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: DeliverooColors.accent),
            SizedBox(height: 16),
            Text(
              'no_transaction_history_yet'.tr(),
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w400, color: DeliverooColors.textDark),
            ),
            SizedBox(height: 8),
            Text(
              'start_earning_or_spending_points'.tr(),
              style: GoogleFonts.poppins(color: DeliverooColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}