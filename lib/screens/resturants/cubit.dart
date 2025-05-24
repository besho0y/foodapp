import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/category.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/models/resturant.dart';
import 'package:foodapp/screens/resturants/states.dart';

class Restuarantscubit extends Cubit<ResturantsStates> {
  Restuarantscubit() : super(ResturantsInitialState()) {
    // Initialize data on creation
    initializeData();
  }
  static Restuarantscubit get(context) => BlocProvider.of(context);

  // Single source of truth for restaurants
  final List<Restuarants> _allRestuarants = [];
  // Getter for filtered/displayed restaurants
  List<Restuarants> get restaurants => _filteredRestaurants ?? _allRestuarants;
  // Temporary list for filtered results
  List<Restuarants>? _filteredRestaurants;

  List<Category> categories = [];
  bool _isInitialized = false;

  List<String> banners = [
    "assets/images/banners/banner1.png",
    "assets/images/banners/banner2.png",
    "assets/images/banners/banner3.png",
  ];

  // Initialize all data
  Future<void> initializeData() async {
    if (_isInitialized) {
      print("Data already initialized, skipping...");
      return;
    }

    print("Initializing data...");
    emit(RestuarantsLoadingState());

    try {
      // Get categories first
      await _fetchCategories();

      // Then get restaurants
      await _fetchRestaurants();

      _isInitialized = true;
      emit(RestuarantsGetDataSuccessState());
    } catch (e) {
      print("Error initializing data: $e");
      emit(RestuarantsErrorState(e.toString()));
    }
  }

