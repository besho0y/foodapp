import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/screens/favourits/states.dart';

class Favouritecubit extends Cubit<FavouriteState> {
  Favouritecubit() : super(FavouriteInitialState());

  static Favouritecubit get(context) => BlocProvider.of(context);

  List<Item> favourites = [];
  void toggleFavourite(Item item) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(FavouriteErrorState("User not logged in"));
        return;
      }

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      // Toggle the favorite status
      item.isfavourite = !item.isfavourite;

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
        favourites.add(item);
        emit(FavouriteAddState());
      } else {
        // Remove from favorites
        favIds.removeWhere((id) => id == item.id);
        favourites.removeWhere((i) => i.id == item.id);
        emit(FavouriteRemoveState());
      }

      // Update Firestore
      await userDoc.set({'favourites': favIds}, SetOptions(merge: true));
    } catch (e) {
      print("Error toggling favorite: $e");
      emit(FavouriteErrorState(e.toString()));

      // Revert the local state change since the operation failed
      item.isfavourite = !item.isfavourite;
      if (item.isfavourite) {
        if (!favourites.any((i) => i.id == item.id)) {
          favourites.add(item);
        }
      } else {
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

      // Clear current favourites list
      favourites.clear();

      if (favIds.isEmpty) {
        emit(FavouriteLoadedState());
        return;
      }

      // First approach: Get ALL items from Firestore and then filter by ID
      print("Loading all items to filter favorites");

      // This will hold ALL items across all restaurants
      Map<String, Item> allItems = {};

      // Get items from main collection
      try {
        final itemsSnapshot =
            await FirebaseFirestore.instance.collection('items').get();
        print("Found ${itemsSnapshot.docs.length} items in main collection");

        for (var doc in itemsSnapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id; // Ensure ID is set
          final item = Item.fromJson(data);
          allItems[doc.id] = item;
        }
      } catch (e) {
        print("Error loading main items: $e");
      }

      // Get items from all restaurant subcollections
      try {
        final restaurantsSnapshot =
            await FirebaseFirestore.instance.collection('restaurants').get();
        print("Found ${restaurantsSnapshot.docs.length} restaurants");

        for (var restaurantDoc in restaurantsSnapshot.docs) {
          try {
            final itemsSnapshot = await FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurantDoc.id)
                .collection('items')
                .get();

            print(
                "Found ${itemsSnapshot.docs.length} items in restaurant ${restaurantDoc.id}");

            for (var doc in itemsSnapshot.docs) {
              final data = doc.data();
              data['id'] = doc.id; // Ensure ID is set
              final item = Item.fromJson(data);
              allItems[doc.id] = item;
            }
          } catch (e) {
            print("Error loading items for restaurant ${restaurantDoc.id}: $e");
          }
        }
      } catch (e) {
        print("Error loading restaurants: $e");
      }

      print("Total items loaded: ${allItems.length}");

      // Use a Map to store favorites to prevent duplicates by ID
      final Map<String, Item> favoriteItemsMap = {};

      // Now filter for favorites only
      for (String id in favIds) {
        final item = allItems[id];
        if (item != null) {
          // Mark as favorite
          item.isfavourite = true;
          // Use the ID as key in the map to ensure uniqueness
          favoriteItemsMap[id] = item;
          print("Added to favorites: ${item.name} (ID: $id)");
        } else {
          print("Could not find item with ID: $id in any collection");
        }
      }

      // Convert map values to list
      favourites = favoriteItemsMap.values.toList();

      print("Successfully loaded ${favourites.length} favourite items");
      emit(FavouriteLoadedState());
    } catch (e) {
      print("Error loading favourites: $e");
      emit(FavouriteErrorState(e.toString()));
    }
  }
}
