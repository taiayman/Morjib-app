import 'package:flutter/material.dart';
import 'package:business_management_app/models/project.dart';
import 'package:business_management_app/screens/project_details_screen.dart';
import 'package:business_management_app/screens/edit_project_screen.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onView;
  final VoidCallback onUpdate;

  ProjectCard({
    required this.project,
    required this.onView,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4.0,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onView,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: Text('View'),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onUpdate,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: Text('Update'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}