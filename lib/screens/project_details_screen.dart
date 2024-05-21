import 'package:flutter/material.dart';
import 'package:business_management_app/models/project.dart';
import 'package:business_management_app/models/team_member.dart';
import 'package:business_management_app/services/project_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  final bool isDarkTheme;

  ProjectDetailsScreen({required this.project, required this.isDarkTheme});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final ProjectService _projectService = ProjectService();
  List<TeamMember> _teamMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchTeamMembers();
  }

  Future<void> _fetchTeamMembers() async {
    if (widget.project.teamMemberIds.isNotEmpty) {
      List<TeamMember> teamMembers = await _projectService.getTeamMembers(widget.project.teamMemberIds);
      setState(() {
        _teamMembers = teamMembers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkTheme ? Color(0xFF2C2B28) : Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text(widget.project.name, style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Description'),
              SizedBox(height: 8),
              Text(widget.project.details, style: GoogleFonts.nunito(fontSize: 16, color: widget.isDarkTheme ? Colors.white : Colors.black)),
              SizedBox(height: 16),
              _buildSectionTitle('Goals'),
              SizedBox(height: 8),
              Text(widget.project.goals, style: GoogleFonts.nunito(fontSize: 16, color: widget.isDarkTheme ? Colors.white : Colors.black)),
              SizedBox(height: 16),
              _buildSectionTitle('Start and End Date'),
              SizedBox(height: 8),
              Text(
                '${DateFormat('yyyy/MM/dd').format(widget.project.start.toLocal())} to ${DateFormat('yyyy/MM/dd').format(widget.project.end.toLocal())}',
                style: GoogleFonts.nunito(fontSize: 16, color: widget.isDarkTheme ? Colors.white : Colors.black),
              ),
              SizedBox(height: 16),
              _buildSectionTitle('Budget'),
              SizedBox(height: 8),
              Text('\$${widget.project.budget}', style: GoogleFonts.nunito(fontSize: 16, color: widget.isDarkTheme ? Colors.white : Colors.black)),
              SizedBox(height: 16),
              _buildSectionTitle('Team Members'),
              SizedBox(height: 8),
              _buildTeamMembersWrap(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold, color: widget.isDarkTheme ? Colors.white : Colors.black),
    );
  }

  Widget _buildTeamMembersWrap() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: widget.project.teamMemberNames.map((name) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: widget.isDarkTheme ? Color(0xFF444444) : Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(color: widget.isDarkTheme ? Colors.grey[700]! : Colors.grey[300]!, width: 1),
          ),
          child: Text(
            name,
            style: GoogleFonts.nunito(fontSize: 16, color: widget.isDarkTheme ? Colors.white : Colors.black),
          ),
        );
      }).toList(),
    );
  }
}
