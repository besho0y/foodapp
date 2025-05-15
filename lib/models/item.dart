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

    if (!this.categories.contains("All")) {
      this.categories.add("All");
    }

    if (!this.categories.contains(category) && category != "All") {
      this.categories.add(category);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'namear': nameAr,
      'description': description,
      'descriptionar': descriptionAr,
      'price': price,
      "img": img,
      "category": category,
      "categoryar": categoryAr,
      "categories": categories,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    final mainCategory = json["category"] ?? 'Uncategorized';

    List<String> categoriesList = [];
    if (json["categories"] != null) {
      if (json["categories"] is List) {
        categoriesList = List<String>.from(json["categories"]);
      } else if (json["categories"] is String) {
        categoriesList = [json["categories"].toString()];
      }
    }

    if (!categoriesList.contains("All")) {
      categoriesList.add("All");
    }

    if (!categoriesList.contains(mainCategory) && mainCategory != "All") {
      categoriesList.add(mainCategory);
    }

    print("Loading item: ${json['name']}, Categories: $categoriesList");

    return Item(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed Item',
      nameAr: json['namear'] ?? json['nameAr'] ?? '',
      description: json['description'] ?? 'No description',
      descriptionAr: json['descriptionar'] ?? json['descriptionAr'] ?? '',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : (double.tryParse(json['price']?.toString() ?? '0') ?? 0.0),
      img: json["img"] ?? 'assets/images/items/default.jpg',
      category: mainCategory,
      categoryAr: json['categoryar'] ?? json['categoryAr'] ?? 'غير مصنف',
      categories: categoriesList,
    );
  }

  @override
  String toString() {
    return 'Item: $name, ID: $id, Price: $price, Categories: $categories';
  }
}
