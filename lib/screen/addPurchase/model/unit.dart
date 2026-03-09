class Unit {
  final int id;
  final String name;
  final String description;

  Unit({
    required this.id,
    required this.name,
    this.description = '',
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
    );
  }
}
