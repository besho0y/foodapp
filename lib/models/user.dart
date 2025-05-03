class User {
  String name;
  String email;
  String phone;
  String uid;

  User({
    required this.name,
    required this.phone,
    required this.email,
    required this.uid
  });

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        uid= json['uid'],
        phone = json['phone'];

  get address => null;

  Map<String, dynamic> tomap() => {
        'name': name,
        'uid': uid,
        'email': email,
        'phone': phone,
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
