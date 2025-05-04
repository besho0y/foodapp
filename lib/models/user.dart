class User {
  String name;
  String email;
  String phone;
  String uid;
  List<Address> addresses;
  List<CartItem> cart;
  List<String> orderIds;
  List<String> favourites;

  User({
    required this.name,
    required this.phone,
    required this.email,
    required this.uid,
    this.addresses = const [],
    this.cart = const [],
    this.orderIds = const [],
    this.favourites = const [],
  });

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        uid = json['uid'],
        phone = json['phone'],
        addresses = json['addresses'] != null
            ? List<Address>.from(
                (json['addresses'] as List).map((x) => Address.fromJson(x)))
            : [],
        orderIds =
            json['orderIds'] != null ? List<String>.from(json['orderIds']) : [],
        favourites = json['favourites'] != null
            ? List<String>.from(json['favourites'])
            : [],
        cart = []; // Cart is only stored locally, not in Firestore

  Map<String, dynamic> tomap() => {
        'name': name,
        'uid': uid,
        'email': email,
        'phone': phone,
        'addresses': addresses.map((address) => address.toJson()).toList(),
        'orderIds': orderIds,
        'favourites': favourites,
        // Note: Cart is not included as it's only stored locally
      };
}

class Address {
  String title;
  String address;
  bool isDefault;

  Address({
    required this.title,
    required this.address,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'address': address,
        'isDefault': isDefault,
      };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        title: json['title'],
        address: json['address'],
        isDefault: json['isDefault'],
      );
}

class CartItem {
  String id;
  String name;
  double price;
  int quantity;
  String img;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.img,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'img': img,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        name: json['name'],
        price: json['price'].toDouble(),
        quantity: json['quantity'],
        img: json['img'],
      );
}
