class Banner {
  final String id;
  final String imageUrl;
  final DateTime createdAt;
  final bool isActive;

  Banner({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
    this.isActive = true,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  @override
  String toString() =>
      'Banner(id: $id, imageUrl: $imageUrl, isActive: $isActive)';
}
