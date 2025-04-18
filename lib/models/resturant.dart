class HomeData {
  List<Restuarants> restuarants = [];
  List<Menu> menuItems = [];
  HomeData({required this.restuarants, required this.menuItems});

  HomeData.fromJson(Map<String, dynamic> json) {
    json["restaurants"].foreach((element) => restuarants.add(element));
  }
}

class Restuarants {
  String name;

  Restuarants.fromJson(Map<String, dynamic> json) : name = json['name'];
}

class Menu {
  List<Items> items = [];
  Menu.fromJson(Map<String, dynamic> json) {}
}

class Items {
  Items.fromJson(Map<String, dynamic> json) {}
}
