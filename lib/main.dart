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
import 'package:business_management_app/utils/theme.dart';
import 'package:business_management_app/screens/ai_chat_screen.dart'; // Import AI Chat Screen
import 'package:business_management_app/screens/settings_screen.dart'; // Import Settings Screen
import 'package:business_management_app/screens/notifications_screen.dart'; // Import Notifications Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Management App',
      theme: appTheme(),
      home: InitialScreen(), // Set the home to InitialScreen
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/boss_dashboard': (context) => BossDashboard(),
        '/ceo_dashboard': (context) => CEODashboard(),
        '/profile': (context) => ProfileScreen(),
        '/company_details': (context) => CompanyDetailsScreen(companyId: ModalRoute.of(context)!.settings.arguments as String),
        '/add_project': (context) => AddProjectScreen(companyId: ModalRoute.of(context)!.settings.arguments as String),
      },
    );
  }
}

