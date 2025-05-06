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

  List<String> itemcategories = ["All"]; // Default category

  // Get menu categories for a specific restaurant
  List<String> getRestaurantMenuCategories(String restaurantId) {
    try {
      // Find the restaurant
      final restaurant = restaurants.firstWhere(
        (r) => r.id == restaurantId,
        orElse: () => throw Exception('Restaurant not found'),
      );

      // Get unique categories from restaurant's menu items
      final uniqueCategories = <String>{};
      for (var item in restaurant.menuItems) {
        if (item.category.isNotEmpty && item.category != "Uncategorized") {
          uniqueCategories.add(item.category);
        }
      }

      // Return categories with "All" as the first option
      return ["All", ...uniqueCategories.toList()];
    } catch (e) {
      print("Error getting menu categories for restaurant: $e");
      return ["All"]; // Return default category
    }
  }

  void getRestuarants() async {
    // Clear all data before loading
    allRestuarants.clear();
    restaurants.clear();
    itemcategories = ["All"]; // Reset to default category only
    emit(RestuarantsLoadingState());

    try {
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

        // Read menu categories (for item filtering)
        List<String> menuCategories =
            List<String>.from(data['menuCategories'] ?? []);

        // Get average rating from reviews
        double averageRating = await getAverageRating(restaurantId);

        // Add the restaurant with its items and correct categories
        allRestuarants.add(Restuarants.fromJson({
          ...data,
          'items': items.map((item) => item.toJson()).toList(),
          'id': restaurantId,
          'categories': firestoreCategories,
          'menuCategories': menuCategories,
          'rating': averageRating, // Use the fetched average rating
        }));
      }

      // Copy to restaurants list for display
      restaurants = List.from(allRestuarants);
      emit(RestuarantsGetDataSuccessState());
    } catch (e) {
      print("Error loading restaurants: $e");
      emit(RestuarantsErrorState(e.toString()));
    }
  }

  // Function to calculate average rating from reviews
  Future<double> getAverageRating(String restaurantId) async {
    try {
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("reviews")
          .get();

      if (reviewsSnapshot.docs.isEmpty) {
        return 0.0; // Default rating if no reviews
      }

      double totalRating = 0.0;
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('rating')) {
          totalRating += double.parse(data['rating'].toString());
        }
      }

      // Format to one decimal place for consistency
      double average = totalRating / reviewsSnapshot.docs.length;
      return double.parse(average.toStringAsFixed(1));
    } catch (e) {
      print("Error fetching average rating: $e");
      return 0.0;
    }
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
