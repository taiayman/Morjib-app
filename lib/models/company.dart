class Company {
  final String id;
  final String name;
  final String ceoId;
  final String ceoName;
  final String ceoEmail;
  final String ceoPhone;
  final String ceoWhatsApp;
  final int employeeCount;
  final List<String> projects;
  final String statusColor;

  Company({
    required this.id,
    required this.name,
    required this.ceoId,
    required this.ceoName,
    required this.ceoEmail,
    required this.ceoPhone,
    required this.ceoWhatsApp,
    required this.employeeCount,
    required this.projects,
    required this.statusColor,
  });

  factory Company.fromMap(Map<String, dynamic> data) {
    return Company(
      id: data['id'],
      name: data['name'],
      ceoId: data['ceoId'],
      ceoName: data['ceoName'],
      ceoEmail: data['ceoEmail'],
      ceoPhone: data['ceoPhone'],
      ceoWhatsApp: data['ceoWhatsApp'],
      employeeCount: data['employeeCount'],
      projects: List<String>.from(data['projects']),
      statusColor: data['statusColor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ceoId': ceoId,
      'ceoName': ceoName,
      'ceoEmail': ceoEmail,
      'ceoPhone': ceoPhone,
      'ceoWhatsApp': ceoWhatsApp,
      'employeeCount': employeeCount,
      'projects': projects,
      'statusColor': statusColor,
    };
  }
}
