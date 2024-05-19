import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_management_app/models/company.dart';
import 'package:business_management_app/models/project.dart';
import 'package:business_management_app/services/company_service.dart';
import 'package:business_management_app/services/project_service.dart';
import 'package:business_management_app/services/user_service.dart';
import 'package:business_management_app/models/user.dart' as AppUser;
import 'package:business_management_app/screens/add_project_screen.dart';
import 'package:business_management_app/screens/edit_project_screen.dart';
import 'package:business_management_app/screens/project_details_screen.dart';
import 'package:business_management_app/screens/report_issue_screen.dart';
import 'package:business_management_app/screens/send_notification_screen.dart';
import 'package:business_management_app/widgets/project_card.dart';

class CEODashboard extends StatefulWidget {
  @override
  _CEODashboardState createState() => _CEODashboardState();
}

class _CEODashboardState extends State<CEODashboard> {
  final CompanyService _companyService = CompanyService();
  final ProjectService _projectService = ProjectService();
  final UserService _userService = UserService();
  List<Project> _projects = [];
  Company? _selectedCompany;
  AppUser.User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserAndCompany();
  }

  Future<void> _loadUserAndCompany() async {
    AppUser.User? user = await _userService.getCurrentUser();
    setState(() {
      _user = user;
    });

    if (user != null && user.companyId.isNotEmpty) {
      Company company = await _companyService.getCompanyById(user.companyId);
      setState(() {
        _selectedCompany = company;
      });

      _loadProjects(company.id);
    }
  }

  Future<void> _loadProjects(String companyId) async {
    List<Project> projects = await _projectService.getProjectsForCompany(companyId);
    setState(() {
      _projects = projects;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('CEO Dashboard', style: GoogleFonts.rubik()),
        backgroundColor: Color(0xFFD97757),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle logout
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_user != null) _buildProfileHeader(),
            _buildActionButtons(),
            if (_selectedCompany != null) _buildProjectsSection(),
          ],
        ),
      ),
      floatingActionButton: _selectedCompany != null
          ? FloatingActionButton(
              onPressed: () {
                if (_selectedCompany != null) {
                  Navigator.pushNamed(
                    context,
                    '/add_project',
                    arguments: _selectedCompany!.id,
                  ).then((value) => _loadProjects(_selectedCompany!.id));
                }
              },
              backgroundColor: Color(0xFFD97757),
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(_user?.profileImage ?? 'https://via.placeholder.com/150'),
            radius: 30,
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _user?.name ?? 'Unknown',
                style: GoogleFonts.rubik(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'the CEO of ${_selectedCompany?.name ?? 'no company selected'}',
                style: GoogleFonts.rubik(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildActionButton('Add a project', () {
            if (_selectedCompany != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProjectScreen(companyId: _selectedCompany!.id)),
              ).then((value) => _loadProjects(_selectedCompany!.id));
            }
          }, Icons.add),
          _buildActionButton('Report an issue', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReportIssueScreen()),
            );
          }, Icons.report),
          _buildActionButton('Send a notification', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SendNotificationScreen()),
            );
          }, Icons.notification_add),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, VoidCallback onPressed, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFD97757),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          textStyle: GoogleFonts.rubik(fontSize: 18),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(title, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Projects',
            style: GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        _buildProjectsList(),
      ],
    );
  }

  Widget _buildProjectsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _projects.length,
      itemBuilder: (context, index) {
        return ProjectCard(
          project: _projects[index],
          onView: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectDetailsScreen(project: _projects[index]),
              ),
            );
          },
          onUpdate: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProjectScreen(project: _projects[index]),
              ),
            ).then((value) => _loadProjects(_selectedCompany!.id));
          },
        );
      },
    );
  }
}
