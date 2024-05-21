import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:business_management_app/models/project.dart';
import 'package:business_management_app/services/project_service.dart';
import 'package:intl/intl.dart';

class AddProjectScreen extends StatefulWidget {
  final String companyId;
  final String companyName; // Add this line

  AddProjectScreen({required this.companyId, required this.companyName}); // Update constructor

  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalsController = TextEditingController();
  final _teamMembersController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _budgetController = TextEditingController();
  final ProjectService _projectService = ProjectService();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = _dateFormat.format(pickedDate);
      });
    }
  }

 void _submit() async {
  if (_formKey.currentState!.validate()) {
    final newProject = Project(
      id: Uuid().v4(),
      name: _nameController.text,
      start: DateTime.parse(_startDateController.text),
      end: DateTime.parse(_endDateController.text),
      budget: double.parse(_budgetController.text),
      details: _descriptionController.text,
      goals: _goalsController.text,
      teamMemberNames: _teamMembersController.text.split(', '),
      status: 'ongoing',
      leaderId: 'leader-id', // Replace with actual leader ID
      companyId: widget.companyId,
      companyName: widget.companyName, // Pass this line
      teamMemberIds: [],
    );

    await _projectService.addProject(newProject);
    Navigator.pop(context);
  } else {
    print('Form validation failed');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F0E8),
      appBar: AppBar(
        title: Text('Add Project', style: GoogleFonts.nunito()),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextFormField(_nameController, 'Project Name'),
                _buildTextFormField(_descriptionController, 'Description'),
                _buildTextFormField(_goalsController, 'Goals'),
                _buildTextFormField(_teamMembersController, 'Team Members (comma separated)'),
                _buildDateFormField(_startDateController, 'Start Date', context),
                _buildDateFormField(_endDateController, 'End Date', context),
                _buildTextFormField(_budgetController, 'Budget', isNumeric: true),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD97757),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    textStyle: GoogleFonts.nunito(fontSize: 18),
                  ),
                  child: Text('Add Project', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String labelText, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.nunito(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a $labelText';
          }
          if (isNumeric) {
            try {
              double.parse(value);
            } catch (e) {
              return 'Invalid number format';
            }
          }
          return null;
        },
        style: GoogleFonts.nunito(),
      ),
    );
  }

  Widget _buildDateFormField(TextEditingController controller, String labelText, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.nunito(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onTap: () => _selectDate(context, controller),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a $labelText';
          }
          try {
            DateTime.parse(value);
          } catch (e) {
            return 'Invalid date format. Please use YYYY-MM-DD';
          }
          return null;
        },
        style: GoogleFonts.nunito(),
      ),
    );
  }
}
