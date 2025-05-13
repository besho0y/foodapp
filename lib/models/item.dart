class Item {
  String id;
  String name;
  String nameAr;
  String description;
  String descriptionAr;
  double price;
  String img;
  bool isfavourite = false;
  String category;
  String categoryAr;
  List<String> categories = [];

  Item({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    required this.img,
    required this.category,
    required this.categoryAr,
    List<String>? categories,
  }) {
    this.categories = categories ?? [];
    if (!this.categories.contains(category) && category != "All") {
      this.categories.add(category);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'price': price,
      "img": img,
      "category": category,
      "categoryAr": categoryAr,
      "categories": categories,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    final mainCategory = json["category"] ?? 'Uncategorized';

    List<String> categoriesList = [];
    if (json["categories"] != null) {
      categoriesList = List<String>.from(json["categories"]);
    }

    if (!categoriesList.contains(mainCategory) && mainCategory != "All") {
      categoriesList.add(mainCategory);
    }

    return Item(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed Item',
      nameAr: json['nameAr'] ?? json['namear'] ?? 'عنصر بدون اسم',
      description: json['description'] ?? 'No description',
      descriptionAr:
          json['descriptionAr'] ?? json['descriptionar'] ?? 'لا يوجد وصف',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : (double.tryParse(json['price']?.toString() ?? '0') ?? 0.0),
      img: json["img"] ?? 'assets/images/items/default.jpg',
      category: mainCategory,
      categoryAr: json['categoryAr'] ?? json['categoryar'] ?? 'غير مصنف',
      categories: categoriesList,
    );
  }

  @override
  String toString() {
    return 'Item: $name, ID: $id, Price: $price, Categories: $categories';
  }
}
