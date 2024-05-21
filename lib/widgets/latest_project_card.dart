import 'package:flutter/material.dart';
import 'package:business_management_app/models/project.dart';
import 'package:business_management_app/screens/project_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LatestProjectCard extends StatelessWidget {
  final Project project;
  final bool isDarkTheme;

  LatestProjectCard({required this.project, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsScreen(
              project: project,
              isDarkTheme: isDarkTheme, // Pass the isDarkTheme value
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        color: isDarkTheme ?  Color.fromARGB(255, 60, 59, 57) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  project.name,
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                subtitle: Text(
                  'Budget: \$${project.budget}',
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0, right: 15.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    project.companyName,
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        color: isDarkTheme ? Colors.grey : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}