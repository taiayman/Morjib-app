import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_delivery_app/services/traditional_market_service.dart';
import 'package:my_delivery_app/screens/cart_screen.dart';
import 'package:my_delivery_app/services/cart_service.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;

class TraditionalMarketColors {
  static const Color primary = Color(0xFFB75D69);
  static const Color secondary = Color(0xFFEBAA62);
  static const Color background = Color(0xFFFAE8D7);
  static const Color textDark = Color(0xFF4A3034);
  static const Color textLight = Color(0xFF8E5D52);
  static const Color accent = Color(0xFFE06C78);
  static const Color neutral = Color(0xFFD2A979);
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
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildSearchBox(),
          ),
          SliverToBoxAdapter(
            child: _buildCategoryList(),
          ),
          _buildProductList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: TraditionalMarketColors.primary,
      iconTheme: IconThemeData(color: TraditionalMarketColors.background),
      title: Text(
        'Traditional Market',
        style: GoogleFonts.poppins(
          textStyle: TextStyle(color: TraditionalMarketColors.background, fontWeight: FontWeight.bold, fontSize: 24),
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
                  badgeColor: TraditionalMarketColors.accent,
                  padding: EdgeInsets.all(5),
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                  elevation: 0,
                ),
                badgeContent: Text(
                  '${cart.itemCount}',
                  style: TextStyle(color: TraditionalMarketColors.background, fontWeight: FontWeight.bold),
                ),
                child: IconButton(
                  icon: Icon(Icons.shopping_basket, color: TraditionalMarketColors.background),
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
            color: TraditionalMarketColors.primary,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            // TODO: Implement search functionality
          },
          icon: Icon(Icons.search, size: 18, color: const Color.fromARGB(255, 60, 60, 60)),
          label: Text(
            'Search in Traditional Market',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: TraditionalMarketColors.primary),
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: TraditionalMarketColors.primary,
            side: BorderSide(color: TraditionalMarketColors.primary, width: 2),
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

  Widget _buildCategoryList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _marketService.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCategoryShimmerEffect();
        }

        return Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(
                    data['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _selectedCategoryId == document.id ? TraditionalMarketColors.background : TraditionalMarketColors.textDark,
                    ),
                  ),
                  selected: _selectedCategoryId == document.id,
                  selectedColor: TraditionalMarketColors.primary,
                  backgroundColor: TraditionalMarketColors.neutral,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryId = selected ? document.id : null;
                    });
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductList() {
    if (_selectedCategoryId == null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(
            'Select a category to view products',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: TraditionalMarketColors.textLight,
            ),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _marketService.getProductsByCategory(_selectedCategoryId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(child: _buildProductShimmerEffect());
        }

        final filteredProducts = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildProductCard(filteredProducts[index]),
            childCount: filteredProducts.length,
          ),
        );
      },
    );
  }

  Widget _buildProductCard(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: TraditionalMarketColors.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    data['imageUrl'] ?? 'https://via.placeholder.com/150',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: TraditionalMarketColors.secondary.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${data['price'].toStringAsFixed(2)} MAD',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: TraditionalMarketColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TraditionalMarketColors.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: TraditionalMarketColors.accent, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '4.5',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: TraditionalMarketColors.textLight,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '(120)',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: TraditionalMarketColors.textLight,
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
                          color: TraditionalMarketColors.primary,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Provider.of<CartService>(context, listen: false)
                            .addItem(document.id, data['name'], data['price'], data['imageUrl'], data['sellerType']);
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
                            backgroundColor: TraditionalMarketColors.primary,
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
                        foregroundColor: TraditionalMarketColors.primary,
                        side: BorderSide(color: TraditionalMarketColors.primary, width: 2),
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
        ],
      ),
    );
  }

  Widget _buildCategoryShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: TraditionalMarketColors.neutral.withOpacity(0.3),
      highlightColor: TraditionalMarketColors.neutral,
      child: Container(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Chip(
                label: Container(
                  width: 80,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductShimmerEffect() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Shimmer.fromColors(
            baseColor: TraditionalMarketColors.neutral.withOpacity(0.3),
            highlightColor: TraditionalMarketColors.neutral,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
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
                'Item Added to Cart',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: TraditionalMarketColors.textDark,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Would you like to pay now or continue shopping?',
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
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: TraditionalMarketColors.primary,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartScreen()),
                          );
                        },
                        child: Text(
                          'Buy now',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TraditionalMarketColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: TraditionalMarketColors.primary,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TraditionalMarketColors.primary,
                          side: BorderSide(color: TraditionalMarketColors.primary, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white,
                        ),
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