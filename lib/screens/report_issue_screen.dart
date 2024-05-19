import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportIssueScreen extends StatefulWidget {
  @override
  _ReportIssueScreenState createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _issueController = TextEditingController();

  void _reportIssue() {
    final issue = _issueController.text;
    // Implement issue reporting logic here
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('Report an Issue', style: GoogleFonts.rubik()),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _issueController,
              decoration: InputDecoration(
                labelText: 'Describe the issue',
                labelStyle: GoogleFonts.rubik(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 5,
              style: GoogleFonts.rubik(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _reportIssue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97757),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                textStyle: GoogleFonts.rubik(fontSize: 18),
              ),
              child: Text('Report Issue', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
