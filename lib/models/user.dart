// user.dart
class User {
  String id;
  String name;
  String email;
  String role;
  String companyId;
  String whatsapp;
  String description;
  String profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.companyId,
    required this.whatsapp,
    required this.description,
    required this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'companyId': companyId,
      'whatsapp': whatsapp,
      'description': description,
      'profileImage': profileImage,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      companyId: map['companyId'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      description: map['description'] ?? '',
      profileImage: map['profileImage'] ?? '',
    );
  }
}
