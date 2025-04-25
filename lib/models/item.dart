class Item {
  String id;
  String name;
  String description;
  double price;
  String img;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.img,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'price': price ,"img":img};
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      img:json["img"],
    );
  }
}
