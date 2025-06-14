class Area {
  final String id;
  final String name;
  final String nameAr;
  final String cityId;
  final DateTime createdAt;

  Area({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.cityId,
    required this.createdAt,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      cityId: json['cityId'] ?? '',
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
      'cityId': cityId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
