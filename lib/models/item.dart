class Item {
  String id;
  String name;
  String description;
  double price;
  String img;
  bool isfavourite = false;
  String category;
  List<String> categories = [];

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.img,
    required this.category,
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
      'description': description,
      'price': price,
      "img": img,
      "category": category,
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
      description: json['description'] ?? 'No description',
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : (double.tryParse(json['price']?.toString() ?? '0') ?? 0.0),
      img: json["img"] ?? 'assets/images/items/default.jpg',
      category: mainCategory,
      categories: categoriesList,
    );
  }

  @override
  String toString() {
    return 'Item: $name, ID: $id, Price: $price, Categories: $categories';
  }
}
