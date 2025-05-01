import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/models/resturant.dart';
import 'package:foodapp/screens/resturants/states.dart';

class Restuarantscubit extends Cubit<ResturantsStates> {
  Restuarantscubit() : super(ResturantsInitialState());
  static Restuarantscubit get(context) => BlocProvider.of(context);
  List<Restuarants> restaurants = [];

  List<String> banners = [
    "assets/images/banners/banner1.png",
    "assets/images/banners/banner2.png",
    "assets/images/banners/banner3.png",
  ];
  List<Restuarants> allRestuarants = [
    Restuarants(
      name: "mcdonald's",
      img: "assets/images/restuarants/fastfood.jpg",
      rating: 3.5,
      category: "fast food",
      menuItems: [
        Item(
          id: "1",
          name: "burger",
          description: "best burger",
          price: 210,
          img: "assets/images/items/burger.png",
          category: "Burger"
        ),
        Item(
          id: "2",
          name: "pizza",
          description: "best pizza",
          price: 210,
          img: "assets/images/items/pizza.png",
          category: "Pizza"
        ),
        Item(
          id: "3",
          name: "sushi",
          description: "best sushi",
          price: 210,
          img: "assets/images/items/sushi.png",
          category: "Sushi"
        ),
        Item(
          id: "4",
          name: "pasta",
          description: "best pasta",
          price: 210,
          img: "assets/images/items/pasta.png",
          category: "Pizaa"
        ),
        Item(
          id: "5",
          name: "rice",
          description: "best rice",
          price: 210,
          img: "assets/images/items/rice.png",
          category: "For you"
        ),
      ],
    ),
    

  ];
  List<Map<String, dynamic>> categories = [
    {"name": "All", "img": "assets/images/categories/all.png"},

    {"name": "fast food", "img": "assets/images/categories/fastfood.png"},
    {"name": "sea food", "img": "assets/images/categories/seafood.PNG"},
    {"name": "sweets", "img": "assets/images/categories/sweets.png"},
    {"name": "drinks", "img": "assets/images/categories/drinks.png"},
  ];

  void getRestuarants() {
    restaurants = List.from(allRestuarants);
    emit(RestuarantsGetDataSuccessState());
  }

  // filter the restaurants by category

  void filterRestaurants(String categoryName) {
    if (categoryName == "All") {
      restaurants = List.from(allRestuarants);
    } else {
      restaurants =
          allRestuarants
              .where((restaurant) => restaurant.category == categoryName)
              .toList();
    }
    emit(RestaurantsFilteredState());
  }
}
