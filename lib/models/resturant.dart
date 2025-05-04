// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:foodapp/models/item.dart';

class Restuarants {
  String name;
  List<Item> menuItems = [];
  String img;
  double rating;
  String category;
  String deliveryTime;
  String deliveryFee;
  int ordersnum;
  String id;
  List<String> categories;
  List<String>? menuCategories; // Menu categories for items

  Restuarants(
      {required this.name,
      required this.menuItems,
      required this.img,
      required this.rating,
      required this.category,
      required this.deliveryFee,
      required this.ordersnum,
      required this.deliveryTime,
      required this.id,
      required this.categories,
      this.menuCategories});

  Restuarants.fromJson(Map<String, dynamic> json)
      : name = json['resname'] ?? '',
        menuItems = (json['items'] as List<dynamic>?)
                ?.map(
                    (element) => Item.fromJson(element as Map<String, dynamic>))
                .toList() ??
            [],
        id = json['id'] ?? '',
        img = json['img'] ?? 'assets/images/restuarants/store.jpg',
        rating =
            json['rating'] is num ? (json['rating'] as num).toDouble() : 0.0,
        deliveryFee = json['delivery fee']?.toString() ?? '50',
        deliveryTime = json['delivery time']?.toString() ?? '1 day',
        ordersnum = json['ordersnumber'] is num
            ? (json['ordersnumber'] as num).toInt()
            : 0,
        categories = json['categories'] is List
            ? List<String>.from(json['categories'])
            : [],
        menuCategories = json['menuCategories'] is List
            ? List<String>.from(json['menuCategories'])
            : null,
        category = json["category"]?.toString() ?? "fast food";

  Map<String, dynamic> toJson() {
    return {
      'resname': name,
      'id': id,
      'img': img,
      'rating': rating,
      'category': category,
      'delivery fee': deliveryFee,
      'delivery time': deliveryTime,
      'ordersnumber': ordersnum,
      'categories': categories,
      'menuCategories': menuCategories,
      'items': menuItems.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Restaurant: $name, ID: $id, Category: $category, Items: ${menuItems.length}';
  }
}
