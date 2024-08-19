import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_delivery_app/screens/cart_screen.dart';
import 'package:my_delivery_app/screens/search_screen.dart';
import 'package:my_delivery_app/services/cart_service.dart';
import 'package:provider/provider.dart';
import '../services/marjane_service.dart';
import '../models/category.dart';
import '../models/product.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;

class DeliverooColors {
  static const Color primary = Color(0xFF00CCBC);
  static const Color secondary = Color(0xFF2E3333);
  static const Color background = Color(0xFFF9FAFA);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFFF8000);
}

class MarjaneScreen extends StatefulWidget {
  final String location;

  const MarjaneScreen({Key? key, required this.location}) : super(key: key);

  @override
  _MarjaneScreenState createState() => _MarjaneScreenState();
}

class _MarjaneScreenState extends State<MarjaneScreen> {
  final MarjaneService _marjaneService = MarjaneService();
  final TextEditingController _searchController = TextEditingController();

  Future<List<Category>> _fetchCategories() async {
    return await _marjaneService.getMarjaneCategories(widget.location);
  }

  Future<List<Product>> _fetchCategoryProducts(String categoryUrl) async {
    return await _marjaneService.getCategoryProducts(categoryUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeliverooColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildSearchBox(),
          ),
          FutureBuilder<List<Category>>(
            future: _fetchCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(child: _buildCategoryShimmerEffect());
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('No categories found')),
                );
              } else {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildMarjaneSection(snapshot.data![index]),
                    childCount: snapshot.data!.length,
                  ),
                );
              }
            },
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
      backgroundColor: DeliverooColors.primary,
      iconTheme: IconThemeData(color: Colors.white),
      title: Text(
        'Marjane',
        style: GoogleFonts.poppins(
          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      actions: [
        Consumer<CartService>(
          builder: (context, cart, child) {
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: badges.Badge(
                position: badges.BadgePosition.topEnd(top: 0, end: 3),
                badgeAnimation: badges.BadgeAnimation.rotation(
                  animationDuration: Duration(seconds: 1),
                  colorChangeAnimationDuration: Duration(seconds: 1),
                  loopAnimation: false,
                  curve: Curves.fastOutSlowIn,
                  colorChangeAnimationCurve: Curves.easeInCubic,
                ),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.circle,
                  badgeColor: DeliverooColors.accent,
                  padding: EdgeInsets.all(5),
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                  elevation: 0,
                ),
                badgeContent: Text(
                  '${cart.itemCount}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                child: IconButton(
                  icon: Icon(Icons.shopping_basket, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DeliverooColors.primary,
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
            'Search in Marjane',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DeliverooColors.primary),
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: DeliverooColors.primary,
            side: BorderSide(color: DeliverooColors.primary, width: 2),
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

  Widget _buildMarjaneSection(Category category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            category.name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: DeliverooColors.textDark,
            ),
          ),
        ),
        Container(
          height: 320,
          child: FutureBuilder<List<Product>>(
            future: _fetchCategoryProducts(category.url),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildProductShimmerEffect();
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading products'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No products available'));
              } else {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(snapshot.data![index]);
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: 200,
      height: 300,
      margin: EdgeInsets.only(left: 16, bottom: 16, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                    color: DeliverooColors.primary.withOpacity(0.9),
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
                      color: DeliverooColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: DeliverooColors.accent, size: 16),
                      SizedBox(width: 4),
                      Text(
                        product.averageRating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: DeliverooColors.textLight,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '(${product.numberOfRatings})',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: DeliverooColors.textLight,
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
                            color: DeliverooColors.primary,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Provider.of<CartService>(context, listen: false)
    .addItem(product.id, product.name, product.price, product.imageUrl, product.sellerType); // Pass sellerType
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added to cart',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: DeliverooColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.add_shopping_cart, size: 18),
                        label: Text('Add to Cart', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: DeliverooColors.primary,
                          side: BorderSide(color: DeliverooColors.primary, width: 2),
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

  Widget _buildCategoryShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          _buildSearchBoxShimmer(),
          ...List.generate(3, (index) => _buildShimmerSection()),
        ],
      ),
    );
  }

  Widget _buildSearchBoxShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildProductShimmerEffect() {
    return ListView.builder(
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
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
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
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
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
          ),
        );
      },
    );
  }

  Widget _buildShimmerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Container(
            width: 150,
            height: 24,
            color: Colors.white,
          ),
        ),
        Container(
          height: 320,
          child: _buildProductShimmerEffect(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}