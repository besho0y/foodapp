import 'package:cloud_firestore/cloud_firestore.dart';
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
    // Restuarants(
    //   name: "mcdonald's",
    //   img: "assets/images/restuarants/fastfood.jpg",
    //   rating: 3.5,
    //   category: "fast food",
    //   menuItems: [
    //     Item(
    //       id: "1",
    //       name: "burger",
    //       description: "best burger",
    //       price: 210,
    //       img: "assets/images/items/burger.png",
    //       category: "Burger"
    //     ),
    //     Item(
    //       id: "2",
    //       name: "pizza",
    //       description: "best pizza",
    //       price: 210,
    //       img: "assets/images/items/pizza.png",
    //       category: "Pizza"
    //     ),
    //     Item(
    //       id: "3",
    //       name: "sushi",
    //       description: "best sushi",
    //       price: 210,
    //       img: "assets/images/items/sushi.png",
    //       category: "Sushi"
    //     ),
    //     Item(
    //       id: "4",
    //       name: "pasta",
    //       description: "best pasta",
    //       price: 210,
    //       img: "assets/images/items/pasta.png",
    //       category: "Pizaa"
    //     ),
    //     Item(
    //       id: "5",
    //       name: "rice",
    //       description: "best rice",
    //       price: 210,
    //       img: "assets/images/items/rice.png",
    //       category: "For you"
    //     ),
    //   ],
    // ),
  ];
  List<Map<String, dynamic>> categories = [
    {"name": "All", "img": "assets/images/categories/all.png"},
    {"name": "fast food", "img": "assets/images/categories/fastfood.png"},
    {"name": "sea food", "img": "assets/images/categories/seafood.PNG"},
    {"name": "sweets", "img": "assets/images/categories/sweets.png"},
    {"name": "drinks", "img": "assets/images/categories/drinks.png"},
  ];

  List<String> itemcategories = [];

  void getRestuarants() async {
    allRestuarants.clear();
    emit(RestuarantsLoadingState());

    final restaurantSnapshots =
        await FirebaseFirestore.instance.collection("restaurants").get();

    for (var doc in restaurantSnapshots.docs) {
      String restaurantId = doc.id;
      final data = doc.data();

      // Get items subcollection
      final itemsSnapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("items")
          .get();

      List<Item> items = itemsSnapshot.docs.map((itemDoc) {
        final itemData = itemDoc.data();
        return Item(
          id: itemDoc.id,
          name: itemData['name'] ?? '',
          description: itemData['description'] ?? '',
          price: (itemData['price'] as num?)?.toDouble() ?? 0.0,
          img: itemData['img'] ?? '',
          category: itemData['category'] ?? '',
        );
      }).toList();

      // ✅ Read categories from the document data
      List<String> firestoreCategories =
          List<String>.from(data['categories'] ?? []);

      // Add the restaurant with its items and correct categories
      allRestuarants.add(Restuarants.fromJson({
        ...data,
        'items': items.map((item) => item.toJson()).toList(),
        'id': restaurantId,
        'categories': firestoreCategories,
      }));
      itemcategories.addAll(firestoreCategories);
    }

    restaurants = List.from(allRestuarants);
    emit(RestuarantsGetDataSuccessState());
  }

  void filterRestaurants(String categoryName) {
    if (categoryName == "All") {
      restaurants = List.from(allRestuarants);
    } else {
      restaurants = allRestuarants
          .where((restaurant) => restaurant.category == categoryName)
          .toList();
    }
    emit(RestaurantsFilteredState());
  }

  void search(String value) {
    emit(RestuarantsLoadingState()); // Optional
    if (value.trim().isEmpty) {
      restaurants = allRestuarants;
    } else {
      final lowerValue = value.toLowerCase();
      restaurants = allRestuarants
          .where((restaurant) =>
              restaurant.name.toLowerCase().contains(lowerValue))
          .toList();
    }
    emit(RestuarantsGetDataSuccessState());
  }
}
