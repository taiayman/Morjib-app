import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/medicine_service.dart';
import '../models/product.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import './cart_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:easy_localization/easy_localization.dart';

class MedicineColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class MedicineScreen extends StatefulWidget {
  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  final MedicineService _medicineService = MedicineService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _medicineService.getMedicineProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final nameMatch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final categoryMatch = _selectedCategory == 'All' || product.category == _selectedCategory;
        return nameMatch && categoryMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedicineColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildCategoryFilter(),
          _isLoading ? _buildShimmerGrid() : _buildProductGrid(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 2,
      backgroundColor: MedicineColors.primary,
      iconTheme: IconThemeData(color: Colors.white),
      title: Text(
        'medicine'.tr(),
        style: GoogleFonts.playfairDisplay(
          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
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
                  badgeColor: MedicineColors.accent,
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

  Widget _buildCategoryFilter() {
    final categories = ['All', ...Set.from(_products.map((p) => p.category))];
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: EdgeInsets.symmetric(vertical: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8),
              child: ChoiceChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = category;
                      _filterProducts();
                    });
                  }
                },
                selectedColor: MedicineColors.primary,
                backgroundColor: Colors.white,
                labelStyle: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    color: _selectedCategory == category ? Colors.white : MedicineColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    final groupedProducts = groupProductsByCategory(_filteredProducts);
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final category = groupedProducts.keys.elementAt(index);
          final products = groupedProducts[category]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text(
                  category,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MedicineColors.textDark,
                  ),
                ),
              ),
              Container(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(products[index]);
                  },
                ),
              ),
              SizedBox(height: 16),
            ],
          );
        },
        childCount: groupedProducts.length,
      ),
    );
  }

  Map<String, List<Product>> groupProductsByCategory(List<Product> products) {
    return groupBy(products, (Product p) => p.category);
  }

  Map<K, List<T>> groupBy<T, K>(Iterable<T> values, K Function(T) keyFunction) {
    return values.fold(<K, List<T>>{}, (Map<K, List<T>> map, T element) {
      K key = keyFunction(element);
      if (!map.containsKey(key)) {
        map[key] = <T>[];
      }
      map[key]!.add(element);
      return map;
    });
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: 200,
      height: 300,
      margin: EdgeInsets.only(bottom: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: MedicineColors.secondary.withOpacity(0.2),
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
                    color: MedicineColors.primary.withOpacity(0.9),
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
                      color: MedicineColors.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: MedicineColors.accent,
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
                              backgroundColor: MedicineColors.primary,
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
                          foregroundColor: MedicineColors.primary,
                          side: BorderSide(color: MedicineColors.primary, width: 2),
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

  Widget _buildShimmerGrid() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Shimmer.fromColors(
            baseColor: MedicineColors.secondary.withOpacity(0.3),
            highlightColor: MedicineColors.secondary.withOpacity(0.1),
            child: Column(
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
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, productIndex) {
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
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        childCount: 3,
      ),
    );
  }
}