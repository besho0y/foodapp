// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/models/resturant.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/favourits/states.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/screens/reviews/reviewsscreen.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/widgets/itemcard.dart';

class Menuscreen extends StatefulWidget {
  const Menuscreen({
    super.key,
    required this.items,
    required this.name,
    required this.img,
    required this.deliverytime,
    required this.deliveryprice,
    required this.restaurantId,
    this.outOfAreaFee,
  });

  final List<Item> items;
  final String? name;
  final String img;
  final String deliverytime;
  final String deliveryprice;
  final String restaurantId;
  final String? outOfAreaFee;

  @override
  State<Menuscreen> createState() => _MenuscreenState();
}

class _MenuscreenState extends State<Menuscreen> {
  // Data structures for menu categories
  late List<Map<String, String>> menuCategories = [
    {"name": "All", "nameAr": "الكل"}
  ];
  String selectedCategory = "All";
  bool isLoadingCategories = true;
  bool isRtl = false;

  @override
  void initState() {
    super.initState();
    _fetchMenuCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check RTL direction when locale might have changed
    isRtl = Directionality.of(context) == TextDirection.rtl;
    // Reset selected category based on RTL state
    _updateSelectedCategoryForLanguage();
  }

  // Helper method to update selected category when language changes
  void _updateSelectedCategoryForLanguage() {
    // Find the current category in both languages
    final currentCategoryMap = menuCategories.firstWhere(
      (cat) =>
          cat["name"] == selectedCategory || cat["nameAr"] == selectedCategory,
      orElse: () => {"name": "All", "nameAr": "الكل"},
    );

    // Set the appropriate language version
    if (isRtl) {
      selectedCategory = currentCategoryMap["nameAr"] ?? "الكل";
    } else {
      selectedCategory = currentCategoryMap["name"] ?? "All";
    }
  }

  // Helper method to get localized category name
  String getLocalizedCategoryName(int index) {
    if (index >= menuCategories.length) return "";
    final cat = menuCategories[index];
    return isRtl
        ? (cat["nameAr"] ?? cat["name"] ?? "")
        : (cat["name"] ?? cat["nameAr"] ?? "");
  }

