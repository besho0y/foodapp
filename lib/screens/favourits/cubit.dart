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
          // Store the complete item data in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('favorite_items')
              .doc(item.id)
              .set({
            'id': item.id,
            'name': item.name,
            'nameAr': item.nameAr,
            'description': item.description,
            'descriptionAr': item.descriptionAr,
            'price': item.price,
            'img': item.img,
            'category': item.category,
            'categoryAr': item.categoryAr,
            'categories': item.categories,
          });
        }
        favourites.add(item);
        emit(FavouriteAddState());
      } else {
        // Remove from favorites
        favIds.removeWhere((id) => id == item.id);
        favourites.removeWhere((i) => i.id == item.id);
        // Also remove the item data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('favorite_items')
            .doc(item.id)
            .delete();
        emit(FavouriteRemoveState());
      }

      // Update Firestore with favorite IDs
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

      // First try to load from favorite_items collection
      for (String id in favIds) {
        try {
          final itemDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('favorite_items')
              .doc(id)
              .get();

          if (itemDoc.exists && itemDoc.data() != null) {
            final data = itemDoc.data()!;
            final item = Item(
              id: data['id'] ?? '',
              name: data['name'] ?? '',
              nameAr: data['nameAr'] ?? '',
              description: data['description'] ?? '',
              descriptionAr: data['descriptionAr'] ?? '',
              price: (data['price'] as num?)?.toDouble() ?? 0.0,
              img: data['img'] ?? '',
              category: data['category'] ?? '',
              categoryAr: data['categoryAr'] ?? '',
              categories: data['categories'] is List
                  ? List<String>.from(data['categories'])
                  : [],
            );
            item.isfavourite = true;
            favourites.add(item);
            continue; // Skip to next item since we found this one
          }
        } catch (e) {
          print("Error loading favorite item $id: $e");
        }

        // If item not found in favorite_items, try restaurants collection
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

              // Store the item data in favorite_items for future use
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .collection('favorite_items')
                  .doc(id)
                  .set({
                'id': item.id,
                'name': item.name,
                'nameAr': item.nameAr,
                'description': item.description,
                'descriptionAr': item.descriptionAr,
                'price': item.price,
                'img': item.img,
                'category': item.category,
                'categoryAr': item.categoryAr,
                'categories': item.categories,
              });

              found = true;
              break;
            }
          }

          if (!found) {
            print("Could not find item with ID: $id in any collection");
          }
        } catch (e) {
          print("Error searching for item $id in restaurants: $e");
        }
      }

      print("Successfully loaded ${favourites.length} favourite items");
      emit(FavouriteLoadedState());
    } catch (e) {
      print("Error loading favourites: $e");
      emit(FavouriteErrorState(e.toString()));
    }
  }
}
