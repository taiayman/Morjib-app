import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:business_management_app/screens/login.dart';
import 'package:business_management_app/screens/boss_dashboard.dart';
import 'package:business_management_app/screens/ceo_dashboard.dart';
import 'package:business_management_app/screens/signup.dart';
import 'package:business_management_app/screens/profile_screen.dart';
import 'package:business_management_app/screens/company_details_screen.dart';
import 'package:business_management_app/screens/add_project_screen.dart';
import 'package:business_management_app/screens/initial_screen.dart';
import 'package:business_management_app/screens/ai_chat_screen.dart';
import 'package:business_management_app/screens/settings_screen.dart';
import 'package:business_management_app/screens/notifications_screen.dart';
import 'package:business_management_app/screens/admin_screen.dart';
import 'package:business_management_app/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Management App',
      theme: appTheme(_isDarkTheme),
      home: InitialScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/boss_dashboard': (context) => BossDashboard(isDarkTheme: _isDarkTheme),
        '/ceo_dashboard': (context) => CEODashboard(isDarkTheme: _isDarkTheme),
        '/profile': (context) => ProfileScreen(),
        '/company_details': (context) => CompanyDetailsScreen(companyId: ModalRoute.of(context)!.settings.arguments as String),
        '/add_project': (context) => AddProjectScreen(
          companyId: ModalRoute.of(context)!.settings.arguments as String,
          companyName: 'companyNamePlaceholder',
        ),
        '/ai_chat': (context) => AIChatScreen(isDarkTheme: _isDarkTheme),
        '/settings': (context) => SettingsScreen(onThemeChanged: _toggleTheme, isDarkTheme: _isDarkTheme),
        '/admin': (context) => AdminScreen(),
      },
    );
  }
}
