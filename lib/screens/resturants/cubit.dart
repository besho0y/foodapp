import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/banner.dart' as BannerModel;
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
  String _selectedArea = 'Cairo'; // Default area
  String _searchQuery = ''; // Store current search query

  List<BannerModel.Banner> banners = [];

  // Getter for selected area
  String get selectedArea => _selectedArea;

  // Method to update selected area and filter restaurants
  void updateSelectedArea(String area) {
    print("Updating selected area from $_selectedArea to $area");
    _selectedArea = area;
    _applyFilters();
    print(
        "After filtering: ${_filteredRestaurants?.length ?? 0} restaurants found for area $area");
    emit(RestuarantsGetDataSuccessState());
  }

  // Apply all filters (area and search)
  void _applyFilters() {
    print("Applying filters for area: $_selectedArea, search: '$_searchQuery'");
    print("Total restaurants before filtering: ${_allRestuarants.length}");

    List<Restuarants> filtered = List.from(_allRestuarants);

    // Debug: Show all restaurant areas
    for (var restaurant in _allRestuarants) {
      print("Restaurant: ${restaurant.name}, Area: ${restaurant.area}");
    }

    // Filter by area - check both single area and areas array
    filtered = filtered.where((restaurant) {
      // Check if restaurant serves the selected area
      bool servesArea = restaurant.area == _selectedArea ||
          restaurant.areas.contains(_selectedArea);
      return servesArea;
    }).toList();

    print("After area filtering: ${filtered.length} restaurants");

    // Filter by search query if exists
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((restaurant) {
        return restaurant.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            restaurant.nameAr.contains(_searchQuery) ||
            restaurant.category
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            restaurant.categoryAr.contains(_searchQuery);
      }).toList();
      print("After search filtering: ${filtered.length} restaurants");
    }

    // Always set filtered restaurants to show area-specific results
    _filteredRestaurants = filtered;
    print("Final filtered restaurants count: ${_filteredRestaurants!.length}");
  }

  // Synchronize favorite status for all items
  void syncFavoriteStatus(List<String> favoriteIds) {
    for (var restaurant in _allRestuarants) {
      for (var item in restaurant.menuItems) {
        item.isfavourite = favoriteIds.contains(item.id);
      }
    }
    // Emit state to trigger UI update
    emit(RestuarantsGetDataSuccessState());
  }

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

      // Fetch banners
      await _fetchBanners();

      _isInitialized = true;
      _applyFilters(); // Apply area filtering after loading restaurants
      emit(RestuarantsGetDataSuccessState());
    } catch (e) {
      print("Error initializing data: $e");
      emit(RestuarantsErrorState(e.toString()));
    }
  }

  // Initialize with user's selected area
  void initializeWithUserArea(String userArea) {
    _selectedArea = userArea;
    print("Initialized restaurant cubit with user area: $userArea");
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
            area: data['area']?.toString() ??
                'Cairo', // Keep for backward compatibility
            areas: data['areas'] is List
                ? List<String>.from(data['areas'])
                : [
                    data['area']?.toString() ?? 'Cairo'
                  ], // Use areas array or fallback to single area
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

  // Filter restaurants by category (respecting the selected area)
  void filterRestaurants(Category category) {
    try {
      print(
          "Filtering restaurants for category: ${category.toString()} in area: $_selectedArea");
      emit(RestuarantsLoadingState());

      if (category.en == "All") {
        print(
            "Selected 'All' category - showing all restaurants in $_selectedArea");
        // Apply area filter only
        _filteredRestaurants = _allRestuarants.where((restaurant) {
          bool areaMatches = restaurant.area == _selectedArea ||
              restaurant.areas.contains(_selectedArea);
          print(
              "Restaurant ${restaurant.name}: area=${restaurant.area}, areas=${restaurant.areas}, areaMatches=$areaMatches");
          return areaMatches;
        }).toList();
      } else {
        print(
            "Filtering for category: ${category.en}/${category.ar} in area: $_selectedArea");
        _filteredRestaurants = _allRestuarants.where((restaurant) {
          // Check both category and area
          bool categoryMatches =
              restaurant.category.toLowerCase() == category.en.toLowerCase() ||
                  restaurant.categoryAr == category.ar;
          bool areaMatches = restaurant.area == _selectedArea ||
              restaurant.areas.contains(_selectedArea);
          bool finalMatch = categoryMatches && areaMatches;

          print(
              "Restaurant ${restaurant.name}: category=${restaurant.category}, area=${restaurant.area}, areas=${restaurant.areas}, categoryMatches=$categoryMatches, areaMatches=$areaMatches, finalMatch=$finalMatch");
          return finalMatch;
        }).toList();
      }

      print(
          "Found ${_filteredRestaurants?.length} matching restaurants in $_selectedArea");
      emit(RestaurantsFilteredState());
    } catch (e) {
      print("Error filtering restaurants: $e");
      emit(RestuarantsErrorState(e.toString()));
    }
  }

  void search(String value) {
    emit(RestuarantsLoadingState());
    print("Searching restaurants for: '$value'");

    _searchQuery = value.trim();
    _applyFilters();

    print("Found ${_filteredRestaurants?.length} matching restaurants");
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
          area: restaurant.area,
          areas: restaurant.areas,
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

  // Private method to fetch banners
  Future<void> _fetchBanners() async {
    try {
      print("Starting to fetch banners...");

      // First try with ordering only (to avoid index requirement)
      QuerySnapshot bannersSnapshot;
      try {
        bannersSnapshot = await FirebaseFirestore.instance
            .collection("banners")
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        // If ordering fails, get all banners without ordering
        print("OrderBy failed, fetching all banners: $e");
        bannersSnapshot =
            await FirebaseFirestore.instance.collection("banners").get();
      }

      print("Found ${bannersSnapshot.docs.length} total banners");

      // Filter active banners in code instead of in query
      banners = bannersSnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Handle Firestore timestamp
            DateTime createdAt = DateTime.now();
            if (data['createdAt'] != null) {
              if (data['createdAt'] is Timestamp) {
                createdAt = (data['createdAt'] as Timestamp).toDate();
              } else if (data['createdAt'] is String) {
                createdAt = DateTime.parse(data['createdAt']);
              }
            }

            return BannerModel.Banner(
              id: doc.id,
              imageUrl: data['imageUrl'] ?? '',
              createdAt: createdAt,
              isActive: data['isActive'] ?? true,
            );
          })
          .where((banner) => banner.isActive) // Filter active banners in code
          .toList();

      // Sort by creation date in code
      banners.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print("Successfully loaded ${banners.length} active banners");
    } catch (e) {
      print("Error loading banners: $e");
      // Don't throw error, just use empty list
      banners = [];
    }
  }
}
