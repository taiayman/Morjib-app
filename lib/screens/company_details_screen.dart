import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_management_app/models/company.dart';
import 'package:business_management_app/models/project.dart';
import 'package:business_management_app/services/company_service.dart';
import 'package:business_management_app/services/project_service.dart';
import 'package:business_management_app/services/user_service.dart';
import 'package:business_management_app/models/user.dart' as AppUser;

class CompanyDetailsScreen extends StatelessWidget {
  final String companyId;

  CompanyDetailsScreen({required this.companyId});

  final CompanyService _companyService = CompanyService();
  final ProjectService _projectService = ProjectService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('Company Details', style: GoogleFonts.nunito()),
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
            style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(company.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
          ),
          SizedBox(height: 8),
          Text(
            'CEO: ${company.ceoName}',
            style: GoogleFonts.nunito(fontSize: 16),
          ),
          Text(
            'Email: ${company.ceoEmail}',
            style: GoogleFonts.nunito(fontSize: 16),
          ),
          Text(
            'Phone: ${company.ceoPhone}',
            style: GoogleFonts.nunito(fontSize: 16),
          ),
          Text(
            'WhatsApp: ${company.ceoWhatsApp}',
            style: GoogleFonts.nunito(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            'Projects',
            style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Project>>(
              future: _projectService.getProjectsForCompany(company.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading projects'));
                } else {
                  List<Project>? projects = snapshot.data;
                  return projects != null && projects.isNotEmpty
                      ? ListView.builder(
                          itemCount: projects.length,
                          itemBuilder: (context, index) {
                            var project = projects[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(project.name, style: GoogleFonts.nunito()),
                                subtitle: Text('Budget: \$${project.budget}', style: GoogleFonts.nunito()),
                              ),
                            );
                          },
                        )
                      : Center(child: Text('No projects found'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