  Future<void> _fetchMenuCategories() async {
    // Start with "All" category
    List<Map<String, String>> categoriesList = [
      {"name": "All", "nameAr": "الكل"}
    ];
    Set<String> processedCategories = {
      "all",
      "الكل",
      "كل"
    }; // Use lowercase for consistent checking

    try {
      if (!mounted) return; // Early return if widget is disposed

      setState(() {
        isLoadingCategories = true;
      });

      // Method 1: Try to fetch from menu_categories subcollection first
      final categorySnapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(widget.restaurantId)
          .collection("menu_categories")
          .get();

      print(
          "Found ${categorySnapshot.docs.length} categories in subcollection");

      if (categorySnapshot.docs.isNotEmpty) {
        // Categories found in subcollection
        for (var doc in categorySnapshot.docs) {
          final data = doc.data();
          final categoryName = data['name']?.toString();
          final categoryNameAr = data['nameAr']?.toString();

          if (categoryName != null &&
              categoryName.isNotEmpty &&
              categoryName.toLowerCase() !=
                  "all" && // Explicitly exclude "All" in any case
              !processedCategories.contains(categoryName.toLowerCase()) &&
              !categoryName.toLowerCase().contains("uncategorized")) {
            final arabicName = categoryNameAr ?? categoryName;
            categoriesList.add({"name": categoryName, "nameAr": arabicName});
            processedCategories.add(categoryName.toLowerCase());
            processedCategories.add(arabicName.toLowerCase());
            print(
                "Added category from subcollection: $categoryName / $arabicName");
          }
        }
      } else {
        // Method 2: Fall back to menuCategories array field if subcollection is empty
        try {
          final restaurantDoc = await FirebaseFirestore.instance
              .collection("restaurants")
              .doc(widget.restaurantId)
              .get();

          if (restaurantDoc.exists) {
            final data = restaurantDoc.data();
            final menuCategories = data?['menuCategories'];
            final menuCategoriesAr = data?['menuCategoriesAr'];

            if (menuCategories != null && menuCategories is List) {
              print("Using menuCategories array field as fallback");

              for (int i = 0; i < menuCategories.length; i++) {
                final category = menuCategories[i];
                String categoryAr = "";

                // Try to get matching Arabic category
                if (menuCategoriesAr != null &&
                    menuCategoriesAr is List &&
                    i < menuCategoriesAr.length) {
                  categoryAr = menuCategoriesAr[i].toString();
                } else {
                  categoryAr = category.toString();
                }

                if (category != null &&
                    category.toString().isNotEmpty &&
                    category.toString().toLowerCase() !=
                        "all" && // Explicitly exclude "All" in any case
                    !processedCategories
                        .contains(category.toString().toLowerCase()) &&
                    !category
                        .toString()
                        .toLowerCase()
                        .contains("uncategorized")) {
                  categoriesList
                      .add({"name": category.toString(), "nameAr": categoryAr});
                  processedCategories.add(category.toString().toLowerCase());
                  processedCategories.add(categoryAr.toLowerCase());
                  print(
                      "Added category from menuCategories array: $category / $categoryAr");
                }
              }
            }
          }
        } catch (e) {
          print("Error getting restaurant array categories: $e");
        }

        // Method 3: Fallback to extracting from items if both previous methods failed
        if (categoriesList.length <= 1) {
          print(
              "No categories found in subcollection or array field. Using items as fallback.");

          // Process categories from items
          for (var item in widget.items) {
            print("Item: ${item.name}, Categories: ${item.categories}");

            // Handle multiple categories
            if (item.categories.isNotEmpty) {
              for (var category in item.categories) {
                if (category.isNotEmpty &&
                    category.toLowerCase() !=
                        "all" && // Explicitly exclude "All" in any case
                    !processedCategories.contains(category.toLowerCase()) &&
                    !category.toLowerCase().contains("uncategorized")) {
                  categoriesList.add({"name": category, "nameAr": category});
                  processedCategories.add(category.toLowerCase());
                  print("Added category from multiple: $category");
                }
              }
            }
            // Handle single category
            else if (item.category.isNotEmpty &&
                item.category.toLowerCase() !=
                    "all" && // Explicitly exclude "All" in any case
                !item.category.toLowerCase().contains("uncategorized") &&
                !processedCategories.contains(item.category.toLowerCase())) {
              categoriesList
                  .add({"name": item.category, "nameAr": item.category});
              processedCategories.add(item.category.toLowerCase());
              print("Added category from single: ${item.category}");
            }
          }
        }
      }

      // Method 4: Also try to get restaurant categories from Restuarantscubit if available
      try {
        final restaurantCubit = Restuarantscubit.get(context);
        final restaurant = restaurantCubit.restaurants
            .firstWhere((r) => r.id == widget.restaurantId);

        final restaurantCategories = restaurant.menuCategories;
        final restaurantCategoriesAr = restaurant.menuCategoriesAr;

        if (restaurantCategories != null) {
          print(
              "Got restaurant menu categories from cubit: $restaurantCategories");

          for (int i = 0; i < restaurantCategories.length; i++) {
            final category = restaurantCategories[i];
            String categoryAr = "";

            // Try to get matching Arabic category
            if (restaurantCategoriesAr != null &&
                i < restaurantCategoriesAr.length) {
              categoryAr = restaurantCategoriesAr[i];
            } else {
              categoryAr = category;
            }

            if (category.isNotEmpty &&
                category.toLowerCase() !=
                    "all" && // Explicitly exclude "All" in any case
                !category.toLowerCase().contains("uncategorized") &&
                !processedCategories.contains(category.toLowerCase())) {
              categoriesList.add({"name": category, "nameAr": categoryAr});
              processedCategories.add(category.toLowerCase());
              processedCategories.add(categoryAr.toLowerCase());
              print(
                  "Added restaurant-level menu category: $category / $categoryAr");
            }
          }
        }
      } catch (e) {
        print("Error getting restaurant cubit categories: $e");
      }

      print("Final categories list: $categoriesList");

      if (!mounted) return; // Check again before setState

      setState(() {
        menuCategories = categoriesList;
        isLoadingCategories = false;
        isRtl = Directionality.of(context) == TextDirection.rtl;
        // Set the initial selected category to "All" or "الكل" based on language
        selectedCategory = isRtl ? "الكل" : "All";
      });
    } catch (e) {
      print("Error fetching menu categories: $e");

      // Fallback to directly extracting from items if all else fails
      List<Map<String, String>> fallbackList = [
        {"name": "All", "nameAr": "الكل"}
      ];
      Set<String> processedFallback = {
        "all",
        "الكل",
        "كل"
      }; // Use lowercase for consistent checking

      for (var item in widget.items) {
        if (item.categories.isNotEmpty) {
          for (var category in item.categories) {
            if (category.isNotEmpty &&
                category.toLowerCase() !=
                    "all" && // Explicitly exclude "All" in any case
                !processedFallback.contains(category.toLowerCase())) {
              fallbackList.add({"name": category, "nameAr": category});
              processedFallback.add(category.toLowerCase());
            }
          }
        } else if (item.category.isNotEmpty &&
            item.category.toLowerCase() !=
                "all" && // Explicitly exclude "All" in any case
            !processedFallback.contains(item.category.toLowerCase())) {
          fallbackList.add({"name": item.category, "nameAr": item.category});
          processedFallback.add(item.category.toLowerCase());
        }
      }

      if (!mounted) return; // Check again before setState

      setState(() {
        menuCategories = fallbackList;
        isLoadingCategories = false;
        isRtl = Directionality.of(context) == TextDirection.rtl;
        // Set the initial selected category to "All" or "الكل" based on language
        selectedCategory = isRtl ? "الكل" : "All";
      });
    }
  }

