class Project {
  final String id;
  final String name;
  final DateTime start;
  final DateTime end;
  final double budget;
  final String details;
  final String status;
  final String leaderId;

  Project({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    required this.budget,
    required this.details,
    required this.status,
    required this.leaderId,
  });

  factory Project.fromMap(Map<String, dynamic> data) {
    return Project(
      id: data['id'],
      name: data['name'],
      start: DateTime.parse(data['start']),
      end: DateTime.parse(data['end']),
      budget: data['budget'],
      details: data['details'],
      status: data['status'],
      leaderId: data['leaderId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'budget': budget,
      'details': details,
      'status': status,
      'leaderId': leaderId,
    };
  }
}
