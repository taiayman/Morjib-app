import 'package:flutter/material.dart';
import 'package:business_management_app/models/company.dart';
import 'package:google_fonts/google_fonts.dart';

class CompanyCard extends StatelessWidget {
  final Company company;
  final bool isDarkTheme;

  CompanyCard({required this.company, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDarkTheme ? Color.fromARGB(255, 60, 59, 57) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            child: Image.network(
              company.imageUrl, // Use the company's image URL
              height: 115.0, // Adjust the height as needed
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        company.name,
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CircleAvatar(
                      radius: 12.0,
                      backgroundColor: _getStatusColor(company.statusColor),
                    ),
                  ],
                ),
                SizedBox(height: 4.0),
                Text(
                  'Employees: ${company.employeeCount}',
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.0), // Adjust height to prevent overflow
        ],
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
        return Colors.green; // Default to green
    }
  }
}