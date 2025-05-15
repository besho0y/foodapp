class Promocode {
  String code;
  double discount;
  int usageCount; // Track how many times the code has been used

  Promocode({
    required this.code,
    required this.discount,
    this.usageCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discount': discount,
      'usageCount': usageCount,
    };
  }

  factory Promocode.fromJson(Map<String, dynamic> json) {
    return Promocode(
      code: json['code'] ?? '',
      discount: (json['discount'] ?? 0.0).toDouble(),
      usageCount: json['usageCount'] ?? 0,
    );
  }
}
