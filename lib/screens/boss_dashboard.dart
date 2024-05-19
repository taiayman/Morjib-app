import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_management_app/models/company.dart';
import 'package:business_management_app/models/project.dart';
import 'package:business_management_app/services/company_service.dart';
import 'package:business_management_app/services/project_service.dart';
import 'package:business_management_app/services/user_service.dart';
import 'package:business_management_app/widgets/company_card.dart';
import 'package:business_management_app/widgets/latest_project_card.dart';
import 'package:business_management_app/widgets/ceo_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:business_management_app/screens/project_details_screen.dart';
import 'package:business_management_app/screens/ai_chat_screen.dart';
import 'package:business_management_app/screens/settings_screen.dart';
import 'package:business_management_app/screens/notifications_screen.dart';
import 'package:business_management_app/models/user.dart' as AppUser;

class BossDashboard extends StatefulWidget {
  @override
  _BossDashboardState createState() => _BossDashboardState();
}

class _BossDashboardState extends State<BossDashboard> {
  final CompanyService _companyService = CompanyService();
  final ProjectService _projectService = ProjectService();
  final UserService _userService = UserService();
  List<Company> _companies = [];
  List<Project> _projects = [];
  List<AppUser.User> _ceos = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    _loadProjects();
    _loadCEOs();
  }

  Future<void> _loadCompanies() async {
    List<Company> companies = await _companyService.getAllCompanies();
    setState(() {
      _companies = companies;
    });
  }

  Future<void> _loadProjects() async {
    List<Project> projects = await _projectService.getLatestProjects();
    setState(() {
      _projects = projects;
    });
  }

  Future<void> _loadCEOs() async {
    List<AppUser.User> ceos = await _userService.getAllCEOs();
    setState(() {
      _ceos = ceos;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _widgetOptions() {
    return <Widget>[
      Scaffold(
        appBar: AppBar(
          title: Text(
            'Boss Dashboard',
            style: GoogleFonts.rubik(fontSize: 20),
          ),
          backgroundColor: Color(0xFFD97757),
          automaticallyImplyLeading: false, // Remove the back button
        ),
        body: BossDashboardContent(companies: _companies, projects: _projects, ceos: _ceos),
      ),
      AIChatScreen(),
      NotificationsScreen(),
      SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8), // Background color
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class BossDashboardContent extends StatelessWidget {
  final List<Company> companies;
  final List<Project> projects;
  final List<AppUser.User> ceos;

  BossDashboardContent({
    required this.companies,
    required this.projects,
    required this.ceos,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // My Companies section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'My Companies',
              style: GoogleFonts.rubik(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16),
          // Company carousel
          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              viewportFraction: 0.8,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              scrollDirection: Axis.horizontal,
              autoPlay: false, // Disable automatic sliding
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
            ),
            items: companies.map((company) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/company_details',
                    arguments: company.id,
                  );
                },
                child: CompanyCard(company: company),
              );
            }).toList(),
          ),
          SizedBox(height: 32),
          // Latest projects section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Latest Projects',
              style: GoogleFonts.rubik(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16),
          // Project carousel
          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              viewportFraction: 0.8,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              scrollDirection: Axis.horizontal,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
            ),
            items: projects.map((project) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProjectDetailsScreen(project: project),
                    ),
                  );
                },
                child: LatestProjectCard(project: project),
              );
            }).toList(),
          ),
          SizedBox(height: 32),
          // CEOs section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'CEOs',
              style: GoogleFonts.rubik(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 16),
          // CEO list
          Container(
            height: 150, // Adjust height as needed
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ceos.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120, // Adjust width as needed
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CEOCard(user: ceos[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}