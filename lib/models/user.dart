class User {
  String name;
  List address;
  String email;
  int phone;

  User({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        address = json['address'],
        email = json['email'],
        phone = json['phone'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'email': email,
        'phone': phone,
      };
}

class Address {
  String title;
  String address;
  bool isDefault;
  double? latitude;
  double? longitude;

  Address({
    required this.title,
    required this.address,
    required this.isDefault,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'address': address,
        'isDefault': isDefault,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        title: json['title'],
        address: json['address'],
        isDefault: json['isDefault'],
        latitude: json['latitude'],
        longitude: json['longitude'],
      );
}
