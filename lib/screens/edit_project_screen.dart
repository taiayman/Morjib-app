import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:business_management_app/models/project.dart';
import 'package:business_management_app/services/project_service.dart';

class EditProjectScreen extends StatefulWidget {
  final Project project;

  EditProjectScreen({required this.project});

  @override
  _EditProjectScreenState createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  final _detailsController = TextEditingController();
  final _goalsController = TextEditingController(); // Add a controller for goals
  final _teamMembersController = TextEditingController(); // Add a controller for team members
  final ProjectService _projectService = ProjectService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.project.name;
    _budgetController.text = widget.project.budget.toString();
    _detailsController.text = widget.project.details;
    _goalsController.text = widget.project.goals; // Initialize goals
    _teamMembersController.text = widget.project.teamMemberNames.join(', '); // Initialize team members
  }

  void _editProject() async {
    final name = _nameController.text;
    final budget = double.tryParse(_budgetController.text) ?? 0;
    final details = _detailsController.text;
    final goals = _goalsController.text; // Get goals
    final teamMembers = _teamMembersController.text.split(', '); // Split team members by comma and space

    Project updatedProject = Project(
      id: widget.project.id,
      name: name,
      start: widget.project.start,
      end: widget.project.end,
      budget: budget,
      details: details,
      goals: goals, // Set goals
      teamMemberNames: teamMembers, // Set team members
      status: widget.project.status,
      leaderId: widget.project.leaderId,
      companyId: widget.project.companyId,
      companyName: widget.project.companyName, // Provide the company name here
      teamMemberIds: widget.project.teamMemberIds,
    );

    await _projectService.updateProject(updatedProject);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('Edit Project', style: GoogleFonts.nunito()),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextFormField(_nameController, 'Project Name'),
            _buildTextFormField(_budgetController, 'Budget', keyboardType: TextInputType.number),
            _buildTextFormField(_detailsController, 'Details'),
            _buildTextFormField(_goalsController, 'Goals'), // Add goals field
            _buildTextFormField(_teamMembersController, 'Team Members (comma separated)'), // Add team members field
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD97757),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                textStyle: GoogleFonts.nunito(fontSize: 18),
              ),
              child: Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String labelText, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.nunito(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: GoogleFonts.nunito(),
      ),
    );
  }
}
