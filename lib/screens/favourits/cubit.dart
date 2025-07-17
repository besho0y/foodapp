import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/main.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/screens/favourits/states.dart';
import 'package:foodapp/screens/resturants/cubit.dart';

class Favouritecubit extends Cubit<FavouriteState> {
  Favouritecubit() : super(FavouriteInitialState());

  static Favouritecubit get(context) => BlocProvider.of(context);

  List<Item> favourites = [];
  List<String> _favoriteIds = []; // Cache favorite IDs for quick lookup

  // Check if an item is favorited
  bool isFavorite(String itemId) {
    return _favoriteIds.contains(itemId);
  }

  // Update favorite status for a list of items
  void updateItemsFavoriteStatus(List<Item> items) {
    for (var item in items) {
      item.isfavourite = _favoriteIds.contains(item.id);
    }
  }

  // Get current favorite IDs from Firestore
  Future<List<String>> _getFavoriteIds() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return [];

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) return [];

      return List<String>.from(userDoc.data()?['favourites'] ?? []);
    } catch (e) {
      print("Error getting favorite IDs: $e");
      return [];
    }
  }

  void toggleFavourite(Item item) async {
    print("🔄 === TOGGLING FAVOURITE ===");
    print("📝 Item: ${item.name} (ID: ${item.id})");
    print(
        "🔄 Current status: ${item.isfavourite ? 'Favorited' : 'Not favorited'}");

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("❌ User not logged in");
        emit(FavouriteErrorState("User not logged in"));
        return;
      }

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      // Toggle the favorite status locally first for immediate UI feedback
      item.isfavourite = !item.isfavourite;
      print(
          "🔄 New status: ${item.isfavourite ? 'Favorited' : 'Not favorited'}");

      // Update the cached favorite IDs
      if (item.isfavourite) {
        if (!_favoriteIds.contains(item.id)) {
          _favoriteIds.add(item.id);
        }
      } else {
        _favoriteIds.remove(item.id);
      }

      // Get current favorites list from Firestore
      final userSnapshot = await userDoc.get();
      List<String> favIds = [];
      if (userSnapshot.exists && userSnapshot.data() != null) {
        favIds = List<String>.from(userSnapshot.data()?['favourites'] ?? []);
      }

      print("📝 Current favorites in Firebase: $favIds");

      if (item.isfavourite) {
        // Add to favorites if not already present
        if (!favIds.contains(item.id)) {
          favIds.add(item.id);
        }

        // Add to local favorites list if not already present
        if (!favourites.any((i) => i.id == item.id)) {
          favourites.add(item);
        }
        print("✅ Added to favorites");
      } else {
        // Remove from favorites
        favIds.removeWhere((id) => id == item.id);
        favourites.removeWhere((i) => i.id == item.id);
        print("❌ Removed from favorites");
      }

      print("📝 Updated favorites list: $favIds");
      print("💾 Saving to Firebase...");

      // Update Firestore with favorite IDs only
      await userDoc.set({'favourites': favIds}, SetOptions(merge: true));

      // Update cached favorite IDs
      _favoriteIds = favIds;

      // Only emit a state change if we're currently on the favorites screen
      // This prevents unnecessary rebuilds when toggling from other screens
      if (state is FavouriteLoadedState) {
        emit(FavouriteLoadedState());
      }

      print("✅ Successfully toggled favorite for ${item.name}");
      print("📊 Current favorites count: ${_favoriteIds.length}");
      print("🔄 === TOGGLE COMPLETE ===");
    } catch (e) {
      print("❌ Error toggling favorite: $e");
      emit(FavouriteErrorState(e.toString()));

      // Revert the local state change since the operation failed
      item.isfavourite = !item.isfavourite;

      // Revert cached favorite IDs
      if (item.isfavourite) {
        if (!_favoriteIds.contains(item.id)) {
          _favoriteIds.add(item.id);
        }
        if (!favourites.any((i) => i.id == item.id)) {
          favourites.add(item);
        }
      } else {
        _favoriteIds.remove(item.id);
        favourites.removeWhere((i) => i.id == item.id);
      }
    }
  }

  Future<void> loadFavourites() async {
    // Don't emit loading state if we're already loading
    if (state is FavouriteLoadingState) {
      return;
    }

    emit(FavouriteLoadingState());
    print("🔄 === LOADING FAVOURITES ===");

    try {
      // Get the current user document
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("❌ User not logged in");
        emit(FavouriteErrorState("User not logged in"));
        return;
      }

      print("👤 Loading favorites for user: ${currentUser.uid}");

      // Get user document to retrieve favourites list
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        print("❌ User document not found in Firestore");
        emit(FavouriteErrorState("User data not found"));
        return;
      }

      // Get the list of favorited item IDs
      final favIds = List<String>.from(userDoc.data()?['favourites'] ?? []);
      print("📝 Found ${favIds.length} favourite IDs in Firebase: $favIds");

      // Update cached favorite IDs
      _favoriteIds = favIds;

      // Clear current favourites list
      favourites.clear();

      if (favIds.isEmpty) {
        print("📝 No favorites found - showing empty state");
        emit(FavouriteLoadedState());
        return;
      }

      // Try to load from restaurant cubit first (fastest method)
      bool loadedFromRestaurantCubit = await _loadFromRestaurantCubit(favIds);

      if (!loadedFromRestaurantCubit) {
        print(
            "🔄 Restaurant cubit method failed, using optimized Firebase method...");
        await _loadFavoritesFromFirebaseOptimized(favIds);
      }

      print("✅ Successfully loaded ${favourites.length} favourite items");
      print("🔄 === FAVOURITES LOADING COMPLETE ===");
      emit(FavouriteLoadedState());
    } catch (e) {
      print("❌ Error loading favourites: $e");
      print("📊 Stack trace: ${StackTrace.current}");
      emit(FavouriteErrorState(e.toString()));
    }
  }

  // Fast method: Load from restaurant cubit if available
  Future<bool> _loadFromRestaurantCubit(List<String> favIds) async {
    try {
      final context = navigatorKey.currentContext;
      if (context == null) {
        print("❌ No context available for restaurant cubit");
        return false;
      }

      final restaurantCubit = Restuarantscubit.get(context);
      final allRestaurants = restaurantCubit.restaurants;

      print("📊 Found ${allRestaurants.length} restaurants in cubit");

      if (allRestaurants.isEmpty) {
        print("❌ No restaurants loaded in cubit yet");
        return false;
      }

      print(
          "🔍 Searching for ${favIds.length} favorite items in restaurant cubit...");

      int foundCount = 0;
      for (String itemId in favIds) {
        bool found = false;

        for (var restaurant in allRestaurants) {
          try {
            final item = restaurant.menuItems.firstWhere(
              (item) => item.id == itemId,
            );

            print(
                "✅ Found item: ${item.name} in restaurant: ${restaurant.name}");
            item.isfavourite = true;
            favourites.add(item);
            found = true;
            foundCount++;
            break;
          } catch (e) {
            // Item not found in this restaurant, continue to next
            continue;
          }
        }

        if (!found) {
          print("❌ Could not find item with ID: $itemId in restaurant cubit");
        }
      }

      print(
          "✅ Loaded $foundCount/${favIds.length} items from restaurant cubit");

      // If we found most items, consider it successful
      if (foundCount > 0) {
        return true;
      }

      return false;
    } catch (e) {
      print("❌ Error accessing restaurant cubit: $e");
      return false;
    }
  }

  // Optimized Firebase method: Much faster than the old method
  Future<void> _loadFavoritesFromFirebaseOptimized(List<String> favIds) async {
    print("🔄 Loading favorites using optimized Firebase method...");

    try {
      if (favIds.isEmpty) {
        print("📝 No favorite IDs to search for");
        return;
      }

      // Use a more efficient approach: Query all items with matching IDs
      // Split into batches if too many favorites (Firestore 'in' query limit is 10)
      const int batchSize = 10;

      for (int i = 0; i < favIds.length; i += batchSize) {
        final batch = favIds.skip(i).take(batchSize).toList();
        print("🔍 Searching for batch of ${batch.length} items: $batch");

        // Search in all restaurants for this batch
        final restaurantsSnapshot =
            await FirebaseFirestore.instance.collection('restaurants').get();

        for (var restaurantDoc in restaurantsSnapshot.docs) {
          try {
            // Query multiple items at once using 'in' operator
            final itemsSnapshot = await FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurantDoc.id)
                .collection('items')
                .where(FieldPath.documentId, whereIn: batch)
                .get();

            for (var itemDoc in itemsSnapshot.docs) {
              if (itemDoc.exists && itemDoc.data().isNotEmpty) {
                final data = itemDoc.data();

                print(
                    "✅ Found item: ${data['name']} in restaurant: ${restaurantDoc.id}");

                final item = Item(
                  id: itemDoc.id,
                  name: data['name'] ?? '',
                  nameAr: data['namear'] ?? data['nameAr'] ?? '',
                  description: data['description'] ?? '',
                  descriptionAr:
                      data['descriptionar'] ?? data['descriptionAr'] ?? '',
                  price: (data['price'] as num?)?.toDouble() ?? 0.0,
                  img: data['img'] ?? '',
                  category: data['category'] ?? '',
                  categoryAr: data['categoryar'] ?? data['categoryAr'] ?? '',
                  categories: data['categories'] is List
                      ? List<String>.from(data['categories'])
                      : [],
                );
                item.isfavourite = true;
                favourites.add(item);
                print("📝 Added item ${item.name} to favorites list");
              }
            }
          } catch (e) {
            print("❌ Error searching restaurant ${restaurantDoc.id}: $e");
            continue;
          }
        }
      }

      print(
          "✅ Optimized Firebase search complete. Found ${favourites.length} items");

      // Clean up any favorite IDs that weren't found
      List<String> foundIds = favourites.map((item) => item.id).toList();
      List<String> missingIds =
          favIds.where((id) => !foundIds.contains(id)).toList();

      if (missingIds.isNotEmpty) {
        print(
            "🗑️ Removing ${missingIds.length} non-existent favorite items: $missingIds");
        _favoriteIds.removeWhere((id) => missingIds.contains(id));

        // Update Firestore to remove non-existent items
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .set({'favourites': _favoriteIds}, SetOptions(merge: true));
        }
      }
    } catch (e) {
      print("❌ Error in optimized Firebase loading: $e");
    }
  }

  // Initialize favorite IDs cache without loading full items
  Future<void> initializeFavoriteIds() async {
    try {
      _favoriteIds = await _getFavoriteIds();
      print("✅ Initialized favorite IDs cache: ${_favoriteIds.length} items");
    } catch (e) {
      print("❌ Error initializing favorite IDs: $e");
      _favoriteIds = [];
    }
  }

  // Clear all favorites (useful for logout)
  void clearFavorites() {
    favourites.clear();
    _favoriteIds.clear();
    emit(FavouriteInitialState());
  }

  // Enhanced method to reload favorites with better error handling
  Future<void> reloadFavorites() async {
    print("🔄 Force reloading favorites...");

    // Clear current data
    favourites.clear();

    // Reload from scratch
    await loadFavourites();
  }
}
