import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/glovo_service.dart';
import 'package:shimmer/shimmer.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final String restaurantUrl;
  final String restaurantImageUrl;

  RestaurantDetailsScreen({
    required this.restaurantId, 
    required this.restaurantName, 
    required this.restaurantUrl,
    required this.restaurantImageUrl,
  });

  @override
  _RestaurantDetailsScreenState createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  final GlovoService _glovoService = GlovoService();
  List<dynamic> _items = [];
  bool _isLoading = true;
  String _error = '';
  List<String> _navigationStack = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurantDetails();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  Future<void> _loadRestaurantDetails() async {
    await _loadContent(_glovoService.getRestaurantDetails(widget.restaurantUrl));
  }

  Future<void> _loadCategoryContent(Category category) async {
    _navigationStack.add(category.url);
    await _loadContent(_glovoService.getCategoryContent(category.url));
  }

  Future<void> _loadContent(Future<List<dynamic>> contentFuture) async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final items = await contentFuture;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load content: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateBack() {
    if (_navigationStack.isNotEmpty) {
      _navigationStack.removeLast();
      if (_navigationStack.isEmpty) {
        _loadRestaurantDetails();
      } else {
        String previousUrl = _navigationStack.last;
        _loadContent(_glovoService.getCategoryContent(previousUrl));
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _loadRestaurantDetails,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    widget.restaurantImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.restaurant, size: 100, color: Colors.grey[400]),
                      );
                    },
                  ),
                ),
                leading: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _navigateBack,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    _items.isNotEmpty && _items.first is Product ? 'Menu' : 'Categories',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _isLoading
                  ? SliverFillRemaining(child: _buildSkeletonLoader())
                  : _error.isNotEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_error, textAlign: TextAlign.center),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadRestaurantDetails,
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _buildItemList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  color: Colors.white,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 20,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 15,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 15,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = _items[index];
          if (item is Product) {
            return _buildProductItem(item);
          } else if (item is Category) {
            return _buildCategoryItem(item);
          }
          return SizedBox.shrink();
        },
        childCount: _items.length,
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Implement product details or add to cart functionality
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: Icon(Icons.fastfood, size: 40, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      product.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} ${product.unit}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return InkWell(
      onTap: () => _loadCategoryContent(category),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
              ),
              child: Image.network(
                widget.restaurantImageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: Icon(Icons.category, size: 50, color: Colors.grey[400]),
                  );
                },
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Text(
                category.name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios),
            SizedBox(width: 16.0),
          ],
        ),
      ),
    );
  }
}