import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_delivery_app/screens/cart_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../services/marjane_service.dart';
import '../services/cart_service.dart';
import '../models/product.dart';
import '../models/category.dart';
import 'package:badges/badges.dart' as badges;
import 'package:easy_localization/easy_localization.dart';

class DeliverooColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MarjaneService _marjaneService = MarjaneService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  List<Category> _categories = [];
  int _currentCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _marjaneService.getMarjaneCategories('casablanca');
      setState(() {
        _categories = categories;
      });
      _loadProductsFromCategory();
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProductsFromCategory() async {
    if (_currentCategoryIndex >= _categories.length) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    try {
      final categoryProducts = await _marjaneService.getCategoryProducts(_categories[_currentCategoryIndex].url);
      setState(() {
        _allProducts.addAll(categoryProducts);
        _filteredProducts = _allProducts;
        _isLoading = false;
        _currentCategoryIndex++;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (!_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });
      await _loadProductsFromCategory();
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _allProducts.where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeliverooColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSearchBox()),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: _isLoading
                ? SliverToBoxAdapter(child: _buildCategoryShimmerEffect())
                : SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < _filteredProducts.length) {
                          return _buildProductCard(_filteredProducts[index]);
                        } else if (_isLoadingMore) {
                          return _buildProductShimmer();
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                      childCount: _filteredProducts.length + (_isLoadingMore ? 2 : 0),
                    ),
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
      backgroundColor: DeliverooColors.primary,
      iconTheme: IconThemeData(color: Colors.white),
      title: Text(
        'search_marjane'.tr(),
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
                  style: TextStyle(color: DeliverooColors.primary, fontWeight: FontWeight.bold),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
        child: TextField(
          controller: _searchController,
          onChanged: _performSearch,
          decoration: InputDecoration(
            hintText: 'search_marjane_products'.tr(),
            prefixIcon: Icon(Icons.search, color: DeliverooColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: DeliverooColors.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: DeliverooColors.primary, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: DeliverooColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: DeliverooColors.textDark,
          ),
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
            color: DeliverooColors.primary.withOpacity(0.1),
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
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DeliverooColors.secondary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${product.price.toStringAsFixed(2)} MAD',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: DeliverooColors.primary,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DeliverooColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: DeliverooColors.accent, size: 14),
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
                        color: DeliverooColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () {
                          // Add to cart functionality
                        },
                        child: Text(
                          'add_to_cart'.tr(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
      baseColor: DeliverooColors.secondary.withOpacity(0.3),
      highlightColor: DeliverooColors.secondary.withOpacity(0.1),
      child: Container(
        height: 100,
        color: Colors.white,
      ),
    );
  }

  Widget _buildProductShimmer() {
    return Shimmer.fromColors(
      baseColor: DeliverooColors.secondary.withOpacity(0.3),
      highlightColor: DeliverooColors.secondary.withOpacity(0.1),
      child: Container(
        height: 200,
        color: Colors.white,
      ),
    );
  }
}