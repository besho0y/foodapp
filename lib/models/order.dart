import 'package:foodapp/models/item.dart';

class Order {
  String orderId;
  String customerName;
  String orderDate;
  double totalAmount;
  String address;
  String restaurantName;
  List<Item> items;
  bool status = false;
  Order({
    required this.orderId,
    required this.customerName,
    required this.orderDate,
    required this.totalAmount,
    required this.address,
    required this.restaurantName,
    required this.items,
    this.status = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'customerName': customerName,
      'orderDate': orderDate,
      'totalAmount': totalAmount,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      customerName: json['customerName'],
      orderDate: json['orderDate'],
      totalAmount: json['totalAmount'],
      address: json["useradderess"],
      restaurantName: json["resturantname"],
      status:json["status"],
      items:
          json["orderitems"] != null
              ? List<Item>.from(
                json["orderitems"].map((item) => Item.fromJson(item)),
              )
              : [],
    );
  }
}
