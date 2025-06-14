class City {
  final String id;
  final String name;
  final String nameAr;
  final DateTime createdAt;

  City({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.createdAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
