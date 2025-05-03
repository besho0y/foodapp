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
      required this.categories
      });

  Restuarants.fromJson(Map<String, dynamic> json)
      : name = json['resname'] ?? '',
        menuItems = (json['items'] as List<dynamic>?)
                ?.map((element) => Item.fromJson(element))
                .toList() ??
            [],
        id = json['id'],
        img = json['img'] ?? 'assets/images/restuarants/store.jpg',
        rating = (json['rating'] as num?)?.toDouble() ?? 0.0,
        deliveryFee = json['delivery fee'] ?? '50',
        deliveryTime = json['delivery time'] ?? '1 day',
        ordersnum = json['ordersnumber'],
        categories=List<String>.from(json['categories'] ?? []),
        category = json["category"] ?? "fast food";
} 
