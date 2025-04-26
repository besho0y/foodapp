// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:foodapp/models/item.dart';

class HomeData {
  List<Restuarants> restuarants = [];

  HomeData({required this.restuarants});

  HomeData.fromJson(Map<String, dynamic> json) {
    json["restaurants"].foreach((element) => restuarants.add(element));
  }
}

class Restuarants {
  String name;
  List<Item> menuItems = [];
  String img;
  double rating;
  String category;
  Restuarants({
    required this.name,
    required this.menuItems,
    required this.img,
    required this.rating,
    required this.category,
  });

  Restuarants.fromJson(Map<String, dynamic> json)
    : name = json['name'] ?? '',
      menuItems =
          (json['menuItems'] as List<dynamic>?)
              ?.map((element) => Item.fromJson(element))
              .toList() ??
          [],
      img = json['img'] ?? 'assets/images/restuarants/store.jpg',
      rating = (json['rating'] as num?)?.toDouble() ?? 0.0,
      category = json["category"] ?? "fast food";
}