  List<Item> get filteredItems {
    // Check if showing all items
    if ((selectedCategory == "All" && !isRtl) ||
        (selectedCategory == "الكل" && isRtl)) {
      return widget.items; // Show all items
    }

    // Find both English and Arabic names for the selected category
    final categoryMap = menuCategories.firstWhere(
      (cat) =>
          cat["name"] == selectedCategory || cat["nameAr"] == selectedCategory,
      orElse: () => {"name": selectedCategory, "nameAr": selectedCategory},
    );
    final String englishCategory = categoryMap["name"] ?? selectedCategory;
    final String arabicCategory = categoryMap["nameAr"] ?? selectedCategory;

    // For debugging
    print("Filtering by category: $englishCategory / $arabicCategory");
    print("Total items before filtering: ${widget.items.length}");

    // Only show items that match the selected category (in either language)
    final filtered = widget.items.where((item) {
      // For debugging
      print(
          "Item ${item.name} - Categories: ${item.categories} - Category: ${item.category}");

      // Check multiple categories array first (case insensitive)
      if (item.categories.isNotEmpty) {
        final matchInArray = item.categories.any((cat) {
          final c = cat.toLowerCase().trim();
          return c == englishCategory.toLowerCase().trim() ||
              c == arabicCategory.toLowerCase().trim();
        });
        if (matchInArray) {
          print(
              "Item ${item.name} matches category '$englishCategory' or '$arabicCategory' in array");
          return true;
        }
      }

      // Check single category field (for backward compatibility) (case insensitive)
      final c = item.category.toLowerCase().trim();
      final matchInField = c == englishCategory.toLowerCase().trim() ||
          c == arabicCategory.toLowerCase().trim();
      if (matchInField) {
        print(
            "Item ${item.name} matches category '$englishCategory' or '$arabicCategory' in field");
        return true;
      }

      return false;
    }).toList();

    print(
        "Found ${filtered.length} items for category: $englishCategory / $arabicCategory");
    return filtered;
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
    // Check for RTL at build time in case the locale changed
    isRtl = Directionality.of(context) == TextDirection.rtl;

    // Ensure the selected category is correct for the current language
    _updateSelectedCategoryForLanguage();

    return BlocConsumer<Favouritecubit, FavouriteState>(
      listener: (context, state) {
        // Sync favorite status for items when favorite state changes
        if (state is FavouriteLoadedState ||
            state is FavouriteAddState ||
            state is FavouriteRemoveState) {
          final favCubit = Favouritecubit.get(context);
          favCubit.updateItemsFavoriteStatus(widget.items);
        }
      },
      builder: (context, state) {
        var cubit = Restuarantscubit.get(context);
        return SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                // 🟧 Image and Restaurant Title - More flexible layout
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
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

                // 🟧 Delivery Info Bar - Improved layout with flexible width
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
                  child: Column(
                    children: [
                      // First row: Delivery info
                      Row(
                        children: [
                          // Delivery time with icon
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, size: 16.sp),
                              SizedBox(width: 4.w),
                              Text(
                                widget.deliverytime,
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ],
                          ),
                          dot(),
                          // Delivery fee
                          Text(
                            "${widget.deliveryprice} ${S.of(context).egp} ",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Icons.delivery_dining, size: 18.sp),
                          // Out-of-area fee (only show if it exists and > 0)
                          if (widget.outOfAreaFee != null &&
                              widget.outOfAreaFee!.isNotEmpty &&
                              widget.outOfAreaFee != "0" &&
                              double.tryParse(widget.outOfAreaFee!) != null &&
                              double.parse(widget.outOfAreaFee!) > 0) ...[
                            Text(
                              " + ${widget.outOfAreaFee} ${S.of(context).egp} *",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          dot(),

                          const Spacer(),
                          // Reviews button
                          TextButton.icon(
                            onPressed: () {
                              navigateTo(
                                context,
                                Reviewsscreen(
                                    restaurantId: widget.restaurantId),
                              );
                            },
                            icon: const Icon(Icons.star_rate,
                                color: Colors.amber, size: 16),
                            label: Text(
                              S.of(context).reviews,
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Second row: Out-of-area label (only if fee exists)
                      if (widget.outOfAreaFee != null &&
                          widget.outOfAreaFee!.isNotEmpty &&
                          widget.outOfAreaFee != "0" &&
                          double.tryParse(widget.outOfAreaFee!) != null &&
                          double.parse(widget.outOfAreaFee!) > 0) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Text(
                              "* ${isRtl ? 'خارج المنطقة' : 'Out-of-area delivery fee applies'}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10.sp,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // 🟧 Category Tabs - Optimized for horizontal scrolling without overflow
                Container(
                  height: 60.h,
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  child: isLoadingCategories
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          itemCount: menuCategories.length,
                          itemBuilder: (context, index) {
                            final category = getLocalizedCategoryName(index);
                            final isSelected = category == selectedCategory;

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: GestureDetector(
                                onTap: () {
                                  if (!mounted) return; // Safety check
                                  setState(() {
                                    selectedCategory = category;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8.h, horizontal: 4.w),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color.fromARGB(255, 74, 26, 15)
                                        : Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(25.r),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      category,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // 🟧 Items - No change needed here as itemcard is already fixed
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Text(
                            S.of(context).no_data,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            // Create a simple restaurant object with the data we have
                            final simpleRestaurant = Restuarants(
                              id: widget.restaurantId,
                              name: widget.name ?? '',
                              nameAr:
                                  widget.name ?? '', // Using same name for now
                              menuItems: widget.items,
                              img: widget.img,
                              rating: 0.0,
                              category: 'restaurant',
                              categoryAr: 'مطعم',
                              deliveryFee: widget.deliveryprice,
                              ordersnum: 0,
                              deliveryTime: widget.deliverytime,
                              categories: ['restaurant'],
                            );

                            return itemcard(context, false,
                                filteredItems[index], [simpleRestaurant]);
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
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Text("•", style: TextStyle(fontSize: 14.sp)),
      );
}
