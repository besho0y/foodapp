import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/area.dart';
import 'package:foodapp/models/banner.dart' as BannerModel;
import 'package:foodapp/models/city.dart';
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
            print("Areas for ${restaurant.name}: ${restaurant.areas}");
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
    List<String> mainAreas = const [], // Main areas where restaurant is located
    List<String> secondaryAreas =
        const [], // Secondary areas with out-of-area fee
    String? outOfAreaFee,
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
        // New location structure
        'mainAreas': mainAreas,
        'secondaryAreas': secondaryAreas,
        // Keep old structure for backward compatibility
        'area': mainAreas.isNotEmpty ? mainAreas.first : 'Cairo',
        'areas': [...mainAreas, ...secondaryAreas],
        'outOfAreaFee': outOfAreaFee ?? '0',
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

  // Edit existing item in restaurant
  Future<void> editItem({
    required String restaurantId,
    required String itemId,
    required String name,
    required String nameAr,
    required String description,
    required String descriptionAr,
    required double price,
    required String category,
    required List<String> categories,
    File? imageFile,
  }) async {
    emit(AddingItemState()); // Use same state as adding for consistency
    try {
      print("Editing item: $itemId ($name) in restaurant: $restaurantId");

      // Get current item data to preserve existing image if no new image is uploaded
      final currentItemDoc = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("items")
          .doc(itemId)
          .get();

      if (!currentItemDoc.exists) {
        throw Exception("Item not found in the database");
      }

      final currentData = currentItemDoc.data() as Map<String, dynamic>;
      String imageUrl = currentData['img'] ??
          'assets/images/items/default.jpg'; // Keep existing image as default

      // Upload new image if provided
      if (imageFile != null) {
        print("Uploading new item image...");
        try {
          String uploadedImageUrl = await uploadImage(imageFile, 'items');
          if (uploadedImageUrl.isNotEmpty) {
            imageUrl = uploadedImageUrl;
            print("New item image uploaded successfully: $imageUrl");
          } else {
            print(
                "New item image upload returned empty URL, keeping existing image");
          }
        } catch (e) {
          print("Error uploading new item image: $e");
          // Continue with existing image URL
        }
      } else {
        print("No new image file provided for item, keeping existing image");
      }

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

      // Update item data
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .collection("items")
          .doc(itemId)
          .update({
        'name': name,
        'namear': nameAr,
        'description': description,
        'descriptionar': descriptionAr,
        'price': price,
        'img': imageUrl,
        'category': category,
        'categories': itemCategories,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print("Item data updated in Firestore with image URL: $imageUrl");

      await getRestaurants(); // Refresh restaurants list
      emit(
          SuccessAddingItemState()); // Use same success state as adding for consistency
    } catch (e) {
      print("Error editing item: $e");
      emit(ErrorAddingItemState(
          e.toString())); // Use same error state as adding for consistency
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

  // Edit a menu category
  Future<void> editMenuCategory({
    required String restaurantId,
    required String oldCategoryName,
    required String newCategoryName,
    required String newCategoryNameAr,
    String? categoryId,
  }) async {
    emit(EditingMenuCategoryState());
    try {
      // Don't allow editing the "All" category
      if (oldCategoryName == "All") {
        emit(ErrorEditingMenuCategoryState("Cannot edit the 'All' category"));
        return;
      }

      // Check if new category name already exists (if it's different from old name)
      if (oldCategoryName != newCategoryName) {
        final existingCategorySnapshot = await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(restaurantId)
            .collection("menu_categories")
            .where("name", isEqualTo: newCategoryName)
            .get();

        if (existingCategorySnapshot.docs.isNotEmpty) {
          emit(ErrorEditingMenuCategoryState(
              "Category '$newCategoryName' already exists"));
          return;
        }
      }

      // Update subcollection first
      if (categoryId != null && categoryId.isNotEmpty) {
        // Update using the category ID
        await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(restaurantId)
            .collection("menu_categories")
            .doc(categoryId)
            .update({
          'name': newCategoryName,
          'nameAr': newCategoryNameAr,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print("Updated category document $categoryId in subcollection");
      } else {
        // Find and update by name
        final categorySnapshot = await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(restaurantId)
            .collection("menu_categories")
            .where("name", isEqualTo: oldCategoryName)
            .get();

        for (var doc in categorySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection("restaurants")
              .doc(restaurantId)
              .collection("menu_categories")
              .doc(doc.id)
              .update({
            'name': newCategoryName,
            'nameAr': newCategoryNameAr,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print("Updated category document ${doc.id} in subcollection");
        }
      }

      // For backward compatibility, also update the menuCategories array
      final restaurantDoc = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .get();

      if (restaurantDoc.exists) {
        final data = restaurantDoc.data();
        List<String> menuCategories =
            List<String>.from(data?['menuCategories'] ?? []);
        List<String> menuCategoriesAr =
            List<String>.from(data?['menuCategoriesAr'] ?? []);

        // Update category if it exists in the array
        if (menuCategories.contains(oldCategoryName)) {
          int index = menuCategories.indexOf(oldCategoryName);
          menuCategories[index] = newCategoryName;

          // Also update the corresponding Arabic category if it exists
          if (index < menuCategoriesAr.length) {
            menuCategoriesAr[index] = newCategoryNameAr;
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

        // Update all items with the old category name
        if (oldCategoryName != newCategoryName) {
          final itemsSnapshot = await FirebaseFirestore.instance
              .collection("restaurants")
              .doc(restaurantId)
              .collection("items")
              .where("category", isEqualTo: oldCategoryName)
              .get();

          print(
              "Found ${itemsSnapshot.docs.length} items with category '$oldCategoryName'");

          // Update all items to use the new category name
          final batch = FirebaseFirestore.instance.batch();
          for (var doc in itemsSnapshot.docs) {
            batch.update(doc.reference, {'category': newCategoryName});
          }

          // Commit the batch update
          if (itemsSnapshot.docs.isNotEmpty) {
            await batch.commit();
            print(
                "Updated ${itemsSnapshot.docs.length} items to category '$newCategoryName'");
          }
        }
      }

      await getRestaurants();
      emit(SuccessEditingMenuCategoryState());
    } catch (e) {
      print("Error editing menu category: $e");
      emit(ErrorEditingMenuCategoryState(e.toString()));
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

  // Banner methods
  List<BannerModel.Banner> _banners = [];

  List<BannerModel.Banner> get banners => _banners;

  // Fetch all banners from Firestore
  Future<void> fetchBanners() async {
    emit(LoadingBannersState());

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('banners')
          .orderBy('createdAt', descending: true)
          .get();

      final List<BannerModel.Banner> loadedBanners = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;

        // Convert Firestore timestamp to string for the model
        if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }

        return BannerModel.Banner.fromJson(data);
      }).toList();

      _banners =
          loadedBanners.where((banner) => banner.isActive == true).toList();
      emit(SuccessLoadingBannersState());
    } catch (e) {
      print('Error fetching banners: $e');
      emit(ErrorLoadingBannersState(e.toString()));
    }
  }

  // Add a new banner
  Future<void> addBanner({required File imageFile}) async {
    emit(AddingBannerState());

    try {
      // Upload image to Firebase Storage
      String imageUrl = await uploadImage(imageFile, 'banners');

      if (imageUrl.isEmpty) {
        throw Exception('Failed to upload banner image');
      }

      // Save banner data to Firestore
      await FirebaseFirestore.instance.collection('banners').add({
        'imageUrl': imageUrl,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Refresh banners list
      await fetchBanners();
      emit(SuccessAddingBannerState());
    } catch (e) {
      print('Error adding banner: $e');
      emit(ErrorAddingBannerState(e.toString()));
    }
  }

  // Delete a banner
  Future<void> deleteBanner(String bannerId) async {
    emit(DeletingBannerState());

    try {
      await FirebaseFirestore.instance
          .collection('banners')
          .doc(bannerId)
          .delete();

      // Refresh banners list
      await fetchBanners();
      emit(SuccessDeletingBannerState());
    } catch (e) {
      print('Error deleting banner: $e');
      emit(ErrorDeletingBannerState(e.toString()));
    }
  }

  // Cities methods
  List<City> _cities = [];

  List<City> get cities => _cities;

  // Fetch all cities from Firestore
  Future<void> fetchCities() async {
    emit(LoadingCitiesState());

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('cities')
          .orderBy('createdAt', descending: true)
          .get();

      final List<City> loadedCities = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;

        // Convert Firestore timestamp to string for the model
        if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }

        return City.fromJson(data);
      }).toList();

      _cities = loadedCities;
      emit(SuccessLoadingCitiesState());
    } catch (e) {
      print('Error fetching cities: $e');
      emit(ErrorLoadingCitiesState(e.toString()));
    }
  }

  // Add a new city
  Future<void> addCity({
    required String name,
    required String nameAr,
  }) async {
    emit(AddingCityState());

    try {
      await FirebaseFirestore.instance.collection('cities').add({
        'name': name,
        'nameAr': nameAr,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Refresh cities list
      await fetchCities();
      emit(SuccessAddingCityState());
    } catch (e) {
      print('Error adding city: $e');
      emit(ErrorAddingCityState(e.toString()));
    }
  }

  // Delete a city
  Future<void> deleteCity(String cityId) async {
    emit(DeletingCityState());

    try {
      // First delete all areas in this city
      final areasSnapshot = await FirebaseFirestore.instance
          .collection('cities')
          .doc(cityId)
          .collection('areas')
          .get();

      for (var doc in areasSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('cities')
            .doc(cityId)
            .collection('areas')
            .doc(doc.id)
            .delete();
      }

      // Then delete the city document
      await FirebaseFirestore.instance
          .collection('cities')
          .doc(cityId)
          .delete();

      // Refresh cities list
      await fetchCities();
      emit(SuccessDeletingCityState());
    } catch (e) {
      print('Error deleting city: $e');
      emit(ErrorDeletingCityState(e.toString()));
    }
  }

  // Areas methods
  List<Area> _areas = [];
  final List<Area> _allAreas = []; // All areas from all cities

  List<Area> get areas => _areas;
  List<Area> get allAreas => _allAreas;

  // Fetch all areas for a specific city
  Future<void> fetchAreas(String cityId) async {
    emit(LoadingAreasState());

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('cities')
          .doc(cityId)
          .collection('areas')
          .orderBy('createdAt', descending: true)
          .get();

      final List<Area> loadedAreas = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        data['cityId'] = cityId;

        // Convert Firestore timestamp to string for the model
        if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
          data['createdAt'] =
              (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }

        return Area.fromJson(data);
      }).toList();

      _areas = loadedAreas;
      emit(SuccessLoadingAreasState());
    } catch (e) {
      print('Error fetching areas: $e');
      emit(ErrorLoadingAreasState(e.toString()));
    }
  }

  // Fetch ALL areas from ALL cities for restaurant delivery coverage
  Future<void> fetchAllAreas() async {
    emit(LoadingAreasState());

    try {
      print('🔄 Fetching all areas from all cities...');
      _allAreas.clear();

      // Get all cities first
      if (cities.isEmpty) {
        print('🏙️ No cities loaded, fetching cities first...');
        await fetchCities();
      }

      print('🏙️ Found ${cities.length} cities to check for areas');

      if (cities.isEmpty) {
        print('❌ No cities found! Cannot load areas.');
        emit(ErrorLoadingAreasState(
            'No cities found. Please add cities first.'));
        return;
      }

      // Fetch areas from each city
      for (var city in cities) {
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('cities')
              .doc(city.id)
              .collection('areas')
              .orderBy('createdAt', descending: true)
              .get();

          final List<Area> cityAreas = snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            data['cityId'] = city.id;

            // Convert Firestore timestamp to string for the model
            if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
              data['createdAt'] =
                  (data['createdAt'] as Timestamp).toDate().toIso8601String();
            }

            return Area.fromJson(data);
          }).toList();

          _allAreas.addAll(cityAreas);
          print('✅ Loaded ${cityAreas.length} areas from ${city.name}');
        } catch (e) {
          print('❌ Error fetching areas from city ${city.name}: $e');
        }
      }

      // Sort all areas by city name then area name
      _allAreas.sort((a, b) {
        final cityA = cities.firstWhere((city) => city.id == a.cityId).name;
        final cityB = cities.firstWhere((city) => city.id == b.cityId).name;
        final cityComparison = cityA.compareTo(cityB);
        if (cityComparison != 0) return cityComparison;
        return a.name.compareTo(b.name);
      });

      print('🎉 Successfully loaded ${_allAreas.length} areas from all cities');
      emit(SuccessLoadingAreasState());
    } catch (e) {
      print('❌ Error fetching all areas: $e');
      emit(ErrorLoadingAreasState(e.toString()));
    }
  }

  // Add a new area to a city
  Future<void> addArea({
    required String cityId,
    required String name,
    required String nameAr,
  }) async {
    emit(AddingAreaState());

    try {
      await FirebaseFirestore.instance
          .collection('cities')
          .doc(cityId)
          .collection('areas')
          .add({
        'name': name,
        'nameAr': nameAr,
        'cityId': cityId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Refresh areas list
      await fetchAreas(cityId);
      emit(SuccessAddingAreaState());
    } catch (e) {
      print('Error adding area: $e');
      emit(ErrorAddingAreaState(e.toString()));
    }
  }

  // Delete an area
  Future<void> deleteArea(String cityId, String areaId) async {
    emit(DeletingAreaState());

    try {
      await FirebaseFirestore.instance
          .collection('cities')
          .doc(cityId)
          .collection('areas')
          .doc(areaId)
          .delete();

      // Refresh areas list
      await fetchAreas(cityId);
      emit(SuccessDeletingAreaState());
    } catch (e) {
      print('Error deleting area: $e');
      emit(ErrorDeletingAreaState(e.toString()));
    }
  }

  // Method to fix existing restaurants with area IDs instead of area names
  Future<void> fixRestaurantAreas() async {
    emit(LoadingRestaurantsState());

    try {
      print("🔧 Starting to fix restaurant areas...");

      // Get all restaurants
      final restaurantsSnapshot =
          await FirebaseFirestore.instance.collection("restaurants").get();

      // Get all cities and areas for mapping
      await fetchCities();

      int fixedCount = 0;

      for (var doc in restaurantsSnapshot.docs) {
        try {
          final data = doc.data();
          final areas = data['areas'] as List<dynamic>?;

          if (areas != null && areas.isNotEmpty) {
            List<String> areaNames = [];
            bool needsUpdate = false;

            for (String areaIdOrName in areas.cast<String>()) {
              // Check if this looks like an area ID (long random string)
              if (areaIdOrName.length > 10 && !areaIdOrName.contains(' ')) {
                // This looks like an ID, try to find the corresponding area name
                String? areaName = await _findAreaNameById(areaIdOrName);
                if (areaName != null) {
                  areaNames.add(areaName);
                  needsUpdate = true;
                  print("  Fixed: ID '$areaIdOrName' -> Name '$areaName'");
                } else {
                  // Keep the original if we can't find a match
                  areaNames.add(areaIdOrName);
                  print(
                      "  Warning: Could not find area name for ID '$areaIdOrName'");
                }
              } else {
                // This already looks like a name, keep it
                areaNames.add(areaIdOrName);
              }
            }

            // Update the restaurant if needed
            if (needsUpdate) {
              await FirebaseFirestore.instance
                  .collection("restaurants")
                  .doc(doc.id)
                  .update({'areas': areaNames});

              fixedCount++;
              print(
                  "✅ Fixed restaurant '${data['resname']}' areas: $areaNames");
            }
          }
        } catch (e) {
          print("❌ Error fixing restaurant ${doc.id}: $e");
        }
      }

      print("🎉 Fixed $fixedCount restaurants");

      // Refresh restaurants list
      await getRestaurants();

      emit(SuccessLoadingRestaurantsState());
    } catch (e) {
      print("💥 Error fixing restaurant areas: $e");
      emit(ErrorLoadingRestaurantsState(e.toString()));
    }
  }

  // Helper method to find area name by ID
  Future<String?> _findAreaNameById(String areaId) async {
    try {
      // Search through all cities for this area ID
      for (var city in cities) {
        final areasSnapshot = await FirebaseFirestore.instance
            .collection("cities")
            .doc(city.id)
            .collection("areas")
            .doc(areaId)
            .get();

        if (areasSnapshot.exists) {
          final areaData = areasSnapshot.data();
          return areaData?['name'] as String?;
        }
      }
      return null;
    } catch (e) {
      print("Error finding area name for ID $areaId: $e");
      return null;
    }
  }

  // Edit restaurant method
  Future<void> editRestaurant({
    required String restaurantId,
    required String name,
    required String nameAr,
    required String category,
    required String categoryAr,
    required String deliveryFee,
    required String deliveryTime,
    File? imageFile,
    required List<String> categories,
    String area = 'Cairo',
    List<String> areas = const [],
    List<String> mainAreas = const [],
    List<String> secondaryAreas = const [],
    String? locationCityId,
    String? locationCityName,
    String? locationAreaId,
    String? locationAreaName,
    String? outOfAreaFee,
  }) async {
    emit(AddingRestaurantState()); // Reuse the same loading state

    try {
      print("🔄 Starting restaurant edit for ID: $restaurantId");

      String imageUrl = '';
      bool imageUploadSuccess = false;

      // Handle image upload if a new image is provided
      if (imageFile != null) {
        print("📷 New image provided, uploading...");
        try {
          imageUrl = await uploadImage(imageFile, 'restaurants');
          imageUploadSuccess = imageUrl.isNotEmpty;
          print("✅ Image upload success: $imageUploadSuccess");
          print("🔗 New image URL: $imageUrl");
        } catch (e) {
          print("❌ Image upload failed: $e");
          emit(ErrorAddingRestaurantState("Image upload failed: $e"));
          return;
        }
      } else {
        // Keep existing image - get it from current restaurant data
        try {
          final existingRestaurant = restaurants.firstWhere(
            (r) => r.id == restaurantId,
            orElse: () => throw Exception("Restaurant not found"),
          );
          imageUrl = existingRestaurant.img;
          imageUploadSuccess = true;
          print("📷 Keeping existing image: $imageUrl");
        } catch (e) {
          print("⚠️ Could not find existing restaurant, using default image");
          imageUrl = 'assets/images/restuarants/store.jpg';
          imageUploadSuccess = true;
        }
      }

      // Prepare updated restaurant data
      final Map<String, dynamic> restaurantData = {
        'resname': name,
        'namear': nameAr,
        'category': category,
        'categoryar': categoryAr,
        'delivery fee': deliveryFee,
        'delivery time': deliveryTime,
        'img': imageUrl,
        'categories': categories,
        'area': area,
        'areas': areas.isNotEmpty ? areas : [area],
        'mainAreas': mainAreas.isNotEmpty ? mainAreas : [area],
        'secondaryAreas': secondaryAreas,
        'locationCityId': locationCityId,
        'locationCityName': locationCityName,
        'locationAreaId': locationAreaId,
        'locationAreaName': locationAreaName,
        'outOfAreaFee': outOfAreaFee ?? '0',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print("💾 Updating restaurant data in Firestore...");
      print("📊 Restaurant data preview:");
      print("   Name: $name");
      print("   Category: $category");
      print("   Image URL: $imageUrl");
      print("   Areas: $areas");

      // Update restaurant data in Firestore
      await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(restaurantId)
          .update(restaurantData);

      print("✅ Restaurant data updated in Firestore successfully!");

      // Refresh restaurants list
      print("🔄 Refreshing restaurants list...");
      await getRestaurants();

      print("=== RESTAURANT EDITED SUCCESSFULLY ===");
      emit(SuccessAddingRestaurantState()); // Reuse the same success state
    } catch (e) {
      print("💥 Error editing restaurant: $e");
      emit(ErrorAddingRestaurantState(e.toString()));
    }
  }

  // Edit restaurant category method
  Future<void> editRestaurantCategory({
    required String categoryId,
    required String englishName,
    required String arabicName,
    File? imageFile,
  }) async {
    emit(AddingCategoryState()); // Reuse the same loading state

    try {
      print("🔄 Starting restaurant category edit for ID: $categoryId");

      String imageUrl = '';

      // Handle image upload if a new image is provided
      if (imageFile != null) {
        print("📷 New image provided, uploading...");
        try {
          imageUrl = await uploadImage(imageFile, 'restaurant_categories');
          print("✅ Image upload successful");
          print("🔗 New image URL: $imageUrl");
        } catch (e) {
          print("❌ Image upload failed: $e");
          emit(ErrorAddingCategoryState("Image upload failed: $e"));
          return;
        }
      } else {
        // Keep existing image - get it from Firestore
        try {
          final doc = await FirebaseFirestore.instance
              .collection('restaurants_categories')
              .doc(categoryId)
              .get();

          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            imageUrl = data['img'] ?? '';
            print("📷 Keeping existing image: $imageUrl");
          }
        } catch (e) {
          print("⚠️ Could not get existing image: $e");
          imageUrl = '';
        }
      }

      // Prepare updated category data
      final Map<String, dynamic> categoryData = {
        'en': englishName,
        'ar': arabicName,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Only update image if we have one
      if (imageUrl.isNotEmpty) {
        categoryData['img'] = imageUrl;
      }

      print("💾 Updating category data in Firestore...");
      print("📊 Category data preview:");
      print("   English: $englishName");
      print("   Arabic: $arabicName");
      print("   Image URL: $imageUrl");

      // Update category data in Firestore
      await FirebaseFirestore.instance
          .collection('restaurants_categories')
          .doc(categoryId)
          .update(categoryData);

      print("✅ Restaurant category updated in Firestore successfully!");
      print("=== RESTAURANT CATEGORY EDITED SUCCESSFULLY ===");
      emit(SuccessAddingCategoryState()); // Reuse the same success state
    } catch (e) {
      print("💥 Error editing restaurant category: $e");
      emit(ErrorAddingCategoryState(e.toString()));
    }
  }
}
