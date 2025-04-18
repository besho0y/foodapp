class User {
  String name;
  String address;
  int phone;

  User({
    required this.name,
    required this.address,
    required this.phone,
  });
 User.fromJson(Map<String, dynamic> json)
      : name = json['name'] ,
        address = json['address'] ,
        phone = json['phone'];
}
