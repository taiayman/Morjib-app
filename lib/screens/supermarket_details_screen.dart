import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_delivery_app/models/product.dart';
import 'package:my_delivery_app/models/supermarket.dart';
import 'package:my_delivery_app/screens/cart_screen.dart';
import 'package:my_delivery_app/screens/search_screen.dart';
import 'package:my_delivery_app/services/cart_service.dart';
import 'package:my_delivery_app/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:easy_localization/easy_localization.dart';

class MarjaneColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class SupermarketDetailsScreen extends StatefulWidget {
  final Supermarket supermarket;

  const SupermarketDetailsScreen({Key? key, required this.supermarket})
      : super(key: key);

  @override
  _SupermarketDetailsScreenState createState() =>
      _SupermarketDetailsScreenState();
}

class _SupermarketDetailsScreenState extends State<SupermarketDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = true;

  Future<void> _loadProducts() async {
    try {
      List<Product> products = await _firestoreService
          .getSupermarketProducts(widget.supermarket.id);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 2,
      backgroundColor: MarjaneColors.primary,
      iconTheme: IconThemeData(color: Colors.white),
      title: Text(
        widget.supermarket.name,
        style: GoogleFonts.playfairDisplay(
          textStyle: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
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
                  badgeColor: MarjaneColors.accent,
                  padding: EdgeInsets.all(5),
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                  elevation: 0,
                ),
                badgeContent: Text(
                  '${cart.itemCount}',
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                child: IconButton(
                  icon: Icon(Icons.shopping_bag_outlined, color: Colors.white),
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
            color: MarjaneColors.accent,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _navigateToSearchScreen(context),
          icon: Icon(Icons.search, size: 18, color: MarjaneColors.textDark),
          label: Text(
            'Search in ${widget.supermarket.name}',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: MarjaneColors.primary),
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: MarjaneColors.primary,
            side: BorderSide(color: MarjaneColors.primary, width: 2),
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

  Widget _buildProductGrid() {
    return _isLoading
        ? _buildGridShimmerEffect()
        : SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two products per row
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildProductCard(_products[index]);
                },
                childCount: _products.length,
              ),
            ),
          );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: MarjaneColors.secondary.withOpacity(0.2),
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
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: MarjaneColors.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${product.price.toStringAsFixed(2)} MAD',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
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
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MarjaneColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: MarjaneColors.accent,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Provider.of<CartService>(context, listen: false)
                              .addItem(
                            product.id,
                            product.name,
                            product.price,
                            product.imageUrl,
                            'supermarket',
                          );
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
                              backgroundColor: MarjaneColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.add_shopping_cart, size: 18),
                        label: Text('Add to Cart',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MarjaneColors.primary,
                          side: BorderSide(
                              color: MarjaneColors.primary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildGridShimmerEffect() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two products per row
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Shimmer.fromColors(
              baseColor: MarjaneColors.secondary.withOpacity(0.3),
              highlightColor: MarjaneColors.secondary.withOpacity(0.1),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
              ),
            );
          },
          childCount: 4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarjaneColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildSearchBox(),
          ),
          _buildProductGrid(),
        ],
      ),
    );
  }
}
