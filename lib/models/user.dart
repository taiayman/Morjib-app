class User {
  final String id;
  final String email;
  final String name;
  final String phone;
  final int points;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.points = 0,
  });

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      points: data['points'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'points': points,
    };
  }
}