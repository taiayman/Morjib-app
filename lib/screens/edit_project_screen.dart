import 'package:flutter/material.dart';
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
  final ProjectService _projectService = ProjectService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.project.name;
    _budgetController.text = widget.project.budget.toString();
    _detailsController.text = widget.project.details;
  }

  void _editProject() async {
    final name = _nameController.text;
    final budget = double.tryParse(_budgetController.text) ?? 0;
    final details = _detailsController.text;

    Project updatedProject = Project(
      id: widget.project.id,
      name: name,
      start: widget.project.start,
      end: widget.project.end,
      budget: budget,
      details: details,
      status: widget.project.status,
      leaderId: widget.project.leaderId,
    );

    await _projectService.updateProject(updatedProject);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Project Name'),
            ),
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(labelText: 'Budget'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _detailsController,
              decoration: InputDecoration(labelText: 'Details'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editProject,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