  // Private method to fetch restaurants
  Future<void> _fetchRestaurants() async {
    print("Starting to fetch restaurants...");
    try {
      // Clear existing restaurants to prevent duplicates
      _allRestuarants.clear();

      // Get restaurants ordered by creation date (newest first)
      final restaurantSnapshots = await FirebaseFirestore.instance
          .collection("restaurants")
          .orderBy('createdAt', descending: true) // Order by newest first
          .get();
      print("Found ${restaurantSnapshots.docs.length} restaurants");

      if (restaurantSnapshots.docs.isEmpty) {
        print("No restaurants found in Firestore");
        return;
      }

      for (var doc in restaurantSnapshots.docs) {
        try {
          String restaurantId = doc.id;
          final data = doc.data();
          print(
              "Processing restaurant: ${data['resname'] ?? 'Unnamed'} (ID: $restaurantId)");

          // Get items subcollection ordered by creation date (newest first)
          final itemsSnapshot = await FirebaseFirestore.instance
              .collection("restaurants")
              .doc(restaurantId)
              .collection("items")
              .orderBy('createdAt', descending: true) // Order by newest first
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
              nameAr: itemData['namear'] ?? '',
              descriptionAr: itemData['descriptionar'] ?? '',
              categoryAr: itemData['categoryar'] ?? '',
            );
          }).toList();

          // Create restaurant with complete data
          Restuarants restaurant = Restuarants(
            id: restaurantId,
            name: data['resname'] ?? '',
            nameAr: data['namear'] ?? '',
            menuItems: items,
            img: data['img'] ?? 'assets/images/restuarants/store.jpg',
            rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
            category: data['category']?.toString() ?? 'fast food',
            categoryAr: data['categoryar']?.toString() ?? 'طعام سريع',
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
            menuCategoriesAr: data['menuCategoriesAr'] is List
                ? List<String>.from(data['menuCategoriesAr'])
                : null,
          );

          _allRestuarants.add(restaurant);
        } catch (e) {
          print("Error processing restaurant ${doc.id}: $e");
          // Continue with next restaurant
        }
      }

      print("Successfully loaded ${_allRestuarants.length} restaurants");
    } catch (e) {
      print("Error loading restaurants: $e");
      rethrow;
    }
  }

  // Private method to fetch categories
  Future<void> _fetchCategories() async {
    try {
      print("Starting to fetch restaurant categories...");

      final categoriesRef =
          FirebaseFirestore.instance.collection("restaurants_categories");
      print("Attempting to access collection: ${categoriesRef.path}");

      final QuerySnapshot categoriesSnapshot;
      try {
        categoriesSnapshot = await categoriesRef.get();
        print("Successfully connected to Firebase");
      } catch (e) {
        print("Firebase connection error: $e");
        // If collection doesn't exist, create it with test data
        if (e is FirebaseException &&
            (e.code == 'permission-denied' || e.code == 'not-found')) {
          print("Categories collection not found, creating test data...");
          await addTestCategory();
          return;
        }
        rethrow;
      }

      print(
          "Raw snapshot data: ${categoriesSnapshot.docs.map((doc) => doc.data()).toList()}");
      print("Number of categories found: ${categoriesSnapshot.docs.length}");

      categories.clear();

      // Add the "All" category first
      categories.add(Category(
          en: "All", ar: "الكل", img: "assets/images/categories/all.png"));

      if (categoriesSnapshot.docs.isEmpty) {
        print(
            "No restaurant categories found in Firebase. Adding a test category...");
        await addTestCategory();
        return;
      }

      for (var doc in categoriesSnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          print("Processing category document: ${doc.id}");
          print("Category data: $data");

          if (data['en'] != null && data['ar'] != null) {
            final category = Category(
                en: data['en'].toString(),
                ar: data['ar'].toString(),
                img: data['img']?.toString() ??
                    'assets/images/categories/${data['en'].toString().toLowerCase()}.png');
            categories.add(category);
            print("Added category: ${category.toString()}");
          } else {
            print(
                "Invalid category data in document ${doc.id}: missing required fields");
          }
        } catch (e) {
          print("Error processing category ${doc.id}: $e");
        }
      }

      print(
          "Final categories list: ${categories.map((c) => c.toString()).toList()}");
    } catch (e) {
      print("Error in getCategories: $e");
      rethrow;
    }
  }

  // Filter restaurants by category
  void filterRestaurants(Category category) {
    try {
      print("Filtering restaurants for category: ${category.toString()}");
      emit(RestuarantsLoadingState());

      if (category.en == "All") {
        print("Selected 'All' category - showing all restaurants");
        _filteredRestaurants = null; // Use _allRestuarants
      } else {
        print("Filtering for category: ${category.en}/${category.ar}");
        _filteredRestaurants = _allRestuarants.where((restaurant) {
          bool matches =
              restaurant.category.toLowerCase() == category.en.toLowerCase() ||
                  restaurant.categoryAr == category.ar;
          print(
              "Restaurant ${restaurant.name}: category=${restaurant.category}, categoryAr=${restaurant.categoryAr}, matches=$matches");
          return matches;
        }).toList();
        print("Found ${_filteredRestaurants?.length} matching restaurants");
      }

      emit(RestaurantsFilteredState());
    } catch (e) {
      print("Error filtering restaurants: $e");
      emit(RestuarantsErrorState(e.toString()));
    }
  }

  void search(String value) {
    emit(RestuarantsLoadingState());
    print("Searching restaurants for: '$value'");

    if (value.trim().isEmpty) {
      _filteredRestaurants = null; // Use all restaurants
      print("Empty search query - showing all restaurants");
    } else {
      final searchTerm = value.toLowerCase().trim();
      _filteredRestaurants = _allRestuarants.where((restaurant) {
        // Search in restaurant name (English)
        final nameMatches = restaurant.name.toLowerCase().contains(searchTerm);

        // Search in restaurant name (Arabic)
        final nameArMatches =
            restaurant.nameAr.toLowerCase().contains(searchTerm);

        // Search in category (English)
        final categoryMatches =
            restaurant.category.toLowerCase().contains(searchTerm);

        // Search in category (Arabic)
        final categoryArMatches =
            restaurant.categoryAr.toLowerCase().contains(searchTerm);

        // Print debug info
        print("Restaurant: ${restaurant.name}/${restaurant.nameAr}");
        print("  Name match: $nameMatches, Name AR match: $nameArMatches");
        print(
            "  Category match: $categoryMatches, Category AR match: $categoryArMatches");

        // Return true if any field matches
        return nameMatches ||
            nameArMatches ||
            categoryMatches ||
            categoryArMatches;
      }).toList();

      print("Found ${_filteredRestaurants?.length} matching restaurants");
    }
    emit(RestuarantsGetDataSuccessState());
  }

  // Reset restaurant data and state
  void resetRestaurants() {
    _allRestuarants.clear();
    _filteredRestaurants = null;
    _isInitialized = false;
    emit(ResturantsInitialState());
    initializeData(); // Reinitialize all data
  }

  // Get category name based on locale
  String getCategoryName(Category category, bool isArabic) {
    return isArabic ? category.ar : category.en;
  }

  // Function to calculate average rating from reviews
  Future<double> getAverageRating(String restaurantId) async {
    try {
      print("Fetching reviews for restaurant: $restaurantId");
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("reviews")
          .get();

      if (reviewsSnapshot.docs.isEmpty) {
        print("No reviews found for restaurant: $restaurantId");
        return 0.0;
      }

      double totalRating = 0.0;
      int validReviews = 0;

      for (var doc in reviewsSnapshot.docs) {
        try {
          final data = doc.data();
          if (data.containsKey('rating')) {
            final rating = double.tryParse(data['rating'].toString());
            if (rating != null && rating >= 0 && rating <= 5) {
              totalRating += rating;
              validReviews++;
            }
          }
        } catch (e) {
          print("Error processing review ${doc.id}: $e");
        }
      }

      if (validReviews == 0) {
        print("No valid ratings found for restaurant: $restaurantId");
        return 0.0;
      }

      // Format to one decimal place for consistency
      double average = totalRating / validReviews;
      double roundedAverage = double.parse(average.toStringAsFixed(1));

      // Update restaurant's rating in Firestore
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .update({'rating': roundedAverage});

      print(
          "Updated average rating for restaurant $restaurantId: $roundedAverage");
      return roundedAverage;
    } catch (e) {
      print("Error calculating average rating: $e");
      return 0.0;
    }
  }

  // Add a review to a restaurant
  Future<void> addReview({
    required String restaurantId,
    required double rating,
    required String comment,
    required String userId,
    String? userName,
  }) async {
    try {
      print("Adding review for restaurant: $restaurantId");

      if (rating < 0 || rating > 5) {
        throw Exception("Rating must be between 0 and 5");
      }

      final reviewData = {
        'rating': rating,
        'comment': comment,
        'userId': userId,
        'userName': userName ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("reviews")
          .add(reviewData);

      print("Review added successfully");

      // Update the average rating
      await getAverageRating(restaurantId);

      // Update the restaurant in our local list
      final index = _allRestuarants.indexWhere((r) => r.id == restaurantId);
      if (index != -1) {
        final restaurant = _allRestuarants[index];
        final newRating = await getAverageRating(restaurantId);
        _allRestuarants[index] = Restuarants(
          id: restaurant.id,
          name: restaurant.name,
          nameAr: restaurant.nameAr,
          menuItems: restaurant.menuItems,
          img: restaurant.img,
          rating: newRating,
          category: restaurant.category,
          categoryAr: restaurant.categoryAr,
          deliveryFee: restaurant.deliveryFee,
          deliveryTime: restaurant.deliveryTime,
          ordersnum: restaurant.ordersnum,
          categories: restaurant.categories,
          menuCategories: restaurant.menuCategories,
          menuCategoriesAr: restaurant.menuCategoriesAr,
        );
        emit(RestuarantsGetDataSuccessState());
      }
    } catch (e) {
      print("Error adding review: $e");
      emit(RestuarantsErrorState(e.toString()));
    }
  }

  // Get reviews for a restaurant
  Future<List<Map<String, dynamic>>> getReviews(String restaurantId) async {
    try {
      print("Fetching reviews for restaurant: $restaurantId");
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("reviews")
          .orderBy('timestamp', descending: true)
          .get();

      return reviewsSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'rating': double.tryParse(data['rating'].toString()) ?? 0.0,
          'comment': data['comment'] ?? '',
          'userId': data['userId'] ?? '',
          'userName': data['userName'] ?? 'Anonymous',
          'timestamp': data['timestamp']?.toDate() ?? DateTime.now(),
        };
      }).toList();
    } catch (e) {
      print("Error fetching reviews: $e");
      return [];
    }
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
      }
    } catch (e) {
      print("Error checking for restaurants: $e");
      emit(RestuarantsErrorState(e.toString()));
    }
  }

  // Add a test category to Firebase
  Future<void> addTestCategory() async {
    try {
      print("Adding test category to Firebase...");
      await FirebaseFirestore.instance
          .collection("restaurants_categories")
          .add({
        'en': 'Pizza',
        'ar': 'بيتزا',
        'img': 'assets/images/categories/pizza.png'
      });
      print("Test category added successfully");

      // IMPORTANT: Do not fetch categories again here - it causes an infinite loop
      // Commented out to prevent infinite recursion:
      // await _fetchCategories();
    } catch (e) {
      print("Error adding test category: $e");
      emit(RestuarantsErrorState(e.toString()));
    }
  }

  // Refresh only restaurants data without resetting state
  Future<void> refreshRestaurants() async {
    print("Refreshing restaurants data...");
    emit(RestuarantsLoadingState());

    try {
      // Remember if we had filtered results
      final wasFiltered = _filteredRestaurants != null;

      // Clear only restaurant data
      _allRestuarants.clear();

      // Reload restaurants from Firestore
      await _fetchRestaurants();

      // If we had filtered results, apply the current filter criteria again
      if (wasFiltered && _filteredRestaurants != null) {
        // Here we'd reapply the current search/filter
        // Since we don't have access to the original filter criteria,
        // we'll just reset to showing all restaurants
        _filteredRestaurants = null;
      }

      print("Successfully refreshed ${_allRestuarants.length} restaurants");
      emit(RestuarantsGetDataSuccessState());
    } catch (e) {
      print("Error refreshing restaurants: $e");
      emit(RestuarantsErrorState(e.toString()));
    }
  }
}
