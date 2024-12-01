import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_delivery_app/screens/checkout_screen.dart';
import 'package:my_delivery_app/screens/home_screen.dart';
import 'package:my_delivery_app/screens/traditional_market_details_screen.dart';
import 'package:my_delivery_app/screens/welcome_screen.dart';
import 'package:my_delivery_app/services/traditional_market_service.dart';
import 'package:my_delivery_app/screens/cart_screen.dart';
import 'package:my_delivery_app/screens/search_screen.dart';
import 'package:my_delivery_app/services/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:easy_localization/easy_localization.dart';
import '../models/traditional_market.dart';

class TraditionalMarketColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class TraditionalMarketScreen extends StatefulWidget {
  final String location;

  const TraditionalMarketScreen({Key? key, required this.location}) : super(key: key);

  @override
  _TraditionalMarketScreenState createState() => _TraditionalMarketScreenState();
}

class _TraditionalMarketScreenState extends State<TraditionalMarketScreen> {
  final TraditionalMarketService _marketService = TraditionalMarketService();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeFirstCategory();
  }

  void _initializeFirstCategory() async {
    final categories = await _marketService.getCategories().first;
    if (categories.docs.isNotEmpty) {
      setState(() {
        _selectedCategoryId = categories.docs.first.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TraditionalMarketColors.background,
      body: CustomScrollView(
        slivers: [
          buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: _buildSearchBox(),
          ),
          _buildAllMarkets(),
        ],
      ),
    );
  }

  Widget buildSliverAppBar(BuildContext context) {
  return SliverAppBar(
    floating: false,
    pinned: true,
    snap: false,
    elevation: 4,
    backgroundColor: TraditionalMarketColors.primary,
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
        'traditional_market'.tr(),
        style: GoogleFonts.playfairDisplay(
          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      centerTitle: false,
      titlePadding: EdgeInsets.only(left: 56, bottom: 16),
    ),
    actions: [
      Consumer<CartService>(
        builder: (context, cart, child) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: -8, end: -3),
                badgeAnimation: badges.BadgeAnimation.rotation(
                  animationDuration: Duration(seconds: 1),
                  colorChangeAnimationDuration: Duration(seconds: 1),
                  loopAnimation: false,
                  curve: Curves.fastOutSlowIn,
                  colorChangeAnimationCurve: Curves.easeInCubic,
                ),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.circle,
                  badgeColor: TraditionalMarketColors.accent,
                  padding: EdgeInsets.all(5),
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                  elevation: 0,
                ),
                badgeContent: Text(
                  '${cart.itemCount}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: TraditionalMarketColors.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
                  color: TraditionalMarketColors.textLight.withOpacity(0.3),
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
          color: TraditionalMarketColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: TraditionalMarketColors.primary),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: TraditionalMarketColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: TraditionalMarketColors.textLight,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: TraditionalMarketColors.textLight),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  void _navigateToSearchScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () => _navigateToSearchScreen(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: TraditionalMarketColors.textLight),
              SizedBox(width: 12),
              Text(
                'search_markets'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: TraditionalMarketColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllMarkets() {
    return StreamBuilder<List<TraditionalMarket>>(
      stream: _marketService.getTraditionalMarkets(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(child: _buildMarketsShimmer());
        }

        final markets = snapshot.data ?? [];
        if (markets.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text(
                'no_markets_available'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: TraditionalMarketColors.textLight,
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'all_markets'.tr(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: TraditionalMarketColors.textDark,
                    ),
                  ),
                );
              }
              final market = markets[index - 1];
              return _buildMarketCard(context, market);
            },
            childCount: markets.length + 1,
          ),
        );
      },
    );
  }

  void _showFirstTimeCartDialog(String productName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'item_added_to_cart'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: TraditionalMarketColors.textDark,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'pay_now_or_continue_shopping'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: TraditionalMarketColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartScreen()),
                        );
                      },
                      child: Text(
                        'buy_now'.tr(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: TraditionalMarketColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'continue_shopping'.tr(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TraditionalMarketColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TraditionalMarketColors.primary,
                        side: BorderSide(color: TraditionalMarketColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class TraditionalDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  final String categoryId;

  TraditionalDetailsScreen({required this.product, required this.categoryId}) {
    if (product['price'] is int) {
      product['price'] = (product['price'] as int).toDouble();
    }
  }

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
                product['name'],
                style: GoogleFonts.playfairDisplay(
                  textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product['imageUrl'],
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, TraditionalMarketColors.primary.withOpacity(0.7)],
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
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('categories').doc(categoryId).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(color: TraditionalMarketColors.secondary);
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Text('category_not_found'.tr());
                      }
                      final categoryData = snapshot.data!.data() as Map<String, dynamic>;
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: TraditionalMarketColors.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          categoryData['name'] ?? 'traditional_product'.tr(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: TraditionalMarketColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'description'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: TraditionalMarketColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product['description'] ?? 'no_description_available'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: TraditionalMarketColors.textLight,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'price'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: TraditionalMarketColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${(product['price'] as double).toStringAsFixed(2)} MAD',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: TraditionalMarketColors.primary,
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => _confirmBooking(context),
                    child: Text(
                      'buy_now'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: TraditionalMarketColors.primary,
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
            'confirm_booking'.tr(),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: TraditionalMarketColors.textDark,
              fontSize: 20,
            ),
          ),
          content: Text(
            'confirm_booking_message'.tr(),
            style: GoogleFonts.poppins(
              color: TraditionalMarketColors.textLight,
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'cancel'.tr(),
                style: GoogleFonts.poppins(
                  color: TraditionalMarketColors.textLight,
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
                backgroundColor: TraditionalMarketColors.primary,
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
    
    cart.addItem(
      product['name'],
      product['name'],
      product['price'] as double,
      product['imageUrl'],
      'traditional',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(),
      ),
    );
  }
}

Widget _buildMarketCard(BuildContext context, TraditionalMarket market) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TraditionalMarketDetailsScreen(
              market: market,
            ),
          ),
        );
      },
      child: Row(
        children: [
          Hero(
            tag: 'market_image_${market.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                market.imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    market.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TraditionalMarketColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    market.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: TraditionalMarketColors.textLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${market.rating.toStringAsFixed(1)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: TraditionalMarketColors.textDark,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: TraditionalMarketColors.textLight,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildMarketsShimmer() {
  return ListView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(horizontal: 16),
    itemCount: 5,
    itemBuilder: (context, index) {
      return Container(
        height: 120,
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            children: [
              Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: 150,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: 100,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}