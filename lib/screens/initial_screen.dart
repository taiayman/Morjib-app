import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('Welcome', style: GoogleFonts.rubik()),
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
                  textStyle: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('I am a Boss', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('CEO Login or Sign Up', style: GoogleFonts.rubik()),
                      content: Text('Are you an existing CEO or a new CEO?', style: GoogleFonts.rubik()),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            Navigator.pushNamed(context, '/login', arguments: 'CEO');
                          },
                          child: Text('Login', style: GoogleFonts.rubik(color: Color(0xFFD97757))),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text('Sign Up', style: GoogleFonts.rubik(color: Color(0xFFD97757))),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD97757),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.bold),
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
