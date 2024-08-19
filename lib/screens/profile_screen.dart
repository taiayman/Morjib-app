import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:my_delivery_app/models/custom_user.dart';
import 'package:my_delivery_app/services/auth_service.dart';
import 'package:my_delivery_app/services/firestore_service.dart';
import 'package:my_delivery_app/services/order_service.dart';
import 'package:my_delivery_app/screens/order_tracking_screen.dart';

class DeliverooColors {
  static const Color primary = Color(0xFF00CCBC);
  static const Color secondary = Color(0xFF2E3333);
  static const Color background = Color(0xFFF9FAFA);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFFF8000);
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final OrderService _orderService = OrderService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUser(user.uid);
      setState(() {
        _nameController.text = userData['name'] ?? user.displayName ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _addressController.text = userData['address'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: DeliverooColors.background,
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(_nameController.text),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildInfoSection(context, user),
                      _buildOrderSection(context, user),
                      _buildOptionsSection(context),
                      _buildLogoutButton(context, authService),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar(String name) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, CustomUser user) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DeliverooColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          _buildEditableInfoRow(Icons.person, 'Name', _nameController),
          SizedBox(height: 16),
          _buildInfoRow(Icons.email, user.email ?? 'No email'),
          SizedBox(height: 16),
          _buildEditableInfoRow(Icons.phone, 'Phone', _phoneController),
          SizedBox(height: 16),
          _buildEditableInfoRow(Icons.location_on, 'Address', _addressController),
          SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              child: Text(
                'Update Profile',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: _updateUserInfo,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: DeliverooColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection(BuildContext context, CustomUser user) {
    final OrderService _orderService = OrderService();
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Orders',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DeliverooColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              child: Text(
                'View All Orders',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/order_history');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: DeliverooColors.primary,
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: DeliverooColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Options',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DeliverooColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          _buildOptionTile(context, Icons.star, 'My Points', '/points_history'),
          _buildOptionTile(context, Icons.favorite, 'Favorites', '/favorites'),
          _buildOptionTile(context, Icons.headset_mic, 'Customer Support', '/chat_list'),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, IconData icon, String title, String route) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DeliverooColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: DeliverooColors.primary),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.chevron_right, color: DeliverooColors.textLight),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthService authService) {
    return Container(
      margin: EdgeInsets.all(16),
      child: ElevatedButton(
        child: Text(
          'Logout',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: DeliverooColors.accent,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: () async {
          await authService.signOut(context);
          Navigator.of(context).pushReplacementNamed('/login');
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DeliverooColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: DeliverooColors.primary),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableInfoRow(IconData icon, String label, TextEditingController controller) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: DeliverooColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: DeliverooColors.primary),
        ),
        SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateUserInfo() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      try {
        await _firestoreService.updateUserInfo(
          user.uid,
          _nameController.text,
          _phoneController.text,
          _addressController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}