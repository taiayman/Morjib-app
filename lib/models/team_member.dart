// lib/models/team_member.dart

class TeamMember {
  final String id;
  final String name;
  final String profileUrl;

  TeamMember({required this.id, required this.name, required this.profileUrl});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profileUrl': profileUrl,
    };
  }

  factory TeamMember.fromMap(Map<String, dynamic> map) {
    return TeamMember(
      id: map['id'],
      name: map['name'],
      profileUrl: map['profileUrl'],
    );
  }
}
