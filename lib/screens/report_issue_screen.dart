// lib/screens/report_issue_screen.dart

import 'package:flutter/material.dart';

class ReportIssueScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report an Issue'),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Issue Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Issue Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 5,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle issue reporting logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97757),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: Text('Submit Issue', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
