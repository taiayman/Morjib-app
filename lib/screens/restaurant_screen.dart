import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/restaurant_card.dart';
import '../services/glovo_service.dart';
import '../models/restaurant.dart';
import 'restaurant_details_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../services/location_service.dart';

class RestaurantScreen extends StatefulWidget {
  @override
  _RestaurantScreenState createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final GlovoService _glovoService = GlovoService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  bool _isLoading = false;
  String _selectedFilter = 'All';
  List<String> _filters = ['All', 'Rating 4.5+', 'Fastest Delivery', 'Best Deals'];
  String _selectedCity = 'Loading...';
  List<String> _nearbyCities = [];

  final Map<String, String> _cityImages = {
    'Rabat': 'https://tse1.mm.bing.net/th?id=OIP.NIZSevh0UUmnljt4WVxkdgHaFr&pid=Api&P=0&h=180',
    'Marrakech': 'https://tse1.mm.bing.net/th?id=OIP.mXGhJ7EoSWXHd4-8Xyk5jwHaE8&pid=Api&P=0&h=180',
    'Fes': 'https://tse4.mm.bing.net/th?id=OIP.VdznOB51ZWVtoPKrOHwbcgHaE7&pid=Api&P=0&h=180',
    'Tangier': 'https://tse4.mm.bing.net/th?id=OIP.c4gSpU3TwKowVGSFjHEEeQHaE8&pid=Api&P=0&h=180',
    'Agadir': 'https://tse1.mm.bing.net/th?id=OIP.Toai905cGaw1VvbFK4L-9wHaE8&pid=Api&P=0&h=180',
    'Meknes': 'https://tse2.mm.bing.net/th?id=OIP.qx0HNpAX85ir7rA8_YQn6wHaE7&pid=Api&P=0&h=180',
    'Oujda': 'https://tse2.mm.bing.net/th?id=OIP.KpiQoWcu5AultzRBrTct9QHaFc&pid=Api&P=0&h=180',
    'Kenitra': 'https://tse1.mm.bing.net/th?id=OIP.cjWKjG3SFM4hbuvJIZkPFQHaD0&pid=Api&P=0&h=180',
    'Tetouan': 'https://tse2.mm.bing.net/th?id=OIP.eT6Vn3Ka_TZex0uex8gB9QHaE4&pid=Api&P=0&h=180',
    'Safi': 'https://tse2.mm.bing.net/th?id=OIP.S0T-EjP-_1TK3p76TrTKUwHaC9&pid=Api&P=0&h=180',
    'Mohammedia': 'https://tse1.mm.bing.net/th?id=OIP.MyYJwcFf5xa0ACPccibJPwHaEK&pid=Api&P=0&h=180',
    'Khouribga': 'https://tse3.mm.bing.net/th?id=OIP.QgBZ3BqVtuy2A4DXCvn61AHaE8&pid=Api&P=0&h=180',
    'El Jadida': 'https://tse3.mm.bing.net/th?id=OIP.ULGZx66e43OqXIFFkK8CMQHaE0&pid=Api&P=0&h=180',
    'Beni Mellal': 'https://tse3.mm.bing.net/th?id=OIP._sSlPrzGCaOySkXW_29vJQHaEL&pid=Api&P=0&h=180',
    'Nador': 'https://tse4.mm.bing.net/th?id=OIP.O_4hbJsRD2ECFn_mHQjhqgHaD2&pid=Api&P=0&h=180',
    'Taza': 'https://tse2.mm.bing.net/th?id=OIP.1EK0TUneQ5cKRgVnrxq5kAHaEk&pid=Api&P=0&h=180',
    'Settat': 'https://tse4.mm.bing.net/th?id=OIP.9PKPS3c4k8c-snbcWvAtYAHaE5&pid=Api&P=0&h=180',
    'Casablanca': 'https://viagemeturismo.abril.com.br/wp-content/uploads/2016/12/thinkstockphotos-484506846.jpeg',
  };

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    String currentCity = await _locationService.getCurrentCity();
    List<String> nearbyCities = await _locationService.getNearbyMajorCities();
    setState(() {
      _selectedCity = currentCity;
      _nearbyCities = nearbyCities;
    });
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var restaurants = await _glovoService.getRestaurantsForLocation(_selectedCity.toLowerCase());
      setState(() {
        _restaurants = restaurants;
        _filteredRestaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading restaurants: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load restaurants. Please try again.');
    }
  }

  void _filterRestaurants(String query) {
    setState(() {
      _filteredRestaurants = _restaurants
          .where((restaurant) =>
              restaurant.name.toLowerCase().contains(query.toLowerCase()) ||
              restaurant.cuisine.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'Rating 4.5+':
          _filteredRestaurants = _restaurants.where((r) => r.rating >= 90).toList();
          break;
        case 'Fastest Delivery':
          _filteredRestaurants = List.from(_restaurants)
            ..sort((a, b) => a.estimatedDeliveryTime.compareTo(b.estimatedDeliveryTime));
          break;
        case 'Best Deals':
          _filteredRestaurants = _restaurants.where((r) => r.discount > 0).toList();
          break;
        default:
          _filteredRestaurants = List.from(_restaurants);
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 20,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: 100,
                            height: 15,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: 130,
                            height: 15,
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
      ),
    );
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Location', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _nearbyCities.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return ListTile(
                    title: Text(_selectedCity, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    leading: Icon(Icons.location_on, color: Colors.deepOrange),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  );
                }
                return ListTile(
                  title: Text(_nearbyCities[index - 1], style: GoogleFonts.poppins()),
                  onTap: () {
                    setState(() {
                      _selectedCity = _nearbyCities[index - 1];
                    });
                    Navigator.of(context).pop();
                    _loadRestaurants();
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.deepOrange)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _cityImages[_selectedCity] ?? 'https://viagemeturismo.abril.com.br/wp-content/uploads/2016/12/thinkstockphotos-484506846.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.restaurant, size: 50, color: Colors.grey[400]),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(80),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: 'Search restaurants or cuisines',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.location_on, color: Colors.deepOrange),
                        onPressed: _showLocationDialog,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    onChanged: _filterRestaurants,
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) => Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter, style: GoogleFonts.poppins()),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        if (selected) _applyFilter(filter);
                        },
                      selectedColor: Colors.deepOrange.withOpacity(0.2),
                      labelStyle: GoogleFonts.poppins(
                        color: _selectedFilter == filter ? Colors.deepOrange : Colors.black,
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),
          ),
          _isLoading
              ? SliverFillRemaining(
                  child: _buildSkeletonLoader(),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: RestaurantCard(
                          restaurant: _filteredRestaurants[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailsScreen(
                                  restaurantId: _filteredRestaurants[index].id,
                                  restaurantName: _filteredRestaurants[index].name,
                                  restaurantUrl: _filteredRestaurants[index].url,
                                  restaurantImageUrl: _filteredRestaurants[index].imageUrl,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: _filteredRestaurants.length,
                  ),
                ),
        ],
      ),
    );
  }
}