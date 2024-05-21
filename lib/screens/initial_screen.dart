import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    String? userRole = await _storage.read(key: 'userRole');
    if (userRole != null) {
      if (userRole == 'Boss') {
        Navigator.pushReplacementNamed(context, '/boss_dashboard');
      } else if (userRole == 'CEO') {
        Navigator.pushReplacementNamed(context, '/ceo_dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('Welcome', style: GoogleFonts.nunito(color: Colors.white)),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 150),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login', arguments: 'Boss');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD97757),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('I am a Boss', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login', arguments: 'CEO');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD97757),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('I am a CEO', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
