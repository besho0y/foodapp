import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/resturant.dart';
import 'package:foodapp/screens/admin%20panel/states.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AdminPanelCubit extends Cubit<AdminPanelStates> {
  AdminPanelCubit() : super(AdminPanelInitialState());

  static AdminPanelCubit get(context) => BlocProvider.of(context);

  List<Restuarants> restaurants = [];

  // Load all restaurants
  Future<void> getRestaurants() async {
    emit(LoadingRestaurantsState());
    try {
      final QuerySnapshot restaurantsSnapshot =
          await FirebaseFirestore.instance.collection("restaurants").get();

      restaurants = [];
      print(
          "Found ${restaurantsSnapshot.docs.length} restaurants in Firestore");

      if (restaurantsSnapshot.docs.isEmpty) {
        print("No restaurant documents found in Firestore");
        emit(SuccessLoadingRestaurantsState());
        return;
      }

      for (var doc in restaurantsSnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          print("Restaurant document ID: ${doc.id}");
          print("Restaurant data: $data");

          // Create a complete restaurant data object with ID
          final restaurantData = {
            ...data,
            'id': doc.id,
          };

          // Check for required fields
          if (!data.containsKey('resname')) {
            print("Warning: 'resname' field missing in document ${doc.id}");
            restaurantData['resname'] = "Restaurant ${doc.id}";
          }

          // Get items collection for this restaurant
          List<Map<String, dynamic>> itemsList = [];
          try {
            final itemsSnapshot = await FirebaseFirestore.instance
                .collection("restaurants")
                .doc(doc.id)
                .collection("items")
                .get();

            print(
                "Found ${itemsSnapshot.docs.length} items for restaurant ${doc.id}");

            // Process items if they exist
            if (itemsSnapshot.docs.isNotEmpty) {
              for (var itemDoc in itemsSnapshot.docs) {
                final itemData = itemDoc.data();
                itemsList.add({
                  ...itemData,
                  'id': itemDoc.id,
                });
              }
            }
          } catch (e) {
            print("Error fetching items for restaurant ${doc.id}: $e");
          }

          // Add items list to restaurant data
          restaurantData['items'] = itemsList;

          // Fetch menu categories from subcollection
          List<String> menuCategories = [];
          List<String> menuCategoriesAr = [];

          try {
            final categoriesSnapshot = await FirebaseFirestore.instance
                .collection("restaurants")
                .doc(doc.id)
                .collection("menu_categories")
                .orderBy("createdAt",
                    descending: false) // Order by creation date
                .get();

            print(
                "Found ${categoriesSnapshot.docs.length} menu_categories in subcollection for restaurant ${doc.id}");

            if (categoriesSnapshot.docs.isNotEmpty) {
              // Extract the menu categories from subcollection
              for (var categoryDoc in categoriesSnapshot.docs) {
                final categoryData = categoryDoc.data();
                final categoryName = categoryData['name']?.toString();
                final categoryNameAr = categoryData['nameAr']?.toString();

                if (categoryName != null && categoryName.isNotEmpty) {
                  menuCategories.add(categoryName);

                  if (categoryNameAr != null && categoryNameAr.isNotEmpty) {
                    menuCategoriesAr.add(categoryNameAr);
                  } else {
                    // If no Arabic name, use English one to keep arrays in sync
                    menuCategoriesAr.add(categoryName);
                  }
                }
              }

              // Store the menu categories in the restaurant data
              restaurantData['menuCategories'] = menuCategories;
              restaurantData['menuCategoriesAr'] = menuCategoriesAr;

              print(
                  "Loaded menu categories from subcollection for restaurant ${doc.id}: $menuCategories");
              print(
                  "Loaded menu categories (Ar) from subcollection for restaurant ${doc.id}: $menuCategoriesAr");
            }
            // Fall back to array field if subcollection is empty
            else if (data.containsKey('menuCategories')) {
              restaurantData['menuCategories'] = data['menuCategories'];
              print(
                  "Using existing menuCategories array for restaurant ${doc.id}: ${data['menuCategories']}");

              if (data.containsKey('menuCategoriesAr')) {
                restaurantData['menuCategoriesAr'] = data['menuCategoriesAr'];
              }
            } else {
              print(
                  "No menu categories found for restaurant ${doc.id}, initializing empty list");
              restaurantData['menuCategories'] = [];
              restaurantData['menuCategoriesAr'] = [];
            }
          } catch (e) {
            print(
                "Error fetching menu categories for restaurant ${doc.id}: $e");
            // Fall back to array field if subcollection fetch fails
            if (data.containsKey('menuCategories')) {
              restaurantData['menuCategories'] = data['menuCategories'];

              if (data.containsKey('menuCategoriesAr')) {
                restaurantData['menuCategoriesAr'] = data['menuCategoriesAr'];
              }
            } else {
              restaurantData['menuCategories'] = [];
              restaurantData['menuCategoriesAr'] = [];
            }
          }

          // Add the restaurant to our list
          try {
            Restuarants restaurant = Restuarants.fromJson(restaurantData);
            print("Successfully created restaurant object: ${restaurant.name}");
            print(
                "Menu categories for ${restaurant.name}: ${restaurant.menuCategories}");
            restaurants.add(restaurant);
          } catch (e) {
            print("Error creating restaurant object from data: $e");
            print("Problematic data: $restaurantData");
          }
        } catch (e) {
          print("Error processing restaurant document ${doc.id}: $e");
        }
      }

      emit(SuccessLoadingRestaurantsState());
    } catch (e) {
      print("Error loading restaurants: $e");
      emit(ErrorLoadingRestaurantsState(e.toString()));
    }
  }

  // Add new restaurant
  Future<void> addRestaurant({
    required String name,
    required String nameAr,
    required String category,
    required String categoryAr,
    required String deliveryFee,
    required String deliveryTime,
    required File? imageFile,
    required List<String> categories,
  }) async {
    emit(AddingRestaurantState());
    try {
      // Default image path from assets
      String imageUrl = 'assets/images/restuarants/store.jpg';

      // Only attempt to upload an image if one was provided
      if (imageFile != null) {
        try {
          String uploadedImageUrl = await uploadImage(imageFile, 'restaurants');
          if (uploadedImageUrl.isNotEmpty) {
            imageUrl = uploadedImageUrl; // Use uploaded image if successful
          }
        } catch (e) {
          print("Error uploading image: $e");
          // Continue with default image URL
        }
      } else {
        print("Using default image from assets: $imageUrl");
      }

      final String restaurantId = const Uuid().v4();

      print("Adding restaurant with image URL: $imageUrl");

      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .set({
        'resname': name,
        'namear': nameAr,
        'category': category,
        'categoryar': categoryAr,
        'delivery fee': deliveryFee,
        'delivery time': deliveryTime,
        'img': imageUrl,
        'rating': 0.0,
        'ordersnumber': 0,
        'categories': categories,
      });

      await getRestaurants();
      emit(SuccessAddingRestaurantState());
    } catch (e) {
      print("Error adding restaurant: $e");
      emit(ErrorAddingRestaurantState(e.toString()));
    }
  }

  // Delete restaurant
  Future<void> deleteRestaurant(String restaurantId) async {
    emit(DeletingRestaurantState());
    try {
      // Delete all items in the restaurant first
      final itemsSnapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("items")
          .get();

      for (var doc in itemsSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(restaurantId)
            .collection("items")
            .doc(doc.id)
            .delete();
      }

      // Delete restaurant document
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .delete();

      await getRestaurants();
      emit(SuccessDeletingRestaurantState());
    } catch (e) {
      emit(ErrorDeletingRestaurantState(e.toString()));
    }
  }

  // Add item to restaurant
  Future<void> addItem({
    required String restaurantId,
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required double price,
    required String category,
    required List<String> categories,
    File? imageFile,
  }) async {
    emit(AddingItemState());
    try {
      String imageUrl = '';
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile, 'items');
      }

      final String itemId = const Uuid().v4();

      // Create a categories array that includes the main category and "All"
      final List<String> itemCategories = ["All"];

      // Add the main category if it's not "All" and not already included
      if (category != "All" && !itemCategories.contains(category)) {
        itemCategories.add(category);
      }

      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("items")
          .doc(itemId)
          .set({
        'name': name,
        'namear': nameAr,
        'description': description,
        'descriptionar': descriptionAr,
        'price': price,
        'img': imageUrl,
        'category': category,
        'categories': itemCategories,
      });

      await getRestaurants();
      emit(SuccessAddingItemState());
    } catch (e) {
      emit(ErrorAddingItemState(e.toString()));
    }
  }

  // Delete item from restaurant
  Future<void> deleteItem({
    required String restaurantId,
    required String itemId,
  }) async {
    emit(DeletingItemState());
    try {
      print(
          "Attempting to delete item with ID: $itemId from restaurant: $restaurantId");

      // First check if the document exists
      final docSnapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("items")
          .doc(itemId)
          .get();

      if (!docSnapshot.exists) {
        print(
            "Item document with ID $itemId does not exist in restaurant $restaurantId");
        throw Exception("Item not found in the database");
      }

      // Delete the document
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("items")
          .doc(itemId)
          .delete();

      print(
          "Item with ID: $itemId successfully deleted from restaurant: $restaurantId");

      // Refresh restaurants list
      await getRestaurants();
      emit(SuccessDeletingItemState());
    } catch (e) {
      print(
          "Error deleting item with ID: $itemId from restaurant: $restaurantId - Error: $e");
      emit(ErrorDeletingItemState(e.toString()));
    }
  }

  // Add category to restaurant
  Future<void> addCategory({
    required String restaurantId,
    required String categoryName,
  }) async {
    emit(AddingCategoryState());
    try {
      // Get current restaurant data
      final restaurantDoc = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .get();

      if (restaurantDoc.exists) {
        final data = restaurantDoc.data();
        List<String> categories = List<String>.from(data?['categories'] ?? []);

        // Add new category if it doesn't exist
        if (!categories.contains(categoryName)) {
          categories.add(categoryName);

          // Update restaurant document
          await FirebaseFirestore.instance
              .collection("restaurants")
              .doc(restaurantId)
              .update({
            'categories': categories,
          });
        }
      }

      await getRestaurants();
      emit(SuccessAddingCategoryState());
    } catch (e) {
      emit(ErrorAddingCategoryState(e.toString()));
    }
  }

  // Delete category from restaurant
  Future<void> deleteCategory({
    required String restaurantId,
    required String categoryName,
  }) async {
    emit(DeletingCategoryState());
    try {
      // Get current restaurant data
      final restaurantDoc = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .get();

      if (restaurantDoc.exists) {
        final data = restaurantDoc.data();
        List<String> categories = List<String>.from(data?['categories'] ?? []);

        // Remove category if it exists
        categories.remove(categoryName);

        // Update restaurant document
        await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(restaurantId)
            .update({
          'categories': categories,
        });
      }

      await getRestaurants();
      emit(SuccessDeletingCategoryState());
    } catch (e) {
      emit(ErrorDeletingCategoryState(e.toString()));
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String folder) async {
    emit(ImageUploadingState());
    try {
      // Ensure the file exists and is valid
      if (!imageFile.existsSync()) {
        throw Exception("File does not exist");
      }

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref =
          FirebaseStorage.instance.ref().child('$folder/$fileName');

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      emit(SuccessImageUploadingState(downloadUrl));
      return downloadUrl;
    } catch (e) {
      print("Error in uploadImage: $e");
      emit(ErrorImageUploadingState(e.toString()));
      return '';
    }
  }

  // Pick image from gallery
  Future<File?> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print("Error picking image: $e");
      // Here we return null instead of throwing an exception to gracefully handle errors
      return null;
    }
  }

  // Add a new menu category for a restaurant
  Future<void> addMenuCategory({
    required String restaurantId,
    required String categoryName,
    String? categoryNameAr,
  }) async {
    emit(AddingMenuCategoryState());
    try {
      // First check if this menu category already exists in the subcollection
      final categorySnapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("menu_categories")
          .where("name", isEqualTo: categoryName)
          .get();

      if (categorySnapshot.docs.isEmpty) {
        // Add category to the menu_categories subcollection
        await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(restaurantId)
            .collection("menu_categories")
            .add({
          'name': categoryName,
          'namear': categoryNameAr ?? categoryName,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print(
            "Added menu category '$categoryName' to restaurant $restaurantId subcollection");

        // For backward compatibility, also update the menuCategories array
        // But first fetch current values
        final restaurantDoc = await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(restaurantId)
            .get();

        if (restaurantDoc.exists) {
          // Update the menuCategories list in the main restaurant document (for backward compatibility)
          final data = restaurantDoc.data();
          List<String> menuCategories =
              List<String>.from(data?['menuCategories'] ?? []);
          List<String> menuCategoriesAr =
              List<String>.from(data?['menuCategoriesAr'] ?? []);

          // Add new category if it doesn't exist in the array
          if (!menuCategories.contains(categoryName)) {
            menuCategories.add(categoryName);

            // Add Arabic category name, or use English one if not provided
            if (categoryNameAr != null && categoryNameAr.isNotEmpty) {
              // Make sure the Arabic categories list is in sync with the English one
              if (menuCategoriesAr.length < menuCategories.length - 1) {
                // Fill in any missing entries with English values
                while (menuCategoriesAr.length < menuCategories.length - 1) {
                  menuCategoriesAr.add(menuCategories[menuCategoriesAr.length]);
                }
              }
              menuCategoriesAr.add(categoryNameAr);
            } else if (menuCategoriesAr.isNotEmpty) {
              // If no Arabic name provided but we have some Arabic categories already,
              // add the English name to keep arrays in sync
              menuCategoriesAr.add(categoryName);
            }

            // Update restaurant document
            final updateData = {
              'menuCategories': menuCategories,
            };

            // Only add Arabic categories if we have them
            if (menuCategoriesAr.isNotEmpty) {
              updateData['menuCategoriesAr'] = menuCategoriesAr;
            }

            await FirebaseFirestore.instance
                .collection("restaurants")
                .doc(restaurantId)
                .update(updateData);

            print(
                "Also updated menuCategories array for backward compatibility");
          }
        }
      } else {
        print(
            "Menu category '$categoryName' already exists for restaurant $restaurantId");
      }

      await getRestaurants();
      emit(SuccessAddingMenuCategoryState());
    } catch (e) {
      print("Error adding menu category: $e");
      emit(ErrorAddingMenuCategoryState(e.toString()));
    }
  }

  // Delete a menu category and update all affected items
  Future<void> deleteMenuCategory({
    required String restaurantId,
    required String categoryName,
  }) async {
    emit(DeletingMenuCategoryState());
    try {
      // Don't allow deleting the "All" category
      if (categoryName == "All") {
        emit(
            ErrorDeletingMenuCategoryState("Cannot delete the 'All' category"));
        return;
      }

      // First delete from subcollection
      final categorySnapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("menu_categories")
          .where("name", isEqualTo: categoryName)
          .get();

      // Delete all matching subcollection documents
      for (var doc in categorySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(restaurantId)
            .collection("menu_categories")
            .doc(doc.id)
            .delete();

        print("Deleted category document ${doc.id} from subcollection");
      }

      // For backward compatibility, also update the menuCategories array
      final restaurantDoc = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .get();

      if (restaurantDoc.exists) {
        // Update the menuCategories list
        final data = restaurantDoc.data();
        List<String> menuCategories =
            List<String>.from(data?['menuCategories'] ?? []);
        List<String> menuCategoriesAr =
            List<String>.from(data?['menuCategoriesAr'] ?? []);

        // Remove category if it exists
        if (menuCategories.contains(categoryName)) {
          int index = menuCategories.indexOf(categoryName);
          menuCategories.remove(categoryName);

          // Also remove the corresponding Arabic category if it exists
          if (index < menuCategoriesAr.length) {
            menuCategoriesAr.removeAt(index);
          }

          // Update restaurant document
          final updateData = {
            'menuCategories': menuCategories,
          };

          if (menuCategoriesAr.isNotEmpty) {
            updateData['menuCategoriesAr'] = menuCategoriesAr;
          }

          await FirebaseFirestore.instance
              .collection("restaurants")
              .doc(restaurantId)
              .update(updateData);

          print("Updated menuCategories array for backward compatibility");
        }

        // Now update all items with this category
        final itemsSnapshot = await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(restaurantId)
            .collection("items")
            .where("category", isEqualTo: categoryName)
            .get();

        print(
            "Found ${itemsSnapshot.docs.length} items with category '$categoryName'");

        // Update all items to use "Uncategorized" instead
        final batch = FirebaseFirestore.instance.batch();
        for (var doc in itemsSnapshot.docs) {
          batch.update(doc.reference, {'category': 'Uncategorized'});
        }

        // Commit the batch update
        if (itemsSnapshot.docs.isNotEmpty) {
          await batch.commit();
          print(
              "Updated ${itemsSnapshot.docs.length} items to category 'Uncategorized'");
        }
      }

      await getRestaurants();
      emit(SuccessDeletingMenuCategoryState());
    } catch (e) {
      print("Error deleting menu category: $e");
      emit(ErrorDeletingMenuCategoryState(e.toString()));
    }
  }

  // Get menu categories for a restaurant
  List<String> getMenuCategoriesForRestaurant(String restaurantId) {
    try {
      // Find the restaurant
      final restaurant = restaurants.firstWhere(
        (r) => r.id == restaurantId,
        orElse: () => throw Exception('Restaurant not found'),
      );

      // This method will be called from the UI, so we need to return what's already loaded
      // in the restaurants list. The actual loading from subcollection happens in getRestaurants()

      // First try the menuCategories field which should be populated from subcollection
      if (restaurant.menuCategories != null &&
          restaurant.menuCategories!.isNotEmpty) {
        // Always include "All" as the first category
        return ["All", ...restaurant.menuCategories!.where((c) => c != "All")];
      }

      // Fallback to getting categories from items if menuCategories is null or empty
      final uniqueCategories = <String>{};
      for (var item in restaurant.menuItems) {
        if (item.category.isNotEmpty && item.category != "Uncategorized") {
          uniqueCategories.add(item.category);
        }

        // Also add categories from the new multiple categories field
        if (item.categories.isNotEmpty) {
          for (var category in item.categories) {
            if (category != "All" && category != "Uncategorized") {
              uniqueCategories.add(category);
            }
          }
        }
      }

      // Return with "All" as the first category and make sure list is unique
      return ["All", ...uniqueCategories.toList()];
    } catch (e) {
      print("Error getting categories for restaurant: $e");
      return ["All"]; // Return at least the "All" category
    }
  }
}
