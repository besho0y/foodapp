import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/screens/favourits/states.dart';

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
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(FavouriteErrorState("User not logged in"));
        return;
      }

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      // Toggle the favorite status locally first for immediate UI feedback
      item.isfavourite = !item.isfavourite;

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

      if (item.isfavourite) {
        // Add to favorites if not already present
        if (!favIds.contains(item.id)) {
          favIds.add(item.id);
        }

        // Add to local favorites list if not already present
        if (!favourites.any((i) => i.id == item.id)) {
          favourites.add(item);
        }
        emit(FavouriteAddState());
      } else {
        // Remove from favorites
        favIds.removeWhere((id) => id == item.id);
        favourites.removeWhere((i) => i.id == item.id);
        emit(FavouriteRemoveState());
      }

      // Update Firestore with favorite IDs only
      await userDoc.set({'favourites': favIds}, SetOptions(merge: true));

      // Update cached favorite IDs
      _favoriteIds = favIds;

      print(
          "Successfully toggled favorite for ${item.name}. Current favorites: ${_favoriteIds.length}");
    } catch (e) {
      print("Error toggling favorite: $e");
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
    emit(FavouriteLoadingState());
    print("Loading favourites...");

    try {
      // Get the current user document
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(FavouriteErrorState("User not logged in"));
        return;
      }

      // Get user document to retrieve favourites list
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        emit(FavouriteErrorState("User data not found"));
        return;
      }

      // Get the list of favorited item IDs
      final favIds = List<String>.from(userDoc.data()?['favourites'] ?? []);
      print("Found ${favIds.length} favourite IDs: $favIds");

      // Update cached favorite IDs
      _favoriteIds = favIds;

      // Clear current favourites list
      favourites.clear();

      if (favIds.isEmpty) {
        emit(FavouriteLoadedState());
        return;
      }

      // Load items from restaurants collection
      for (String id in favIds) {
        try {
          bool found = false;
          final restaurantsSnapshot =
              await FirebaseFirestore.instance.collection('restaurants').get();

          for (var restaurantDoc in restaurantsSnapshot.docs) {
            final itemDoc = await FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurantDoc.id)
                .collection('items')
                .doc(id)
                .get();

            if (itemDoc.exists && itemDoc.data() != null) {
              final data = itemDoc.data()!;
              data['id'] = id;
              final item = Item(
                id: data['id'] ?? '',
                name: data['name'] ?? '',
                nameAr: data['namear'] ?? '', // Note the different field name
                description: data['description'] ?? '',
                descriptionAr: data['descriptionar'] ??
                    '', // Note the different field name
                price: (data['price'] as num?)?.toDouble() ?? 0.0,
                img: data['img'] ?? '',
                category: data['category'] ?? '',
                categoryAr:
                    data['categoryar'] ?? '', // Note the different field name
                categories: data['categories'] is List
                    ? List<String>.from(data['categories'])
                    : [],
              );
              item.isfavourite = true;
              favourites.add(item);
              found = true;
              break;
            }
          }

          if (!found) {
            print("Could not find item with ID: $id in any restaurant");
            // Remove this ID from favorites since the item no longer exists
            _favoriteIds.remove(id);
          }
        } catch (e) {
          print("Error searching for item $id in restaurants: $e");
        }
      }

      // Update Firestore if we removed any non-existent items
      if (_favoriteIds.length != favIds.length) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({'favourites': _favoriteIds}, SetOptions(merge: true));
        print(
            "Cleaned up ${favIds.length - _favoriteIds.length} non-existent favorite items");
      }

      print("Successfully loaded ${favourites.length} favourite items");
      emit(FavouriteLoadedState());
    } catch (e) {
      print("Error loading favourites: $e");
      emit(FavouriteErrorState(e.toString()));
    }
  }

  // Initialize favorite IDs cache without loading full items
  Future<void> initializeFavoriteIds() async {
    try {
      _favoriteIds = await _getFavoriteIds();
      print("Initialized favorite IDs cache: ${_favoriteIds.length} items");
    } catch (e) {
      print("Error initializing favorite IDs: $e");
      _favoriteIds = [];
    }
  }

  // Clear all favorites (useful for logout)
  void clearFavorites() {
    favourites.clear();
    _favoriteIds.clear();
    emit(FavouriteInitialState());
  }
}
