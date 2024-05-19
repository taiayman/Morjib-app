// latest_project_card.dart
import 'package:flutter/material.dart';
import 'package:business_management_app/models/project.dart';

class LatestProjectCard extends StatelessWidget {
  final Project project;

  LatestProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
        side: BorderSide(
          color: Colors.grey,
          width: 1,
          strokeAlign: BorderSide.strokeAlignCenter, // Center the border
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2.0), // Add padding at the bottom
        child: ListTile(
          title: Text(project.name, style: Theme.of(context).textTheme.headline6),
          subtitle: Text('Status: ${project.status}\nBudget: \$${project.budget}'),
          onTap: () {
            // Handle card tap
          },
        ),
      ),
    );
  }
}