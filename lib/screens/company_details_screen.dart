import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_management_app/models/company.dart';
import 'package:business_management_app/services/company_service.dart';

class CompanyDetailsScreen extends StatelessWidget {
  final String companyId;

  CompanyDetailsScreen({required this.companyId});

  final CompanyService _companyService = CompanyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('Company Details', style: GoogleFonts.rubik()),
        backgroundColor: Color(0xFFD97757),
      ),
      body: FutureBuilder<Company>(
        future: _companyService.getCompanyById(companyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading company details'));
          } else {
            Company? company = snapshot.data;
            return company != null ? _buildCompanyDetails(context, company) : Center(child: Text('Company not found'));
          }
        },
      ),
    );
  }

  Widget _buildCompanyDetails(BuildContext context, Company company) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company.name,
            style: GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'CEO ID: ${company.ceoId}',
            style: GoogleFonts.rubik(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            'Projects',
            style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: company.projects.length,
              itemBuilder: (context, index) {
                var project = company.projects[index];
                return ListTile(
                  title: Text(project, style: GoogleFonts.rubik()),
                  // Modify the line below if your project contains more details
                  subtitle: Text('Project details here', style: GoogleFonts.rubik()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
