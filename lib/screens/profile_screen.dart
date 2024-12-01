import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:my_delivery_app/models/custom_user.dart';
import 'package:my_delivery_app/services/auth_service.dart';
import 'package:my_delivery_app/services/firestore_service.dart';
import 'package:my_delivery_app/services/order_service.dart';
import 'package:my_delivery_app/screens/order_tracking_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class DeliverooColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
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

  final List<Map<String, dynamic>> _supportedLocales = [
    {'locale': Locale('en', 'US'), 'flag': '🇺🇸', 'name': 'English'},
    {'locale': Locale('fr', 'FR'), 'flag': '🇫🇷', 'name': 'Français'},
    {'locale': Locale('ar'), 'flag': '🇸🇦', 'name': 'العربية'},
  ];

  void _updateLocale(Locale locale) {
    context.setLocale(locale);
  }

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
      appBar: AppBar(
        backgroundColor: DeliverooColors.primary,
        title: Text(
          'profile'.tr(),
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: user == null ? _buildNonLoggedInUI(context) : _buildLoggedInUI(context, user),
    );
  }

  Widget _buildNonLoggedInUI(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 100, color: DeliverooColors.primary),
          SizedBox(height: 20),
          Text(
            'not_logged_in'.tr(),
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DeliverooColors.textDark,
            ),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: DeliverooColors.accent.withOpacity(0.5),
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ElevatedButton(
              child: Text(
                'create_account'.tr(),
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: DeliverooColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
            ),
          ),
          SizedBox(height: 20),
          TextButton(
            child: Text(
              'already_have_account'.tr(),
              style: GoogleFonts.poppins(
                textStyle: TextStyle(color: DeliverooColors.primary, fontWeight: FontWeight.w500),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInUI(BuildContext context, CustomUser user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildInfoSection(context, user),
          _buildOrderSection(context, user),
          _buildOptionsSection(context),
          _buildLanguageOptionCard(context),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildLanguageOptionCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLanguageBottomSheet(context),
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: DeliverooColors.primary.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'change_language'.tr(),
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: DeliverooColors.textDark,
              ),
            ),
            Icon(Icons.language, color: DeliverooColors.primary),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _supportedLocales.map((localeInfo) {
              return ListTile(
                leading: Text(localeInfo['flag'], style: TextStyle(fontSize: 24)),
                title: Text(localeInfo['name'], style: GoogleFonts.poppins(fontSize: 16)),
                onTap: () {
                  _updateLocale(localeInfo['locale']);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
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
            color: DeliverooColors.primary.withOpacity(0.1),
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
            'account_information'.tr(),
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: DeliverooColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          _buildEditableInfoRow(Icons.person, 'name'.tr(), _nameController),
          SizedBox(height: 16),
          _buildInfoRow(Icons.email, user.email ?? 'no_email'.tr()),
          SizedBox(height: 16),
          _buildEditableInfoRow(Icons.phone, 'phone'.tr(), _phoneController),
          SizedBox(height: 16),
          _buildEditableInfoRow(Icons.location_on, 'address'.tr(), _addressController),
          SizedBox(height: 24),
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: DeliverooColors.accent.withOpacity(0.5),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ElevatedButton(
                child: Text(
                  'update_profile'.tr(),
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: _updateUserInfo,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: DeliverooColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSection(BuildContext context, CustomUser user) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: DeliverooColors.primary.withOpacity(0.1),
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
            'my_orders'.tr(),
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: DeliverooColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: DeliverooColors.accent.withOpacity(0.5),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ElevatedButton(
                child: Text(
                  'view_all_orders'.tr(),
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
                  elevation: 0,
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
            'options'.tr(),
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: DeliverooColors.textDark,
            ),
          ),
          SizedBox(height: 16),
          _buildOptionTile(context, Icons.star, 'my_points'.tr(), '/points_history'),
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

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: DeliverooColors.accent.withOpacity(0.5),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        child: Text(
          'logout'.tr(),
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: DeliverooColors.primary,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: Size(double.infinity, 50),
          elevation: 0,
        ),
        onPressed: () async {
          final authService = Provider.of<AuthService>(context, listen: false);
          await authService.signOut();
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
            style: GoogleFonts.poppins(fontSize: 16, color: DeliverooColors.textDark),
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
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.poppins(color: DeliverooColors.textLight),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: DeliverooColors.textLight),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: DeliverooColors.primary),
              ),
            ),
            style: GoogleFonts.poppins(color: DeliverooColors.textDark),
          ),
        ),
      ],
    );
  }

  Future<void> _updateUserInfo() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      await _firestoreService.updateUser(user.uid, {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('profile_updated'.tr())));
    }
  }
}