import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_delivery_app/models/supermarket.dart';
import 'package:my_delivery_app/screens/services_screen.dart';
import 'package:my_delivery_app/screens/supermarket_details_screen.dart';
import 'package:my_delivery_app/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;

import 'package:my_delivery_app/screens/cart_screen.dart';
import 'package:my_delivery_app/screens/marjane_screen.dart';
import 'package:my_delivery_app/screens/medicine_screen.dart';
import 'package:my_delivery_app/screens/carrefour_screen.dart';
import 'package:my_delivery_app/screens/profile_screen.dart';
import 'package:my_delivery_app/screens/search_screen.dart';
import 'package:my_delivery_app/screens/traditional_market_screen.dart';
import 'package:my_delivery_app/screens/points_history_screen.dart';

import 'package:my_delivery_app/services/location_service.dart';
import 'package:my_delivery_app/services/marjane_service.dart';
import 'package:my_delivery_app/services/cart_service.dart';
import 'package:my_delivery_app/services/auth_service.dart';
import 'package:my_delivery_app/services/firestore_service.dart';

import 'package:my_delivery_app/models/category.dart';
import 'package:my_delivery_app/models/product.dart';

import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MarjaneService _marjaneService = MarjaneService();
  final LocationService _locationService = LocationService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  bool _isLoadingProducts = true;
  String _selectedCity = 'Loading...';
  List<Category> _randomCategories = [];
  Map<String, List<Product>> _categoryProducts = {};
  Stream<int>? _userPointsStream;
  int _currentPoints = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _initializeLocation();
    await _initializeUserPointsStream();
    await _loadMarjaneData();
  }

  Future<void> _initializeLocation() async {
    String currentCity = await _locationService.getCurrentCity();
    setState(() {
      _selectedCity = currentCity;
      _isLoading = false;
    });
  }

  Future<void> _initializeUserPointsStream() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;
    if (userId != null) {
      _userPointsStream = _firestoreService.getUserPointsStream(userId);
      _currentPoints = await _firestoreService.getUserPoints(userId);
      setState(() {});
    }
  }

  Future<void> _loadMarjaneData() async {
    try {
      List<Category> allCategories = await _marjaneService.getMarjaneCategories(_selectedCity);
      allCategories.shuffle();
      _randomCategories = allCategories.take(3).toList();

      for (var category in _randomCategories) {
        List<Product> products = await _marjaneService.getCategoryProducts(category.url);
        _categoryProducts[category.id] = products;
      }
    } catch (e) {
      print('Error loading Marjane data: $e');
    } finally {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: Color(0xFFE0D5B7), // Light Gold
      appBar: AppBar(
        backgroundColor: Color(0xFFD9251D), // Red
        automaticallyImplyLeading: false, // This line is important
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          },
        ),
        title: GestureDetector(
          onTap: () => _showBottomMenu(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Morjib',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                _buildPointsDisplay(),
                SizedBox(width: 8),
                _buildProfileIcon(),
                SizedBox(width: 8),
                _buildCartIcon(),
              ],
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildAddressBar()),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildCategories()),
          _isLoading || _isLoadingProducts
              ? SliverToBoxAdapter(child: _buildShimmerEffect())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildMarjaneSection(_randomCategories[index]),
                    childCount: _randomCategories.length,
                  ),
                ),
        ],
      ),
    );
  }



  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 2,
      backgroundColor: Color(0xFFD9251D), // Red
      automaticallyImplyLeading: false,
      title: GestureDetector(
        onTap: () => _showBottomMenu(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Morjib',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            children: [
              _buildPointsDisplay(),
              SizedBox(width: 8),
              _buildProfileIcon(),
              SizedBox(width: 8),
              _buildCartIcon(),
            ],
          ),
        ),
      ],
    );
  }

  void _showBottomMenu(BuildContext context) {
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
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Color(0xFF585C5C).withOpacity(0.3), // Light text color
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildBottomMenuItem(
                context,
                Icons.home_outlined,
                Icons.home,
                'Home',
                'Explore services',
                    () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  );
                },
              ),
              _buildBottomMenuItem(
                context,
                Icons.restaurant_outlined,
                Icons.restaurant,
                'Traditionnel',
                'Order local cuisine',
                    () {
                  Navigator.pop(context);
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

  Widget _buildBottomMenuItem(BuildContext context, IconData outlinedIcon, IconData filledIcon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFFE0D5B7), // Light Gold
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(outlinedIcon, color: Color(0xFFD9251D)), // Red
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E3333), // Dark text color
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Color(0xFF585C5C), // Light text color
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF585C5C)), // Light text color
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: Colors.transparent,
      hoverColor: Color(0xFFE0D5B7).withOpacity(0.1), // Light Gold
    );
  }

  Widget _buildPointsDisplay() {
    return StreamBuilder<int>(
      stream: _userPointsStream,
      initialData: _currentPoints,
      builder: (context, snapshot) {
        final points = snapshot.data ?? _currentPoints;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PointsHistoryScreen()),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Color(0xFFD9B382), // Gold
                  size: 16,
                ),
                SizedBox(width: 0),
                Text(
                  '$points pts',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Color(0xFFD9251D), // Red 
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

  Widget _buildProfileIcon() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      },
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.person,
          color: Color(0xFFD9251D), // Red
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCartIcon() {
    return Consumer<CartService>(
      builder: (context, cart, child) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartScreen()),
            );
          },
          child: badges.Badge(
            position: badges.BadgePosition.topEnd(top: -5, end: -5),
            badgeAnimation: badges.BadgeAnimation.rotation(
              animationDuration: Duration(seconds: 1),
              colorChangeAnimationDuration: Duration(seconds: 1),
              loopAnimation: false,
              curve: Curves.fastOutSlowIn,
              colorChangeAnimationCurve: Curves.easeInCubic,
            ),
            badgeStyle: badges.BadgeStyle(
              shape: badges.BadgeShape.circle,
              badgeColor: Color(0xFFD9B382), // Gold
              padding: EdgeInsets.all(5),
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
              elevation: 0,
            ),
            badgeContent: Text(
              '${cart.itemCount}',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xFFD9251D), // Red
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Color(0xFFD9B382).withOpacity(0.8), // Gold
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, color: Colors.white),
          SizedBox(width: 8),
          Text(
            _selectedCity,
            style: GoogleFonts.playfairDisplay(
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFD9251D), // Red
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _navigateToSearchScreen(context),
          icon: Icon(Icons.search, size: 18, color: const Color.fromARGB(255, 60, 60, 60)),
          label: Text(
            'Search in Carrefour & more',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD9251D)), // Red
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFFD9251D), // Red
            side: BorderSide(color: Color(0xFFD9251D), width: 2), // Red
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.white,
          ),
        ),
      ),
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

