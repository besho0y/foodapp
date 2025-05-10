import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/generated/l10n.dart';
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
  List<Restuarants> allRestuarants = [];

  List<Map<String, dynamic>> categories(BuildContext context) => [
        {"name": S.of(context).all, "img": "assets/images/categories/all.png"},
        {
          "name": S.of(context).fastfood,
          "img": "assets/images/categories/fastfood.png"
        },
        {
          "name": S.of(context).seafood,
          "img": "assets/images/categories/seafood.PNG"
        },
        {
          "name": S.of(context).sweets,
          "img": "assets/images/categories/sweets.png"
        },
        {
          "name": S.of(context).drinks,
          "img": "assets/images/categories/drinks.png"
        },
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
    print("Starting to fetch restaurants...");
    // Clear all data before loading
    allRestuarants.clear();
    restaurants.clear();
    itemcategories = ["All"]; // Reset to default category only
    emit(RestuarantsLoadingState());

    try {
      print("Fetching restaurants from Firestore...");
      final restaurantSnapshots =
          await FirebaseFirestore.instance.collection("restaurants").get();
      print("Found ${restaurantSnapshots.docs.length} restaurants");

      if (restaurantSnapshots.docs.isEmpty) {
        print("No restaurants found in Firestore");
        emit(RestuarantsGetDataSuccessState()); // Emit success even when empty
        return;
      }

      for (var doc in restaurantSnapshots.docs) {
        try {
          String restaurantId = doc.id;
          final data = doc.data();
          print(
              "Processing restaurant: ${data['resname'] ?? 'Unnamed'} (ID: $restaurantId)");

          // Get items subcollection
          final itemsSnapshot = await FirebaseFirestore.instance
              .collection("restaurants")
              .doc(restaurantId)
              .collection("items")
              .get();

          print(
              "Found ${itemsSnapshot.docs.length} items for restaurant $restaurantId");

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

          // Create restaurant with complete data
          Restuarants restaurant = Restuarants(
            id: restaurantId,
            name: data['resname'] ?? '',
            menuItems: items,
            img: data['img'] ?? 'assets/images/restuarants/store.jpg',
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            category: data['category']?.toString() ?? 'fast food',
            deliveryFee: data['delivery fee']?.toString() ?? '50',
            deliveryTime: data['delivery time']?.toString() ?? '30-45 min',
            ordersnum: data['ordersnumber'] is num
                ? (data['ordersnumber'] as num).toInt()
                : 0,
            categories: data['categories'] is List
                ? List<String>.from(data['categories'])
                : ['fast food'],
            menuCategories: data['menuCategories'] is List
                ? List<String>.from(data['menuCategories'])
                : null,
          );

          allRestuarants.add(restaurant);
        } catch (e) {
          print("Error processing restaurant ${doc.id}: $e");
          // Continue with next restaurant
        }
      }

      // Copy to restaurants list for display
      restaurants = List.from(allRestuarants);
      print("Successfully loaded ${restaurants.length} restaurants");
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

  // Add a test restaurant to Firestore for testing
  Future<void> addTestRestaurant() async {
    print("Adding test restaurant to Firestore...");
    emit(RestuarantsLoadingState());

    try {
      // Create restaurant document data
      final restaurantData = {
        'resname': 'Test Restaurant',
        'category': 'fast food',
        'delivery fee': '50',
        'delivery time': '30-45 min',
        'img': 'assets/images/restuarants/store.jpg',
        'rating': 4.5,
        'ordersnumber': 0,
        'categories': ['fast food', 'burgers'],
      };

      // Add restaurant document to Firestore
      DocumentReference restaurantRef = await FirebaseFirestore.instance
          .collection('restaurants')
          .add(restaurantData);

      print("Created test restaurant with ID: ${restaurantRef.id}");

      // Add menu items to the restaurant
      await restaurantRef.collection('items').add({
        'name': 'Burger',
        'description': 'Delicious burger with cheese',
        'price': 9.99,
        'img': 'assets/images/items/burger.png',
        'category': 'Burger',
      });

      await restaurantRef.collection('items').add({
        'name': 'Pizza',
        'description': 'Classic pepperoni pizza',
        'price': 12.99,
        'img': 'assets/images/items/pizza.png',
        'category': 'Pizza',
      });

      print("Added menu items to test restaurant");

      // Reload restaurants to include the new one
      getRestuarants();
    } catch (e) {
      print("Error adding test restaurant: $e");
      emit(RestuarantsErrorState(e.toString()));
    }
  }

  // Check if any restaurants exist in Firestore, create a sample if none
  Future<void> ensureRestaurantsExist() async {
    print("Checking if any restaurants exist in Firestore...");
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print("No restaurants found in Firestore, creating a sample one...");
        await addTestRestaurant();
      } else {
        print("Found existing restaurants in Firestore");
        getRestuarants();
      }
    } catch (e) {
      print("Error checking for restaurants: $e");
      emit(RestuarantsErrorState(e.toString()));
    }
  }

  // Reset restaurant data and state
  void resetRestaurants() {
    print("Resetting restaurant data and state...");
    allRestuarants.clear();
    restaurants.clear();
    emit(ResturantsInitialState());

    // Reload restaurants
    getRestuarants();
  }
}
