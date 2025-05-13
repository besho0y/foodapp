class Category {
  final String en;
  final String ar;
  final String img;

  Category({
    required this.en,
    required this.ar,
    required this.img,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      en: json['en'] ?? '',
      ar: json['ar'] ?? '',
      img: json['img'] ?? 'assets/images/categories/all.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ar': ar,
      'img': img,
    };
  }

  @override
  String toString() => 'Category(en: $en, ar: $ar)';
}
