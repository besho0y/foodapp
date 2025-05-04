class Order {
  String id;
  String date;
  double total;
  List<Map<String, dynamic>> items;
  String status;
  Map<String, dynamic>? address;
  String? paymentMethod;
  String? userId;
  String? userName;

  Order({
    required this.id,
    required this.date,
    required this.total,
    required this.items,
    required this.status,
    this.address,
    this.paymentMethod,
    this.userId,
    this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'total': total,
      'items': items,
      'status': status,
      'address': address,
      'paymentMethod': paymentMethod,
      'userId': userId,
      'userName': userName,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? json['orderId'] ?? '',
      date: json['date'] ?? json['orderDate'] ?? '',
      total: (json['total'] ?? json['totalAmount'] ?? 0.0).toDouble(),
      items: json['items'] != null
          ? List<Map<String, dynamic>>.from(json['items'])
          : [],
      status: json['status'] ?? 'pending',
      address: json['address'],
      paymentMethod: json['paymentMethod'],
      userId: json['userId'],
      userName: json['userName'],
    );
  }

  // Calculate the total price from items
  double calculateTotal() {
    double total = 0.0;
    for (var item in items) {
      double price = 0.0;
      int quantity = 1;
      
      if (item['price'] is int) {
        price = (item['price'] as int).toDouble();
      } else if (item['price'] is double) {
        price = item['price'];
      }
      
      if (item['quantity'] is int) {
        quantity = item['quantity'];
      }
      
      total += price * quantity;
    }
    return total;
  }
}
