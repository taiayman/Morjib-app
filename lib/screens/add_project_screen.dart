import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddProjectScreen extends StatefulWidget {
  final String companyId;

  AddProjectScreen({required this.companyId});

  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _budgetController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Add the project to the database
      // You should call your service to add the project here

      print('Project added successfully for companyId: ${widget.companyId}');
      // Pop the screen and return to the dashboard
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
        title: Text('Add Project', style: GoogleFonts.rubik()),
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
                _buildTextFormField(_startDateController, 'Start Date'),
                _buildTextFormField(_endDateController, 'End Date'),
                _buildTextFormField(_budgetController, 'Budget'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD97757),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    textStyle: GoogleFonts.rubik(fontSize: 18),
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

  Widget _buildTextFormField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.rubik(),
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
          return null;
        },
        style: GoogleFonts.rubik(),
      ),
    );
  }
}
