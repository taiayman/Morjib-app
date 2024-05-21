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
import 'package:business_management_app/screens/ceo_profile_screen.dart';
import 'package:business_management_app/models/user.dart' as AppUser;
import 'package:business_management_app/services/notification_service.dart';
import 'package:business_management_app/models/notification.dart' as CustomNotification;

class BossDashboard extends StatefulWidget {
  final bool isDarkTheme;

  BossDashboard({required this.isDarkTheme});

  @override
  _BossDashboardState createState() => _BossDashboardState();
}

class _BossDashboardState extends State<BossDashboard> {
  final CompanyService _companyService = CompanyService();
  final ProjectService _projectService = ProjectService();
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();
  List<Company> _companies = [];
  List<Project> _projects = [];
  List<AppUser.User> _ceos = [];
  bool _hasUnreadNotifications = false;
  int _selectedIndex = 0;
  late bool _isDarkTheme;

  @override
  void initState() {
    super.initState();
    _isDarkTheme = widget.isDarkTheme;
    _loadCompanies();
    _loadProjects();
    _loadCEOs();
    _checkForUnreadNotifications();
  }

  Future<void> _loadCompanies() async {
    List<Company> companies = await _companyService.getAllCompanies();
    setState(() {
      _companies = companies;
    });
  }

  Future<void> _loadProjects() async {
    List<Project> projects = await _projectService.getAllProjects();
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

  Future<void> _checkForUnreadNotifications() async {
    List<CustomNotification.Notification> notifications = await _notificationService.getAllNotifications();
    bool hasUnread = notifications.any((notification) => !notification.isRead);
    setState(() {
      _hasUnreadNotifications = hasUnread;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleNotificationsRead() {
    setState(() {
      _hasUnreadNotifications = false;
    });
  }

  List<Widget> _widgetOptions() {
    return <Widget>[
      Scaffold(
        appBar: AppBar(
          title: Text(
            'Boss Dashboard',
            style: GoogleFonts.nunito(color: Colors.white)),
          backgroundColor: Color(0xFFD97757),
          automaticallyImplyLeading: false,
        ),
        body: BossDashboardContent(
          companies: _companies,
          projects: _projects,
          ceos: _ceos,
          isDarkTheme: _isDarkTheme,
        ),
        backgroundColor: _isDarkTheme ? Color(0xFF2C2B28) : Color(0xFFF2F0E8),
      ),
      AIChatScreen(isDarkTheme: _isDarkTheme),
      NotificationsScreen(onNotificationsRead: _handleNotificationsRead, isDarkTheme: _isDarkTheme),
      SettingsScreen(
        onThemeChanged: () => setState(() => _isDarkTheme = !_isDarkTheme),
        isDarkTheme: _isDarkTheme,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkTheme ? Color(0xFF2C2B28) : Color(0xFFF2F0E8),
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.notifications),
                if (_hasUnreadNotifications)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFD97757),
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
  final bool isDarkTheme;

  BossDashboardContent({
    required this.companies,
    required this.projects,
    required this.ceos,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkTheme ? Color(0xFF2C2B28) : Color(0xFFF2F0E8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'My Companies',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
            SizedBox(height: 0),
            CarouselSlider(
              options: CarouselOptions(
                height: 240.0,
                viewportFraction: 0.8,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                scrollDirection: Axis.horizontal,
                autoPlay: false,
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
                  child: CompanyCard(company: company, isDarkTheme: isDarkTheme),
                );
              }).toList(),
            ),
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Latest Projects',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
            SizedBox(height: 0),
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
                            ProjectDetailsScreen(project: project, isDarkTheme: isDarkTheme),
                      ),
                    );
                  },
                  child: LatestProjectCard(project: project, isDarkTheme: isDarkTheme),
                );
              }).toList(),
            ),
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'CEOs',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
            SizedBox(height: 0),
            Container(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ceos.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CEOProfileScreen(ceo: ceos[index], isDarkTheme: isDarkTheme),
                            ),
                          );
                        },
                        child: CEOCard(user: ceos[index], isDarkTheme: isDarkTheme),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
