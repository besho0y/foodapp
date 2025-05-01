class Item {
  String id;
  String name;
  String description;
  double price;
  String img;
  bool isfavourite = false;
  String category;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.img,
    required this.category
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      "img": img,
      "category":category
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      img: json["img"],
      category: json["category"],
    );
  }
}
