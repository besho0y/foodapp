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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Address && other.title == title && other.address == address;
  }

  @override
  int get hashCode => title.hashCode ^ address.hashCode;
}

class CartItem {
  String id;
  String name;
  String nameAr;
  double price;
  int quantity;
  String img;
  String? comment;
  String restaurantId;
  String restaurantName;
  String restaurantNameAr;
  String deliveryFee;

  CartItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.price,
    required this.quantity,
    required this.img,
    this.comment,
    required String restaurantId,
    required this.restaurantName,
    required this.restaurantNameAr,
    required this.deliveryFee,
  }) : restaurantId = restaurantId.trim() {
    print("\n=== Creating CartItem ===");
    print("Restaurant: $restaurantName (ID: \"$restaurantId\")");
    print("Original Delivery Fee: $deliveryFee");

    // Ensure restaurant ID is not empty
    if (restaurantId.isEmpty) {
      print("WARNING: Empty restaurant ID detected, generating unique ID");
      this.restaurantId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // Force a non-empty delivery fee value
    if (deliveryFee.isEmpty || deliveryFee == '0' || deliveryFee == '0.0') {
      // Set a default delivery fee (you might want to adjust this value)
      deliveryFee = '30.0';
      print(
          "Empty or zero delivery fee detected, setting to default: $deliveryFee");
    }

    // Clean the delivery fee string - remove any non-numeric characters except decimal point
    String cleanFee = deliveryFee.replaceAll(RegExp(r'[^0-9.]'), '');
    print("Cleaned Delivery Fee: $cleanFee");

    if (cleanFee.isNotEmpty) {
      try {
        double fee = double.parse(cleanFee);
        print("Parsed Fee: $fee");

        // Ensure the fee is positive
        if (fee <= 0) {
          fee = 30.0; // Default value if parsing results in 0 or negative
          print("Fee was 0 or negative, using default: $fee");
        }

        // Store the clean value
        deliveryFee = fee.toString();
        print("Final Stored Delivery Fee: $deliveryFee");
      } catch (e) {
        print("Error parsing delivery fee: $e");
        deliveryFee = '30.0'; // Default value on parsing error
        print("Using default delivery fee after error: $deliveryFee");
      }
    } else {
      print("No valid numbers in delivery fee, using default");
      deliveryFee = '30.0'; // Default value if no valid numbers
    }

    print(
        "=== CartItem Created with RestaurantID: \"${this.restaurantId}\" and Delivery Fee: $deliveryFee ===\n");
  }

  double getDeliveryFeeAsDouble() {
    print("\n=== Getting Delivery Fee as Double ===");
    print("Original Delivery Fee: $deliveryFee");

    try {
      String cleanFee = deliveryFee.replaceAll(RegExp(r'[^0-9.]'), '');
      print("Cleaned Fee: $cleanFee");

      if (cleanFee.isEmpty) {
        print("No valid numbers in fee, returning 0");
        return 0.0;
      }

      double fee = double.parse(cleanFee);
      print("Parsed Fee: $fee");

      if (fee <= 0) {
        print("Fee is 0 or negative, returning 0");
        return 0.0;
      }

      print("=== Returning Fee: $fee ===\n");
      return fee;
    } catch (e) {
      print("Error parsing delivery fee: $e");
      return 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    print("\n=== Converting CartItem to JSON ===");
    var json = {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'price': price,
      'quantity': quantity,
      'img': img,
      'comment': comment,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'restaurantNameAr': restaurantNameAr,
      'deliveryFee': deliveryFee,
    };
    print("JSON Delivery Fee: ${json['deliveryFee']}");
    print("=== JSON Conversion Complete ===\n");
    return json;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    print("\n=== Creating CartItem from JSON ===");
    print("JSON Data:");
    print("- name: ${json['name']}");
    print("- restaurantId: ${json['restaurantId']}");
    print("- deliveryFee: ${json['deliveryFee']}");

    // Ensure restaurantId is not empty or null
    String restaurantId = json['restaurantId']?.toString() ?? '';
    if (restaurantId.isEmpty) {
      restaurantId = DateTime.now().millisecondsSinceEpoch.toString();
      print(
          "WARNING: Empty restaurant ID in JSON, generating unique ID: $restaurantId");
    } else {
      restaurantId = restaurantId.trim();
      print("Using restaurant ID from JSON: $restaurantId");
    }

    // Ensure delivery fee is not null or empty
    String fee = json['deliveryFee']?.toString() ?? '30.0';
    print("Initial Fee: $fee");

    // Force a non-empty value
    if (fee.isEmpty || fee == '0' || fee == '0.0') {
      fee = '30.0'; // Default value
      print("Empty or zero fee detected, using default: $fee");
    }

    // Clean the delivery fee string
    String cleanFee = fee.replaceAll(RegExp(r'[^0-9.]'), '');
    print("Cleaned Fee: $cleanFee");

    if (cleanFee.isNotEmpty) {
      try {
        double parsedFee = double.parse(cleanFee);
        print("Parsed Fee: $parsedFee");

        // Ensure the fee is positive
        if (parsedFee <= 0) {
          parsedFee = 30.0; // Default value
          print("Fee was 0 or negative, using default: $parsedFee");
        }

        fee = parsedFee.toString();
        print("Final Fee: $fee");
      } catch (e) {
        print("Error parsing fee: $e");
        fee = '30.0'; // Default value on parsing error
        print("Using default fee after error: $fee");
      }
    } else {
      print("No valid numbers in fee, using default");
      fee = '30.0'; // Default value if no valid numbers
    }

    print("=== CartItem Creation from JSON Complete with Fee: $fee ===\n");

    return CartItem(
      id: json['id'] ?? DateTime.now().toString(),
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
      img: json['img'] ?? '',
      comment: json['comment'],
      restaurantId: restaurantId,
      restaurantName: json['restaurantName'] ?? '',
      restaurantNameAr: json['restaurantNameAr'] ?? '',
      deliveryFee: fee,
    );
  }
}
