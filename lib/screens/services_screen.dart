import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_delivery_app/models/cart_item.dart';
import 'package:my_delivery_app/screens/checkout_screen.dart';
import 'package:my_delivery_app/screens/home_screen.dart';
import 'package:my_delivery_app/screens/traditional_market_screen.dart';
import 'package:my_delivery_app/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../services/cart_service.dart';
import './cart_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

class DeliverooColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class ServicesScreen extends StatefulWidget {
  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late Stream<QuerySnapshot> _servicesStream;

  @override
  void initState() {
    super.initState();
    _servicesStream = FirebaseFirestore.instance.collection('services').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeliverooColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          StreamBuilder<QuerySnapshot>(
            stream: _servicesStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('something_went_wrong'.tr())),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildShimmerServiceCard(),
                      childCount: 5,
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return _buildServiceCard(data);
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
  return SliverAppBar(
    floating: false,
    pinned: true,
    snap: false,
    elevation: 4,
    backgroundColor: DeliverooColors.primary,
    expandedHeight: 60,
    leading: IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      },
    ),
    flexibleSpace: FlexibleSpaceBar(
      title: Text(
        'services'.tr(),
        style: GoogleFonts.playfairDisplay(
          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      centerTitle: false,
      titlePadding: EdgeInsets.only(left: 56, bottom: 16), // Adjusted left padding to account for back button
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.menu, color: Colors.white),
        onPressed: () => _showBottomMenu(context),
      ),
    ],
  );
}

  void _showBottomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: DeliverooColors.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildBottomMenuItem(
                context,
                Icons.home,
                'home'.tr(),
                'explore_services'.tr(),
                () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  );
                },
              ),
              _buildBottomMenuItem(
                context,
                Icons.store,
                'supermarket'.tr(),
                'shop_groceries'.tr(),
                () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              ),
              _buildBottomMenuItem(
                context,
                Icons.restaurant,
                'traditional'.tr(),
                'order_local_cuisine'.tr(),
                () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TraditionalMarketScreen(location: 'casablanca')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomMenuItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: DeliverooColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: DeliverooColors.primary),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: DeliverooColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: DeliverooColors.textLight,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: DeliverooColors.textLight),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  Widget _buildShimmerServiceCard() {
    return Shimmer.fromColors(
      baseColor: DeliverooColors.secondary.withOpacity(0.3),
      highlightColor: DeliverooColors.secondary.withOpacity(0.1),
      child: Container(
        height: 300,
        margin: EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Container(
      height: 300,
      margin: EdgeInsets.only(bottom: 24),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(
                image: NetworkImage(service['imageUrl'] ?? 'https://via.placeholder.com/150'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: DeliverooColors.primary.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  DeliverooColors.primary.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  service['name'] ?? 'unnamed_service'.tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: DeliverooColors.secondary.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        service['category'] ?? 'uncategorized'.tr(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.star, color: DeliverooColors.accent, size: 20),
                    SizedBox(width: 4),
                    Text(
                      (service['rating'] ?? 0.0).toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service['price'] ?? 'price_not_available'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailsScreen(service: service),
                          ),
                        );
                      },
                      child: Text('book_now'.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: DeliverooColors.primary,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> service;

  ServiceDetailsScreen({required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                service['name'] ?? 'unnamed_service'.tr(),
                style: GoogleFonts.playfairDisplay(
                  textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    service['imageUrl'] ?? 'https://via.placeholder.com/250',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, DeliverooColors.primary.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: DeliverooColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      service['category'] ?? 'uncategorized'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: DeliverooColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.star, color: DeliverooColors.accent, size: 24),
                      SizedBox(width: 8),
                      Text(
                        (service['rating'] ?? 'n/a'.tr()).toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: DeliverooColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'description'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: DeliverooColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    service['description'] ?? 'no_description_available'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: DeliverooColors.textLight,
                      height: 1.5,
                      ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'price'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: DeliverooColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    service['price'] ?? 'price_not_available'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: DeliverooColors.primary,
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => _confirmBooking(context),
                    child: Text(
                      'book_now'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: DeliverooColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      minimumSize: Size(double.infinity, 56),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'booking_confirmation'.tr(),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: DeliverooColors.textDark,
              fontSize: 20,
            ),
          ),
          content: Text(
            'are_you_sure_you_want_to_book_this_service'.tr(),
            style: GoogleFonts.poppins(
              color: DeliverooColors.textLight,
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'cancel'.tr(),
                style: GoogleFonts.poppins(
                  color: DeliverooColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(
                'confirm'.tr(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: DeliverooColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _addToCartAndNavigateToCheckout(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _addToCartAndNavigateToCheckout(BuildContext context) {
    final cart = Provider.of<CartService>(context, listen: false);
    
    final priceString = service['price']?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0';
    final price = double.tryParse(priceString) ?? 0.0;

    final cartItem = CartItem(
      id: service['id'] ?? '',
      name: service['name'] ?? 'unnamed_service'.tr(),
      price: price,
      quantity: 1,
      imageUrl: service['imageUrl'] ?? '',
      sellerType: 'service',
    );

    cart.addItem(cartItem.id, cartItem.name, cartItem.price, cartItem.imageUrl, cartItem.sellerType);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(),
      ),
    );
  }
}