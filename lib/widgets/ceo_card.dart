import 'package:flutter/material.dart';
import 'package:business_management_app/models/user.dart';
import 'package:google_fonts/google_fonts.dart';

class CEOCard extends StatelessWidget {
  final User user;
  final bool isDarkTheme;

  CEOCard({required this.user, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.profileImage ?? 'https://via.placeholder.com/150'),
          radius: 40,
        ),
        SizedBox(height: 8),
        Container(
          width: 80,
          child: Text(
            user.name,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkTheme ? Colors.white : Colors.black, // Change text color based on dark mode
              ),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}