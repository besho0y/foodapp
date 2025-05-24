import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/promocode.dart';
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
      // Fetch restaurants ordered by creation date (newest first)
      final QuerySnapshot restaurantsSnapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .orderBy('createdAt', descending: true) // Order by newest first
          .get();

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
                .orderBy('createdAt', descending: true) // Order by newest first
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
                .orderBy("createdAt", descending: true) // Order by newest first
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

  // Upload image to Firebase Storage with enhanced logging and crash prevention
  Future<String> uploadImage(File imageFile, String folder) async {
    emit(ImageUploadingState());
    try {
      print("=== STARTING IMAGE UPLOAD ===");
      print("📁 File path: ${imageFile.path}");
      print("📂 Target folder: $folder");

      // Validate file exists and is accessible
      if (!imageFile.existsSync()) {
        throw Exception("File does not exist at path: ${imageFile.path}");
      }

      final fileSize = await imageFile.length();
      print(
          "📏 File size: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)");

      if (fileSize == 0) {
        throw Exception("File is empty (0 bytes)");
      }

      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        throw Exception(
            "File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB. Max: 10MB");
      }

      // Create unique filename with timestamp and random element
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${folder}_$timestamp.jpg';
      final String fullPath = '$folder/$fileName';

      print("🚀 Uploading to: gs://your-bucket/$fullPath");

      // Create Firebase Storage reference
      final Reference ref = FirebaseStorage.instance.ref().child(fullPath);
      print("📌 Storage reference created successfully");

      // Upload with comprehensive metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'max-age=3600',
        customMetadata: {
          'uploaded_by': 'admin_panel',
          'upload_time': DateTime.now().toIso8601String(),
          'original_name': imageFile.path.split('/').last,
          'folder': folder,
        },
      );

      print("⬆️ Starting Firebase upload...");
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);

      // Monitor upload progress with detailed logging
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print(
            '📊 Upload progress: ${(progress * 100).toStringAsFixed(1)}% (${snapshot.bytesTransferred}/${snapshot.totalBytes} bytes)');

        // Log state changes
        switch (snapshot.state) {
          case TaskState.running:
            print("🔄 Upload state: RUNNING");
            break;
          case TaskState.paused:
            print("⏸️ Upload state: PAUSED");
            break;
          case TaskState.success:
            print("✅ Upload state: SUCCESS");
            break;
          case TaskState.canceled:
            print("❌ Upload state: CANCELED");
            break;
          case TaskState.error:
            print("🚨 Upload state: ERROR");
            break;
        }
      });

      // Wait for upload completion
      final TaskSnapshot taskSnapshot = await uploadTask;
      print("✅ Upload task completed successfully");
      print("📊 Final uploaded bytes: ${taskSnapshot.totalBytes}");

      // Get download URL
      print("🔗 Requesting download URL...");
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print("✅ Download URL obtained: $downloadUrl");

      // Verify URL format
      if (!downloadUrl.startsWith('https://')) {
        throw Exception("Invalid download URL format: $downloadUrl");
      }

      emit(SuccessImageUploadingState(downloadUrl));
      print("=== UPLOAD COMPLETED SUCCESSFULLY ===");
      return downloadUrl;
    } on FirebaseException catch (e) {
      print("🚨 Firebase Storage Error:");
      print("   Code: ${e.code}");
      print("   Message: ${e.message}");
      print("   Plugin: ${e.plugin}");

      String userFriendlyMessage;
      switch (e.code) {
        case 'storage/unauthorized':
          userFriendlyMessage =
              "❌ STORAGE RULES ERROR: Upload not authorized. Please check Firebase Storage rules.";
          print("🔧 SOLUTION: Update Firebase Storage rules to allow uploads");
          break;
        case 'storage/canceled':
          userFriendlyMessage = "Upload was canceled";
          break;
        case 'storage/unknown':
          userFriendlyMessage = "Unknown storage error occurred";
          break;
        case 'storage/object-not-found':
          userFriendlyMessage = "File not found in storage";
          break;
        case 'storage/bucket-not-found':
          userFriendlyMessage = "Storage bucket not found";
          break;
        case 'storage/project-not-found':
          userFriendlyMessage = "Firebase project not found";
          break;
        case 'storage/quota-exceeded':
          userFriendlyMessage = "Storage quota exceeded";
          break;
        case 'storage/unauthenticated':
          userFriendlyMessage = "User not authenticated";
          break;
        case 'storage/retry-limit-exceeded':
          userFriendlyMessage = "Upload retry limit exceeded";
          break;
        default:
          userFriendlyMessage = "Firebase Storage Error: ${e.code}";
      }

      print("❌ User message: $userFriendlyMessage");
      emit(ErrorImageUploadingState(userFriendlyMessage));
      return '';
    } catch (e) {
      print("💥 General Upload Error:");
      print("   Type: ${e.runtimeType}");
      print("   Message: $e");
      print("   Stack trace available for debugging");

      String errorMessage = "Upload failed: $e";
      emit(ErrorImageUploadingState(errorMessage));
      return '';
    }
  }

  // Add new restaurant with proper image handling and crash prevention
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
      print("=== ADDING RESTAURANT: $name ===");

      // Upload image first if provided
      String imageUrl =
          'assets/images/restuarants/store.jpg'; // Default fallback
      bool imageUploadSuccess = false;

      if (imageFile != null) {
        print("📸 Image file provided, attempting upload...");
        try {
          // Validate image file before upload
          if (!imageFile.existsSync()) {
            print("⚠️ Image file does not exist, using default image");
          } else {
            final fileSize = await imageFile.length();
            print(
                "📏 Image file size: ${(fileSize / 1024).toStringAsFixed(2)} KB");

            if (fileSize > 0) {
              print("🚀 Starting image upload to 'restaurants' folder...");
              String uploadedImageUrl =
                  await uploadImage(imageFile, 'restaurants');

              if (uploadedImageUrl.isNotEmpty &&
                  uploadedImageUrl.startsWith('https://')) {
                imageUrl = uploadedImageUrl;
                imageUploadSuccess = true;
                print("✅ Restaurant image uploaded successfully!");
                print("🔗 Image URL: $imageUrl");
              } else {
                print(
                    "⚠️ Upload returned empty/invalid URL, using default image");
              }
            } else {
              print("⚠️ Image file is empty, using default image");
            }
          }
        } catch (e) {
          print("❌ Error uploading restaurant image: $e");
          print(
              "🔄 Continuing with default image to prevent restaurant creation failure");
          // Don't throw here - continue with default image
        }
      } else {
        print("📷 No image file provided, using default image");
      }

      // Generate unique restaurant ID
      final String restaurantId = const Uuid().v4();
      print("🆔 Creating restaurant with ID: $restaurantId");

      // Prepare restaurant data
      final Map<String, dynamic> restaurantData = {
        'resname': name,
        'namear': nameAr,
        'category': category,
        'categoryar': categoryAr,
        'delivery fee': deliveryFee,
        'delivery time': deliveryTime,
        'img':
            imageUrl, // This is crucial - save the image URL (uploaded or default)
        'rating': 0.0,
        'ordersnumber': 0,
        'categories': categories,
        'menuCategories': ['All', 'Uncategorized'], // Default menu categories
        'menuCategoriesAr': [
          'الكل',
          'غير مصنف'
        ], // Default Arabic menu categories
        'createdAt': FieldValue.serverTimestamp(),
      };

      print("💾 Saving restaurant data to Firestore...");
      print("📊 Restaurant data preview:");
      print("   Name: $name");
      print("   Category: $category");
      print("   Image URL: $imageUrl");
      print("   Upload Success: $imageUploadSuccess");

      // Save restaurant data to Firestore
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .set(restaurantData);

      print("✅ Restaurant data saved to Firestore successfully!");

      // Refresh restaurants list
      print("🔄 Refreshing restaurants list...");
      await getRestaurants();

      print("=== RESTAURANT ADDED SUCCESSFULLY ===");
      emit(SuccessAddingRestaurantState());
    } catch (e) {
      print("💥 ERROR ADDING RESTAURANT:");
      print("   Type: ${e.runtimeType}");
      print("   Message: $e");

      // Check if it's a Firestore error
      if (e is FirebaseException) {
        print("🔥 Firebase Error Details:");
        print("   Code: ${e.code}");
        print("   Message: ${e.message}");
        print("   Plugin: ${e.plugin}");
      }

      print("=== RESTAURANT ADDITION FAILED ===");
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

  // Add item to restaurant with proper image handling
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
      print("Adding item: $name to restaurant: $restaurantId");

      // Upload image first if provided
      String imageUrl = 'assets/images/items/default.jpg'; // Default fallback

      if (imageFile != null) {
        print("Uploading item image...");
        try {
          String uploadedImageUrl = await uploadImage(imageFile, 'items');
          if (uploadedImageUrl.isNotEmpty) {
            imageUrl = uploadedImageUrl;
            print("Item image uploaded successfully: $imageUrl");
          } else {
            print("Item image upload returned empty URL, using default");
          }
        } catch (e) {
          print("Error uploading item image: $e");
          // Continue with default image URL
        }
      } else {
        print("No image file provided for item, using default image");
      }

      final String itemId = const Uuid().v4();
      print("Creating item with ID: $itemId");

      // Create a categories array that includes the main category and "All"
      final List<String> itemCategories = ["All"];

      // Add the main category if it's not "All" and not already included
      if (category != "All" && !itemCategories.contains(category)) {
        itemCategories.add(category);
      }

      // Add any additional categories
      for (String cat in categories) {
        if (!itemCategories.contains(cat)) {
          itemCategories.add(cat);
        }
      }

      // Save item data with image URL
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
        'img': imageUrl, // This is crucial - save the uploaded image URL
        'category': category,
        'categories': itemCategories,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Item data saved to Firestore with image URL: $imageUrl");

      await getRestaurants(); // Refresh restaurants list
      emit(SuccessAddingItemState());
    } catch (e) {
      print("Error adding item: $e");
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
    required String categoryNameAr,
    required String img, // require image path or url
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
          'nameAr': categoryNameAr,
          'img': img,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print(
            "Added menu category '$categoryName' to restaurant $restaurantId subcollection");
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

  // Helper to get display name for a category map
  String getDisplayCategoryName(
      Map<String, dynamic> category, BuildContext context) {
    bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return isRtl
        ? (category['nameAr'] ?? category['name'])
        : (category['name'] ?? category['nameAr']);
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

  // Promocode methods
  List<Promocode> _promocodes = [];

  List<Promocode> get promocodes => _promocodes;

  // Fetch all promocodes from Firestore
  Future<void> fetchPromocodes() async {
    emit(LoadingPromocodesState());

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('promocodes').get();

      final List<Promocode> loadedPromocodes = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        // Make sure code is included (it's the document ID)
        data['code'] = doc.id;
        return Promocode.fromJson(data);
      }).toList();

      _promocodes = loadedPromocodes;
      emit(SuccessLoadingPromocodesState(_promocodes));
    } catch (e) {
      print('Error fetching promocodes: $e');
      emit(ErrorLoadingPromocodesState(e.toString()));
    }
  }

  // Add a new promocode
  Future<void> addPromocode(
      {required String code, required double discount}) async {
    emit(AddingPromocodeState());

    try {
      await FirebaseFirestore.instance.collection('promocodes').doc(code).set({
        'discount': discount,
        'usageCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Refresh promocodes list
      await fetchPromocodes();
      emit(SuccessAddingPromocodeState());
    } catch (e) {
      print('Error adding promocode: $e');
      emit(ErrorAddingPromocodeState(e.toString()));
    }
  }

  // Delete a promocode
  Future<void> deletePromocode(String code) async {
    emit(DeletingPromocodeState());

    try {
      await FirebaseFirestore.instance
          .collection('promocodes')
          .doc(code)
          .delete();

      // Refresh promocodes list
      await fetchPromocodes();
      emit(SuccessDeletingPromocodeState());
    } catch (e) {
      print('Error deleting promocode: $e');
      emit(ErrorDeletingPromocodeState(e.toString()));
    }
  }

  // Add restaurant category with image upload
  Future<void> addRestaurantCategory({
    required String englishName,
    required String arabicName,
    File? imageFile,
  }) async {
    emit(AddingCategoryState());
    try {
      print("Adding restaurant category: $englishName");

      // Upload image first if provided
      String imageUrl = 'assets/images/categories/all.png'; // Default fallback

      if (imageFile != null) {
        print("Uploading restaurant category image...");
        try {
          String uploadedImageUrl =
              await uploadImage(imageFile, 'restaurant_categories');
          if (uploadedImageUrl.isNotEmpty) {
            imageUrl = uploadedImageUrl;
            print("Restaurant category image uploaded successfully: $imageUrl");
          } else {
            print(
                "Restaurant category image upload returned empty URL, using default");
          }
        } catch (e) {
          print("Error uploading restaurant category image: $e");
          // Continue with default image URL
        }
      } else {
        print(
            "No image file provided for restaurant category, using default image");
      }

      // Save restaurant category data with image URL
      await FirebaseFirestore.instance
          .collection('restaurants_categories')
          .add({
        'en': englishName,
        'ar': arabicName,
        'img': imageUrl, // This is crucial - save the uploaded image URL
        'createdAt': FieldValue.serverTimestamp(),
      });

      print(
          "Restaurant category data saved to Firestore with image URL: $imageUrl");

      emit(SuccessAddingCategoryState());
    } catch (e) {
      print("Error adding restaurant category: $e");
      emit(ErrorAddingCategoryState(e.toString()));
    }
  }
}
