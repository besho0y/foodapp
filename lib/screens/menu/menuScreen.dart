// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/favourits/states.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/screens/reviews/reviewsscreen.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/widgets/itemcard.dart';

class Menuscreen extends StatefulWidget {
  Menuscreen({
    super.key,
    required this.items,
    required this.name,
    required this.img,
    required this.deliverytime,
    required this.deliveryprice,
    required this.restaurantId,
  });

  final List<Item> items;
  final String? name;
  final String img;
  final String deliverytime;
  final String deliveryprice;
  final String restaurantId;

  @override
  State<Menuscreen> createState() => _MenuscreenState();
}

class _MenuscreenState extends State<Menuscreen> {
  // Extract categories specific to this restaurant's items
  late List<String> restaurantCategories = ["All"];
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    // Start with "All" category
    List<String> categoriesList = ["All"];
    Set<String> processedCategories = {"All"};

    // Debug logging
    print("Restaurant ID: ${widget.restaurantId}");
    print("Items count: ${widget.items.length}");

    // First pass: collect categories from existing items
    for (var item in widget.items) {
      print("Item: ${item.name}, Categories: ${item.categories}");

      // Handle multiple categories
      if (item.categories.isNotEmpty) {
        for (var category in item.categories) {
          if (category.isNotEmpty &&
              !processedCategories.contains(category) &&
              !category.toLowerCase().contains("uncategorized")) {
            categoriesList.add(category);
            processedCategories.add(category);
            print("Added category from multiple: $category");
          }
        }
      }
      // Handle single category
      else if (item.category.isNotEmpty &&
          item.category != "All" &&
          !item.category.toLowerCase().contains("uncategorized") &&
          !processedCategories.contains(item.category)) {
        categoriesList.add(item.category);
        processedCategories.add(item.category);
        print("Added category from single: ${item.category}");
      }
    }

    // Also try to get restaurant-wide categories from Restuarantscubit if available
    try {
      final restaurantCubit = Restuarantscubit.get(context);
      final restaurantCategories = restaurantCubit.restaurants
          .firstWhere((r) => r.id == widget.restaurantId)
          .categories;

      print("Got restaurant categories: $restaurantCategories");

      // Add any restaurant-level categories that aren't already in our list
      for (var category in restaurantCategories) {
        if (category.isNotEmpty &&
            category != "All" &&
            !category.toLowerCase().contains("uncategorized") &&
            !processedCategories.contains(category)) {
          categoriesList.add(category);
          processedCategories.add(category);
          print("Added restaurant-level category: $category");
        }
      }
    } catch (e) {
      print("Error getting restaurant categories: $e");
    }

    print("Final categories list: $categoriesList");
    // Set the final categories list
    restaurantCategories = categoriesList;
  }

  List<Item> get filteredItems {
    if (selectedCategory == "All") {
      return widget.items; // Show all items
    }

    // Only show items that match the selected category
    return widget.items.where((item) {
      // Check multiple categories array first (case insensitive)
      if (item.categories.isNotEmpty) {
        return item.categories
            .any((cat) => cat.toLowerCase() == selectedCategory.toLowerCase());
      }

      // Check single category field (for backward compatibility) (case insensitive)
      return item.category.toLowerCase() == selectedCategory.toLowerCase();
    }).toList();
  }

  // Helper method to get the right image widget
  Widget _getImageWidget(String imageUrl) {
    try {
      if (imageUrl.startsWith('http')) {
        // Network image with error handling
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading menu image: $error");
            return Image.asset(
              'assets/images/restuarants/store.jpg',
              fit: BoxFit.cover,
            );
          },
        );
      } else if (imageUrl.startsWith('assets/')) {
        // Asset image
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
        );
      } else {
        // Default fallback image
        return Image.asset(
          'assets/images/restuarants/store.jpg',
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      print("Error handling menu image: $e");
      return Image.asset(
        'assets/images/restuarants/store.jpg',
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Favouritecubit, FavouriteState>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = Restuarantscubit.get(context);
        return SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                // 🟧 Image and Restaurant Title
                Stack(
                  children: [
                    SizedBox(
                      height: 180.h,
                      width: double.infinity,
                      child: _getImageWidget(widget.img),
                    ),
                    Positioned(
                      top: 10.h,
                      left: 10.w,
                      child: IconButton(
                        onPressed: () {
                          backarrow(context);
                          FocusScope.of(context).unfocus();
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 28.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10.h,
                      left: 16.w,
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        padding: EdgeInsets.all(8.w),
                        child: Text(
                          widget.name ?? "",
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 🟧 Delivery Info Bar
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      SizedBox(width: 4.w),
                      Text("${widget.deliverytime}"),
                      dot(),
                      Text(" ${widget.deliveryprice}",
                          style: TextStyle(color: Colors.green)),
                      dot(),
                      const Icon(Icons.delivery_dining, size: 24),
                      Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          navigateTo(
                            context,
                            Reviewsscreen(restaurantId: widget.restaurantId),
                          );
                        },
                        icon: Icon(Icons.star_rate, color: Colors.amber),
                        label: Text("Reviews"),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🟧 Category Tabs - Using restaurant-specific categories
                SizedBox(
                  height: 50.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    itemCount: restaurantCategories.length,
                    itemBuilder: (context, index) {
                      final category = restaurantCategories[index];
                      final isSelected = category == selectedCategory;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Chip(
                            label: Text(category),
                            backgroundColor: isSelected
                                ? Colors.green
                                : Theme.of(
                                    context,
                                  ).chipTheme.backgroundColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                            elevation: 0,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 🟧 Items
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return itemcard(
                        context,
                        false,
                        filteredItems[index],
                        widget.items,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget dot() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Text("•", style: TextStyle(fontSize: 18.sp)),
      );
}
