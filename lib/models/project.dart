import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String name;
  final DateTime start;
  final DateTime end;
  final double budget;
  final String details;
  final String goals;
  final List<String> teamMemberNames;
  final String status;
  final String companyName; // Ensure this field is present
  final String leaderId;
  final String companyId;
  final List<String> teamMemberIds;

  Project({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    required this.budget,
    required this.details,
    required this.goals,
    required this.teamMemberNames,
    required this.status,
    required this.companyName, // Initialize this field
    required this.leaderId,
    required this.companyId,
    required this.teamMemberIds,
  });

  factory Project.fromMap(Map<String, dynamic> data) {
    return Project(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      start: _convertToDateTime(data['start']),
      end: _convertToDateTime(data['end']),
      budget: data['budget']?.toDouble() ?? 0.0,
      details: data['details'] ?? '',
      goals: data['goals'] ?? '',
      teamMemberNames: data['teamMemberNames'] != null ? List<String>.from(data['teamMemberNames']) : [],
      status: data['status'] ?? '',
      companyName: data['companyName'] ?? '', // Fetch this field
      leaderId: data['leaderId'] ?? '',
      companyId: data['companyId'] ?? '',
      teamMemberIds: data['teamMemberIds'] != null ? List<String>.from(data['teamMemberIds']) : [],
    );
  }

  static DateTime _convertToDateTime(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else {
      throw Exception("Invalid date format");
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'budget': budget,
      'details': details,
      'goals': goals,
      'teamMemberNames': teamMemberNames,
      'status': status,
      'companyName': companyName, // Include this field
      'leaderId': leaderId,
      'companyId': companyId,
      'teamMemberIds': teamMemberIds,
    };
  }
}
