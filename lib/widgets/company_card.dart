import 'package:flutter/material.dart';
import 'package:business_management_app/models/company.dart';

class CompanyCard extends StatelessWidget {
  final Company company;
  CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // Set the background color to white
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        // Remove the side parameter to remove the grey border
      ),
      elevation: 4.0,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  company.name,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CircleAvatar(
                  radius: 12.0,
                  backgroundColor: _getStatusColor(company.statusColor),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              'Employees: ${company.employeeCount}',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String statusColor) {
    switch (statusColor) {
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}