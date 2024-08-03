import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_delivery_app/screens/restaurant_screen.dart';
import 'package:my_delivery_app/widgets/restaurant_card.dart';
import 'package:my_delivery_app/models/restaurant.dart';
import 'package:my_delivery_app/services/glovo_service.dart';
import 'package:my_delivery_app/services/location_service.dart';
import 'package:shimmer/shimmer.dart';

class CustomColors {
  static const Color primaryPeach = Color(0xFFFFB347);
  static const Color accentTeal = Color(0xFF40E0D0);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Color(0xFF7C7C7C);
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlovoService _glovoService = GlovoService();
  final LocationService _locationService = LocationService();
  List<Restaurant> _popularRestaurants = [];
  bool _isLoading = true;
  String _selectedCity = 'Loading...';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    String currentCity = await _locationService.getCurrentCity();
    setState(() {
      _selectedCity = currentCity;
    });
    _loadPopularRestaurants();
  }

  Future<void> _loadPopularRestaurants() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var restaurants = await _glovoService.getPopularRestaurants(_selectedCity.toLowerCase());
      setState(() {
        _popularRestaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading popular restaurants: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load popular restaurants. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: [0.0, 0.3, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 26,
                  child: Container(
                    width: 80,
                    height: 20,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  left: 25,
                  bottom: 60,
                  right: 100,
                  child: Container(
                    height: 48,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 80,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 60,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        itemCount: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.primaryPeach,
      appBar: AppBar(
        backgroundColor: CustomColors.primaryPeach,
        elevation: 0,
        title: Text(
          'FoodDash',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(color: CustomColors.accentTeal, fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'What are you craving?',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: CustomColors.textDark),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    hintText: "Search for dishes, restaurants...",
                    hintStyle: GoogleFonts.poppins(textStyle: TextStyle(color: CustomColors.textLight)),
                    prefixIcon: Icon(Icons.search, color: CustomColors.accentTeal),
                    suffixIcon: Icon(Icons.mic, color: CustomColors.accentTeal),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryItem('Restaurants', 'assets/images/restaurant.png', true),
                  _buildCategoryItem('Fast Food', 'assets/images/fast-food.png', false),
                  _buildCategoryItem('Carrefour', 'assets/images/carrefour.png', false),
                  _buildCategoryItem('Medicine', 'assets/images/medicine.png', false),
                ],
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department, color: CustomColors.accentTeal),
                      SizedBox(width: 8),
                      Text(
                        'Popular This Week',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CustomColors.textDark),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _isLoading
                      ? _buildShimmerEffect()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _popularRestaurants.length,
                          itemBuilder: (context, index) {
                            return RestaurantCard(
                              restaurant: _popularRestaurants[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RestaurantScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String label, String iconPath, bool isRestaurant) {
    return GestureDetector(
      onTap: isRestaurant
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RestaurantScreen()),
              );
            }
          : null,
      child: Container(
        width: 80,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(iconPath, width: 40, height: 40),
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: CustomColors.textDark),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}