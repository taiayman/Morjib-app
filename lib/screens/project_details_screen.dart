import 'package:flutter/material.dart';
import 'package:business_management_app/models/project.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final Project project;

  ProjectDetailsScreen({required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(project.details),
            SizedBox(height: 16),
            Text(
              'Goals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('goals here'),
            SizedBox(height: 16),
            Text(
              'Start and end date',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('${project.start.toLocal()} to ${project.end.toLocal()}'),
            SizedBox(height: 16),
            Text(
              'Budget',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('${project.budget}'),
            SizedBox(height: 16),
            Text(
              'Team members',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Team member image URL
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Team member image URL
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Team member image URL
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
