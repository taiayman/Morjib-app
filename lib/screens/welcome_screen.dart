import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_delivery_app/screens/cart_screen.dart';
import 'package:my_delivery_app/screens/home_screen.dart';
import 'package:my_delivery_app/screens/profile_screen.dart';
import 'package:my_delivery_app/screens/services_screen.dart';
import 'package:my_delivery_app/screens/traditional_market_screen.dart';
import 'package:my_delivery_app/screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_delivery_app/services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';

class DeliverooColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final Color primaryRed = DeliverooColors.primary;
  final Color gold = DeliverooColors.secondary;
  final Color lightGold = DeliverooColors.background;

  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLanguageSelectorVisible = false;

  final List<Map<String, dynamic>> _supportedLocales = [
    {'locale': Locale('en', 'US'), 'flag': '🇺🇸', 'name': 'English'},
    {'locale': Locale('fr', 'FR'), 'flag': '🇫🇷', 'name': 'Français'},
    {'locale': Locale('ar'), 'flag': '🇸🇦', 'name': 'العربية'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setStatusBarColor();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetStatusBarColor();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setStatusBarColor();
    }
  }

  void _setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: primaryRed,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void _resetStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  void _toggleLanguageSelector() {
    setState(() {
      _isLanguageSelectorVisible = !_isLanguageSelectorVisible;
      if (_isLanguageSelectorVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _updateLocale(Locale locale) {
    context.setLocale(locale);
    _toggleLanguageSelector();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> categories = [
      {'title': 'supermarket'.tr(), 'icon': 'assets/icons/supermarkets.png'},
      {'title': 'traditional_markets'.tr(), 'icon': 'assets/icons/traditional_markets.png'},
      {'title': 'services'.tr(), 'icon': 'assets/icons/services.png'},
    ];

    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          _setStatusBarColor();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: lightGold,
              child: SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(context),
                    _buildAddressBar(),
                    Spacer(),
                    _buildFixedCircularCards(context, categories),
                    Spacer(flex: 2),
                  ],
                ),
              ),
            ),
            if (_isLanguageSelectorVisible) _buildLanguageSelector(),
          ],
        ),
        bottomNavigationBar: _buildAccountBanner(context),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: primaryRed,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline, color: primaryRed),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    Text(
                      'search'.tr(),
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _toggleLanguageSelector,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.language, color: primaryRed),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.shopping_bag_outlined, color: primaryRed),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Positioned(
      top: 80,
      right: 16,
      child: ScaleTransition(
        scale: _animation,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 180,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _supportedLocales.map((localeInfo) {
                return ListTile(
                  leading: Text(localeInfo['flag'], style: TextStyle(fontSize: 24)),
                  title: Text(
                    localeInfo['name'],
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  onTap: () => _updateLocale(localeInfo['locale']),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: gold.withOpacity(0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, color: primaryRed),
          SizedBox(width: 8),
          Text(
            "Marrakesh",
            style: GoogleFonts.playfairDisplay(
              textStyle: TextStyle(
                color: primaryRed,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: primaryRed),
        ],
      ),
    );
  }

  Widget _buildAccountBanner(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return FutureBuilder<bool>(
      future: authService.isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }
        if (snapshot.data == true) {
          return SizedBox.shrink();
        }
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'create_account_benefits'.tr(),
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: primaryRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
                child: Text(
                  'sign_up'.tr(),
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFixedCircularCards(BuildContext context, List<Map<String, String>> categories) {
    return Container(
      height: 370,
      width: 370,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: _buildCategoryItem(context, categories[0]['title']!, categories[0]['icon']!),
          ),
          Positioned(
            bottom: 20,
            left: 1,
            child: _buildCategoryItem(context, categories[1]['title']!, categories[1]['icon']!),
          ),
          Positioned(
            bottom: 20,
            right: 1,
            child: _buildCategoryItem(context, categories[2]['title']!, categories[2]['icon']!),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, String iconPath) {
    return GestureDetector(
      onTap: () => _handleCategoryTap(context, title),
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: gold,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 50,
              height: 45,
            ),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: primaryRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCategoryTap(BuildContext context, String category) {
    if (category == 'supermarket'.tr()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else if (category == 'traditional_markets'.tr()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TraditionalMarketScreen(location: 'casablanca'),
        ),
      );
    } else if (category == 'services'.tr()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ServicesScreen()),
      );
    }
  }
}