Widget _buildCategories() {
  return Container(
    height: 200,
    child: FutureBuilder<List<Supermarket>>(
      future: _firestoreService.getSupermarkets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        List<Widget> supermarketItems = [
          SizedBox(width: 16), // Add left padding here
          _buildCategoryItem('Carrefour', 'assets/images/carrefour.jpg', () {
            _navigateWithFadeTransition(CarrefourScreen(location: 'casablanca'));
          }),
          SizedBox(width: 16), // Increase padding between Carrefour and Marjane
          _buildCategoryItem('Marjane', 'assets/images/marjane.png', () {
            _navigateWithFadeTransition(MarjaneScreen(location: 'casablanca'));
          }),
          SizedBox(width: 16), // Add padding after Marjane
        ];

        if (snapshot.hasData) {
          supermarketItems.addAll(snapshot.data!.map((supermarket) => 
            Padding(
              padding: EdgeInsets.only(right: 16), // Add right padding to each dynamic item
              child: _buildDynamicSupermarketItem(supermarket),
            )
          ));
        }

        return ListView(
          scrollDirection: Axis.horizontal,
          children: supermarketItems,
        );

      },
    ),
  );
}

Widget _buildDynamicSupermarketItem(Supermarket supermarket) {
    return GestureDetector(
      onTap: () => _navigateToSupermarketDetails(context, supermarket),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(0xFFD9B382).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFFD9B382),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  supermarket.imageUrl,
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              supermarket.name,
              style: GoogleFonts.playfairDisplay(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD9251D),
                  letterSpacing: 0.5,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

void _navigateToSupermarketDetails(BuildContext context, Supermarket supermarket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupermarketDetailsScreen(supermarket: supermarket),
      ),
    );
  }




  Widget _buildCategoryItem(String label, String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(0xFFD9B382).withOpacity(0.5), // Gold
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFFD9B382), // Gold
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  icon,
                  width: 86,
                  height: 86,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              label,
              style: GoogleFonts.playfairDisplay(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD9251D), // Red
                  letterSpacing: 0.5,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateWithFadeTransition(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildMarjaneSection(Category category) {
    List<Product> products = _categoryProducts[category.id] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(_truncateWithEllipsis(category.name, 14),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3333), // Dark Text Color
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CarrefourScreen(location: 'casablanca')),
                  );
                },
                child: Text(
                  "See all",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD9251D), // Red 
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(products[index]);
            },
          ),
        ),
      ],
    );
  }

  String _truncateWithEllipsis(String text, int maxLength) {
    return (text.length <= maxLength)
        ? text
        : '${text.substring(0, maxLength)}...';
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: 200,
      height: 300,
      margin: EdgeInsets.only(left: 16, bottom: 16, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(
          color: Color(0xFFD9B382).withOpacity(0.5), // Gold
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.5)),
                child: Image.network(
                  product.imageUrl,
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFD9251D).withOpacity(0.9), // Red
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${product.price.toStringAsFixed(2)} MAD',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E3333), // Dark text color
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFD9B382), size: 16), // Gold
                      SizedBox(width: 4),
                      Text(
                        product.averageRating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF585C5C), // Light text color
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${product.numberOfRatings})',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Color(0xFF585C5C), // Light text color
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFD9B382), // Gold
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Provider.of<CartService>(context, listen: false)
                              .addItem(product.id, product.name, product.price, product.imageUrl, product.sellerType);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'added_to_cart'.tr(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Color(0xFFD9251D), // Red
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.add_shopping_cart, size: 18),
                        label: Text('add_to_cart'.tr(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFFD9251D), // Red
                          side: BorderSide(color: Color(0xFFD9251D), width: 2), // Red
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white,
                        ),
                      ),
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

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Color(0xFFD9B382).withOpacity(0.3), // Gold
      highlightColor: Color(0xFFD9B382).withOpacity(0.1), // Gold
      child: Column(
        children: List.generate(3, (index) => _buildShimmerSection()),
      ),
    );
  }

  Widget _buildShimmerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                height: 300,
                margin: EdgeInsets.only(left: 16, bottom: 16, right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 140,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: 100,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}