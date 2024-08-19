class Stall {
  final String id;
  final String name;
  final String description;

  Stall({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Stall.fromJson(Map<String, dynamic> json) {
    return Stall(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  @override
  String toString() => 'Stall(id: $id, name: $name, description: $description)';
}