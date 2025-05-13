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

          // Ensure menuCategories is properly loaded from Firestore
          if (data.containsKey('menuCategories')) {
            restaurantData['menuCategories'] = data['menuCategories'];
            print(
                "Loaded menuCategories for restaurant ${doc.id}: ${data['menuCategories']}");
          } else {
            print(
                "No menuCategories field found for restaurant ${doc.id}, initializing empty list");
            restaurantData['menuCategories'] = [];
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

      // Make sure the main category is in the categories list
      if (!categories.contains(category) && category != "All") {
        categories.add(category);
      }

      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("items")
          .doc(itemId)
          .set({
        'name': name,
        'nameAr': nameAr,
        'description': description,
        'descriptionAr': descriptionAr,
        'price': price,
        'img': imageUrl,
        'category': category,
        'categories': categories,
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
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("items")
          .doc(itemId)
          .delete();

      await getRestaurants();
      emit(SuccessDeletingItemState());
    } catch (e) {
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
  }) async {
    emit(AddingMenuCategoryState());
    try {
      // First, let's get the restaurant to check if this menu category already exists
      final restaurantDoc = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .get();

      if (restaurantDoc.exists) {
        // We'll create or update a "menuCategories" field in the restaurant document
        final data = restaurantDoc.data();
        List<String> menuCategories =
            List<String>.from(data?['menuCategories'] ?? []);

        // Add new category if it doesn't exist
        if (!menuCategories.contains(categoryName)) {
          menuCategories.add(categoryName);

          // Update restaurant document
          await FirebaseFirestore.instance
              .collection("restaurants")
              .doc(restaurantId)
              .update({
            'menuCategories': menuCategories,
          });

          print(
              "Added menu category '$categoryName' to restaurant $restaurantId");
        } else {
          print(
              "Menu category '$categoryName' already exists for restaurant $restaurantId");
        }
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

      // First, get the restaurant document
      final restaurantDoc = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .get();

      if (restaurantDoc.exists) {
        // Update the menuCategories list
        final data = restaurantDoc.data();
        List<String> menuCategories =
            List<String>.from(data?['menuCategories'] ?? []);

        // Remove category if it exists
        if (menuCategories.contains(categoryName)) {
          menuCategories.remove(categoryName);

          // Update restaurant document
          await FirebaseFirestore.instance
              .collection("restaurants")
              .doc(restaurantId)
              .update({
            'menuCategories': menuCategories,
          });
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

      // First get the unique categories from this restaurant's menu items
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

      // Make sure to include categories from the restaurant itself
      for (var category in restaurant.categories) {
        if (category != "All") {
          uniqueCategories.add(category);
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
