import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_delivery_app/screens/address_capture_screen.dart';
import 'package:my_delivery_app/screens/forgot_password_screen.dart';
import 'package:my_delivery_app/screens/welcome_screen.dart';
import 'package:my_delivery_app/screens/phone_auth_screen.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/traditional_market_screen.dart';
import 'screens/shops_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/order_confirmation_screen.dart';
import 'screens/points_history_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/unknown_route_screen.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/notification_service.dart';
import 'services/payment_service.dart';
import 'services/chat_service.dart';
import 'services/recommendation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();

  final paymentService = PaymentService();
  // Removed: await paymentService.initializeStripe(); 

  final chatService = ChatService();
  final recommendationService = RecommendationService();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('fr', 'FR'), Locale('ar')],
      path: 'assets/translations', 
      fallbackLocale: Locale('fr', 'FR'),
      startLocale: Locale('fr', 'FR'),
      child: MyApp(
        notificationService: notificationService,
        paymentService: paymentService,
        chatService: chatService,
        recommendationService: recommendationService,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;
  final PaymentService paymentService;
  final ChatService chatService;
  final RecommendationService recommendationService;

  const MyApp({
    Key? key,
    required this.notificationService,
    required this.paymentService,
    required this.chatService,
    required this.recommendationService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, CartService>(
          create: (_) => CartService(),
          update: (_, authService, previousCartService) =>
              previousCartService!..updateUserId(authService.currentUser?.uid),
        ),
        Provider<NotificationService>.value(value: notificationService),
        Provider<PaymentService>.value(value: paymentService),
        Provider<ChatService>.value(value: chatService),
        Provider<RecommendationService>.value(value: recommendationService),
      ],
      child: MaterialApp(
        title: 'My Delivery App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: WelcomeScreen(), 
        routes: {
          '/welcome': (context) => WelcomeScreen(),
          '/home': (context) => HomeScreen(),
          '/phone-auth': (context) => PhoneAuthScreen(email: '', password: ''),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/profile': (context) => ProfileScreen(),          '/traditional_market': (context) => TraditionalMarketScreen(location: 'casablanca'),
          '/shops': (context) => ShopsScreen(),
          '/checkout': (context) => CheckoutScreen(),
          '/search': (context) => SearchScreen(),
          '/forgot-password': (context) => ForgotPasswordScreen(),
          '/favorites': (context) => FavoritesScreen(),
          '/order_history': (context) => OrderHistoryScreen(),
          '/order_confirmation': (context) => OrderConfirmationScreen(orderId: ModalRoute.of(context)!.settings.arguments as String),
          '/points_history': (context) => PointsHistoryScreen(),
          '/chat_list': (context) => ChatListScreen(),
          '/product_details': (context) => ProductDetailsScreen(productId: ModalRoute.of(context)!.settings.arguments as String),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => UnknownRouteScreen());
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return FutureBuilder<bool>(
      future: authService.isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          if (snapshot.data == true) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        }
      },
    );
  }
}