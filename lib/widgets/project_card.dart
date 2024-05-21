import 'package:flutter/material.dart';
import 'package:business_management_app/models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onView;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  ProjectCard({
    required this.project,
    required this.onView,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0), // Margin left and right
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          // Remove the side BorderSide to remove the outline
        ),
        elevation: 0.0, // Set elevation to 0.0 to remove the shadow
        color: Color.fromARGB(255, 255, 255, 255), // Card background color
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    project.name,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 31, 31, 31),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                project.details,
                style: TextStyle(
                  fontSize: 14.0,
                  color: const Color.fromARGB(179, 75, 75, 75),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onView,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFFD97757)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: Text(
                        'View',
                        style: TextStyle(color: Color(0xFFD97757)),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD97757),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                      ),
                      child: Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
