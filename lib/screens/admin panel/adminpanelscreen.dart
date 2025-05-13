import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/models/order.dart' as app_models;
import 'package:foodapp/models/resturant.dart';
import 'package:foodapp/screens/admin%20panel/cubit.dart';
import 'package:foodapp/screens/admin%20panel/states.dart';
import 'package:foodapp/screens/oredrs/cubit.dart';
import 'package:foodapp/shared/components/components.dart';
import 'package:foodapp/widgets/ordercard_admin.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<FormState> _restaurantFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _itemFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _categoryFormKey = GlobalKey<FormState>();

  // Restaurant form controllers
  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _restaurantNameArController =
      TextEditingController();
  final TextEditingController _restaurantCategoryController =
      TextEditingController();
  final TextEditingController _restaurantCategoryArController =
      TextEditingController();
  final TextEditingController _deliveryFeeController = TextEditingController();
  final TextEditingController _deliveryTimeController = TextEditingController();
  final TextEditingController _categoriesController = TextEditingController();

  // Item form controllers
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemNameArController = TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();
  final TextEditingController _itemDescriptionArController =
      TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemCategoryController = TextEditingController();

  // Category form controllers
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _categoryNameArController =
      TextEditingController();

  String? selectedRestaurantId;
  File? _restaurantImageFile;
  File? _itemImageFile;
  String? selectedItemCategory;
  List<String> selectedCategories = [];
  List<app_models.Order> allOrders = [];
  bool isLoadingOrders = false;
  File? _categoryImageFile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    selectedCategories = []; // Initialize empty categories list
    // Load restaurants when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<AdminPanelCubit>(context).getRestaurants();
    });
    _fetchAllOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _restaurantNameController.dispose();
    _restaurantNameArController.dispose();
    _restaurantCategoryController.dispose();
    _restaurantCategoryArController.dispose();
    _deliveryFeeController.dispose();
    _deliveryTimeController.dispose();
    _categoriesController.dispose();
    _itemNameController.dispose();
    _itemNameArController.dispose();
    _itemDescriptionController.dispose();
    _itemDescriptionArController.dispose();
    _itemPriceController.dispose();
    _itemCategoryController.dispose();
    _categoryNameController.dispose();
    _categoryNameArController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllOrders() async {
    if (!mounted) return;

    setState(() {
      isLoadingOrders = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('date', descending: true)
          .get();

      if (!mounted) return;

      setState(() {
        allOrders = snapshot.docs
            .map((doc) => app_models.Order.fromJson(doc.data()))
            .toList();
        isLoadingOrders = false;
      });
    } catch (e) {
      print('Error fetching all orders: $e');
      if (!mounted) return;

      setState(() {
        isLoadingOrders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminPanelCubit, AdminPanelStates>(
      listener: (context, state) {
        if (state is SuccessAddingRestaurantState) {
          _clearRestaurantForm();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restaurant added successfully')),
          );
        } else if (state is ErrorAddingRestaurantState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding restaurant: ${state.error}')),
          );
        } else if (state is SuccessDeletingRestaurantState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restaurant deleted successfully')),
          );
        } else if (state is SuccessAddingItemState) {
          _clearItemForm();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item added successfully')),
          );
        } else if (state is SuccessDeletingItemState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully')),
          );
        } else if (state is SuccessAddingCategoryState) {
          _clearCategoryForm();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category added successfully')),
          );
        } else if (state is SuccessDeletingCategoryState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted successfully')),
          );
        }
      },
      builder: (context, state) {
        final cubit = AdminPanelCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  Layoutcubit.get(context).changeLanguage();
                },
                icon: Icon(
                  Icons.language,
                  size: 25.sp,
                ),
                tooltip: 'Toggle Language',
              ),
              IconButton(
                onPressed: () async {
                  // Show confirmation dialog
                  bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(S.of(context).logout_title),
                          content: Text(S.of(context).logout_confirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                S.of(context).cancel,
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(S.of(context).logout),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (confirm && mounted) {
                    try {
                      // First perform logout
                      await FirebaseAuth.instance.signOut();

                      // Then navigate only if still mounted
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login', (route) => false);
                      }
                    } catch (e) {
                      print("Error during logout: $e");
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error during logout: $e')),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
              IconButton(
                onPressed: () {
                  Layoutcubit.get(context).toggletheme();
                },
                icon: Icon(
                  Icons.brightness_6_outlined,
                  size: 25.sp,
                ),
                tooltip: 'Toggle Theme',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              isScrollable: true,
              tabs: [
                Tab(text: S.of(context).admin_restaurants),
                Tab(text: S.of(context).admin_items),
                Tab(text: S.of(context).admin_categories),
                Tab(text: S.of(context).admin_orders),
                Tab(text: S.of(context).restaurant_categories),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildRestaurantsTab(cubit, state),
              _buildItemsTab(cubit, state),
              _buildCategoriesTab(cubit, state),
              _buildAllOrdersTab(cubit, state),
              _buildRestaurantCategoriesTab(cubit, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestaurantsTab(AdminPanelCubit cubit, AdminPanelStates state) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).add_restaurant,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => cubit.getRestaurants(),
                  tooltip: S.of(context).refresh,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Form(
              key: _restaurantFormKey,
              child: Column(
                children: [
                  defaultTextField(
                    controller: _restaurantNameController,
                    type: TextInputType.text,
                    label: S.of(context).Name,
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_fill_all_fields;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _restaurantNameArController,
                    type: TextInputType.text,
                    label: '${S.of(context).Name} (${S.of(context).arabic})',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_fill_all_fields;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _restaurantCategoryController,
                    type: TextInputType.text,
                    label: S.of(context).category,
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_fill_all_fields;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _restaurantCategoryArController,
                    type: TextInputType.text,
                    label:
                        '${S.of(context).category} (${S.of(context).arabic})',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_fill_all_fields;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _deliveryFeeController,
                    type: TextInputType.number,
                    label: S.of(context).delivery_fee,
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_fill_all_fields;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _deliveryTimeController,
                    type: TextInputType.text,
                    label: S.of(context).delivery_time,
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_fill_all_fields;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _categoriesController,
                    type: TextInputType.text,
                    label:
                        '${S.of(context).categories} (${S.of(context).comma_separated})',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_fill_all_fields;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final imageFile = await cubit.pickImage();
                            if (imageFile != null) {
                              setState(() {
                                _restaurantImageFile = imageFile;
                              });
                            }
                          } catch (e) {
                            print("Error selecting image: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${S.of(context).error}: ${e.toString()}')),
                            );
                          }
                        },
                        child: Text(S.of(context).select_image),
                      ),
                      SizedBox(width: 16.w),
                      _restaurantImageFile != null
                          ? Text(S.of(context).image_selected)
                          : Text(S.of(context).no_image_selected),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  state is AddingRestaurantState
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _submitRestaurantForm(cubit),
                          child: Text(S.of(context).add_restaurant),
                        ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).restaurants,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${S.of(context).count}: ${cubit.restaurants.length}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.green),
                      onPressed: () => _addTestRestaurant(cubit),
                      tooltip: S.of(context).add_restaurant,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (state is LoadingRestaurantsState)
              Center(
                  child: Column(
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 10.h),
                  Text(S.of(context).loading),
                ],
              ))
            else if (cubit.restaurants.isEmpty)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.no_food, size: 60, color: Colors.grey),
                    SizedBox(height: 10.h),
                    Text(S.of(context).no_data),
                    SizedBox(height: 10.h),
                    ElevatedButton(
                      onPressed: () => cubit.getRestaurants(),
                      child: Text(S.of(context).refresh),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cubit.restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = cubit.restaurants[index];
                  return RestaurantListItem(
                    restaurant: restaurant,
                    onDelete: () => _deleteRestaurant(cubit, restaurant.id),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTab(AdminPanelCubit cubit, AdminPanelStates state) {
    // Get available menu categories for the selected restaurant
    List<String> availableMenuCategories = selectedRestaurantId != null
        ? cubit.getMenuCategoriesForRestaurant(selectedRestaurantId!)
        : [];

    // Make sure categories are unique to avoid dropdown errors
    availableMenuCategories = availableMenuCategories.toSet().toList();

    // Add "All" as the first category
    if (!availableMenuCategories.contains("All")) {
      availableMenuCategories.insert(0, "All");
    }

    // Remove any variations of "Uncategorized" to avoid issues
    availableMenuCategories.removeWhere(
        (category) => category.toLowerCase().contains("uncategorized"));

    // Set selected category to "All" if not set or invalid
    if (selectedItemCategory == null ||
        !availableMenuCategories.contains(selectedItemCategory)) {
      selectedItemCategory = "All";
    }

    // Update the item category controller with selected value
    if (_itemCategoryController.text.isEmpty ||
        !availableMenuCategories.contains(_itemCategoryController.text)) {
      _itemCategoryController.text = "All";
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).add_new_item,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: S.of(context).select_restaurant,
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2),
                ),
              ),
              value: selectedRestaurantId,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                  fontSize: 16.sp),
              icon: Icon(Icons.arrow_drop_down,
                  color: Theme.of(context).primaryColor),
              items: cubit.restaurants.map((restaurant) {
                return DropdownMenuItem<String>(
                  value: restaurant.id,
                  child: Text(
                    restaurant.name,
                    style: TextStyle(
                      // Use the appropriate text color based on theme
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != selectedRestaurantId) {
                  setState(() {
                    selectedRestaurantId = value;
                    // Initialize with "All" category when restaurant is selected
                    if (value != null) {
                      _itemCategoryController.text = "All";
                    }
                    // Reset categories and item selections when restaurant changes
                    selectedCategories = [];
                  });
                }
              },
            ),
            SizedBox(height: 16.h),
            Form(
              key: _itemFormKey,
              child: Column(
                children: [
                  defaultTextField(
                    controller: _itemNameController,
                    type: TextInputType.text,
                    label: S.of(context).item_name,
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter item name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _itemNameArController,
                    type: TextInputType.text,
                    label:
                        '${S.of(context).item_name} (${S.of(context).arabic})',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Arabic item name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _itemDescriptionController,
                    type: TextInputType.multiline,
                    label: S.of(context).item_description,
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _itemDescriptionArController,
                    type: TextInputType.multiline,
                    label:
                        '${S.of(context).item_description} (${S.of(context).arabic})',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Arabic description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _itemPriceController,
                    type: TextInputType.number,
                    label: S.of(context).item_price,
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  // Category selection UI
                  _buildCategorySelectionUI(availableMenuCategories),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final imageFile = await cubit.pickImage();
                            if (imageFile != null) {
                              setState(() {
                                _itemImageFile = imageFile;
                              });
                            }
                          } catch (e) {
                            print("Error selecting image: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error selecting image: $e')),
                            );
                          }
                        },
                        child: Text(S.of(context).select_image),
                      ),
                      SizedBox(width: 16.w),
                      _itemImageFile != null
                          ? Text(S.of(context).image_selected)
                          : Text(S.of(context).no_image_selected),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  state is AddingItemState
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if (_itemFormKey.currentState!.validate()) {
                              if (selectedRestaurantId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(S
                                        .of(context)
                                        .select_restaurant_for_item),
                                  ),
                                );
                                return;
                              }

                              try {
                                await cubit.addItem(
                                  restaurantId: selectedRestaurantId!,
                                  name: _itemNameController.text,
                                  nameAr: _itemNameArController.text,
                                  description: _itemDescriptionController.text,
                                  descriptionAr:
                                      _itemDescriptionArController.text,
                                  price:
                                      double.parse(_itemPriceController.text),
                                  category: _itemCategoryController.text,
                                  categories: selectedCategories,
                                  imageFile: _itemImageFile,
                                );

                                _clearItemForm();
                                _itemImageFile = null;
                                setState(() {});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        S.of(context).item_added_successfully),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error adding item: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(S.of(context).add_item),
                        ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              S.of(context).restaurant_items,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            if (selectedRestaurantId != null)
              Builder(
                builder: (context) {
                  try {
                    return _buildItemsForRestaurant(
                        cubit, selectedRestaurantId!);
                  } catch (e) {
                    print("Error building items for restaurant: $e");
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          SizedBox(height: 16.h),
                          Text('Error displaying items: ${e.toString()}'),
                          SizedBox(height: 8.h),
                          ElevatedButton(
                            onPressed: () => cubit.getRestaurants(),
                            child: const Text('Refresh Data'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              )
            else
              Center(
                  child: Text(S.of(context).select_restaurant_to_view_items)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsForRestaurant(AdminPanelCubit cubit, String restaurantId) {
    final restaurant = cubit.restaurants.firstWhere(
      (r) => r.id == restaurantId,
      orElse: () => throw Exception('Restaurant not found'),
    );

    if (restaurant.menuItems.isEmpty) {
      return const Center(child: Text('No items found for this restaurant'));
    }

    // Get the currently selected category from the dropdown
    String selectedCategory = _itemCategoryController.text.isEmpty
        ? "All"
        : _itemCategoryController.text;

    // Filter items based on selected category
    var displayedItems = restaurant.menuItems;

    // Only filter if not showing "All" items
    if (selectedCategory != "All") {
      displayedItems = restaurant.menuItems
          .where((item) =>
              item.category == selectedCategory ||
              (item.categories.contains(selectedCategory)))
          .toList();
    }

    if (displayedItems.isEmpty) {
      return Center(
          child: Text('No items found in category "$selectedCategory"'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayedItems.length,
      itemBuilder: (context, index) {
        final item = displayedItems[index];
        return ItemListItem(
          item: item,
          onDelete: () => _deleteItem(cubit, restaurantId, item.id),
        );
      },
    );
  }

  Widget _buildCategoriesTab(AdminPanelCubit cubit, AdminPanelStates state) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).add_new_category,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: S.of(context).select_restaurant,
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2),
                ),
              ),
              value: selectedRestaurantId,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.white,
                  fontSize: 16.sp),
              icon: Icon(Icons.arrow_drop_down,
                  color: Theme.of(context).primaryColor),
              items: cubit.restaurants.map((restaurant) {
                return DropdownMenuItem<String>(
                  value: restaurant.id,
                  child: Text(
                    restaurant.name,
                    style: TextStyle(
                      // Use the appropriate text color based on theme
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != selectedRestaurantId) {
                  setState(() {
                    selectedRestaurantId = value;
                    // Reset relevant state when restaurant changes
                    _categoryNameController.clear();
                  });
                }
              },
            ),
            SizedBox(height: 16.h),
            Form(
              key: _categoryFormKey,
              child: Column(
                children: [
                  defaultTextField(
                    controller: _categoryNameController,
                    type: TextInputType.text,
                    label:
                        '${S.of(context).category_name_english} (${S.of(context).english})',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return S
                            .of(context)
                            .please_enter_category_name_in_english;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _categoryNameArController,
                    type: TextInputType.text,
                    label:
                        '${S.of(context).category_name_arabic} (${S.of(context).arabic})',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return S
                            .of(context)
                            .please_enter_category_name_in_arabic;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final imageFile = await cubit.pickImage();
                            if (imageFile != null) {
                              setState(() {
                                _categoryImageFile = imageFile;
                              });
                            }
                          } catch (e) {
                            print("Error selecting image: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error selecting image: $e')),
                            );
                          }
                        },
                        child: Text(S.of(context).select_image),
                      ),
                      SizedBox(width: 16.w),
                      _categoryImageFile != null
                          ? Text(S.of(context).image_selected)
                          : Text(S.of(context).no_image_selected),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  state is AddingCategoryState
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if (_categoryFormKey.currentState!.validate()) {
                              try {
                                String imageUrl =
                                    'assets/images/categories/all.png';
                                final categoryName = _categoryNameController
                                    .text
                                    .toLowerCase()
                                    .replaceAll(' ', '_');

                                if (_categoryImageFile != null) {
                                  // Create storage reference with category name
                                  final storageRef = FirebaseStorage.instance
                                      .ref()
                                      .child('categories')
                                      .child('$categoryName.jpg');

                                  // Upload image
                                  await storageRef.putFile(_categoryImageFile!);

                                  // Get download URL
                                  imageUrl = await storageRef.getDownloadURL();
                                } else {
                                  // If no image selected, use the default image path with category name
                                  imageUrl =
                                      'assets/images/categories/$categoryName.png';
                                }

                                // Add to Firestore
                                await FirebaseFirestore.instance
                                    .collection('restuarants_categories')
                                    .add({
                                  'en': _categoryNameController.text,
                                  'ar': _categoryNameArController.text,
                                  'img': imageUrl,
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Category added successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Clear form
                                _categoryNameController.clear();
                                _categoryNameArController.clear();
                                setState(() {
                                  _categoryImageFile = null;
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error adding category: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(S.of(context).add_category),
                        ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              S.of(context).existing_categories,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('restuarants_categories')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data?.docs ?? [];

                if (categories.isEmpty) {
                  return const Center(child: Text('No categories found'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category =
                        categories[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(category['img'] ??
                            'assets/images/categories/default.png'),
                      ),
                      title: Text(category['en'] ?? ''),
                      subtitle: Text(category['ar'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          try {
                            await categories[index].reference.delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Category deleted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error deleting category: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitRestaurantForm(AdminPanelCubit cubit) async {
    if (_restaurantFormKey.currentState!.validate()) {
      try {
        // Parse and validate categories
        final categoriesList = _categoriesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        if (categoriesList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter at least one category'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        await cubit.addRestaurant(
          name: _restaurantNameController.text.trim(),
          nameAr: _restaurantNameArController.text.trim(),
          category: _restaurantCategoryController.text.trim(),
          categoryAr: _restaurantCategoryArController.text.trim(),
          deliveryFee: _deliveryFeeController.text.trim(),
          deliveryTime: _deliveryTimeController.text.trim(),
          imageFile: _restaurantImageFile,
          categories: categoriesList,
        );

        // Close loading dialog
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Clear form and show success message
        _clearRestaurantForm();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restaurant added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding restaurant: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _submitItemForm(AdminPanelCubit cubit) async {
    if (_itemFormKey.currentState!.validate()) {
      try {
        if (selectedRestaurantId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a restaurant'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Validate price
        final double price;
        try {
          price = double.parse(_itemPriceController.text.trim());
          if (price <= 0) {
            throw const FormatException('Price must be greater than 0');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid price'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Validate categories
        if (selectedCategories.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least one category'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        await cubit.addItem(
          restaurantId: selectedRestaurantId!,
          name: _itemNameController.text.trim(),
          nameAr: _itemNameArController.text.trim(),
          description: _itemDescriptionController.text.trim(),
          descriptionAr: _itemDescriptionArController.text.trim(),
          price: price,
          category: _itemCategoryController.text.trim(),
          categories: selectedCategories,
          imageFile: _itemImageFile,
        );

        // Close loading dialog
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Clear form and show success message
        _clearItemForm();
        setState(() {
          _itemImageFile = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding item: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _deleteRestaurant(AdminPanelCubit cubit, String restaurantId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Restaurant'),
        content: const Text(
            'Are you sure you want to delete this restaurant? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () async {
              try {
                Navigator.pop(context); // Close confirmation dialog

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                // Reset state if we're deleting the currently selected restaurant
                if (selectedRestaurantId == restaurantId) {
                  setState(() {
                    selectedRestaurantId = null;
                    selectedCategories = [];
                    _itemCategoryController.clear();
                  });
                }

                await cubit.deleteRestaurant(restaurantId);

                // Close loading dialog
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Restaurant deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Close loading dialog
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Error deleting restaurant: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(AdminPanelCubit cubit, String restaurantId, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text(
            'Are you sure you want to delete this item? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () async {
              try {
                Navigator.pop(context); // Close confirmation dialog

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                await cubit.deleteItem(
                  restaurantId: restaurantId,
                  itemId: itemId,
                );

                // Close loading dialog
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Close loading dialog
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting item: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _clearRestaurantForm() {
    _restaurantNameController.clear();
    _restaurantNameArController.clear();
    _restaurantCategoryController.clear();
    _restaurantCategoryArController.clear();
    _deliveryFeeController.clear();
    _deliveryTimeController.clear();
    _categoriesController.clear();
    setState(() {
      _restaurantImageFile = null;
    });
  }

  void _clearItemForm() {
    _itemNameController.clear();
    _itemNameArController.clear();
    _itemDescriptionController.clear();
    _itemDescriptionArController.clear();
    _itemPriceController.clear();
    _itemCategoryController.clear();
    setState(() {
      _itemImageFile = null;
      selectedCategories = [];
    });
  }

  void _clearCategoryForm() {
    _categoryNameController.clear();
    _categoryNameArController.clear();
  }

  // Debug function to add a test restaurant
  void _addTestRestaurant(AdminPanelCubit cubit) async {
    try {
      // Using null for imageFile - will use the default image from assets/images/restuarants/store.jpg
      await cubit.addRestaurant(
        name: "Test Restaurant ${DateTime.now().millisecondsSinceEpoch}",
        nameAr: "مطعم تجريبي ${DateTime.now().millisecondsSinceEpoch}",
        category: "Fast Food",
        categoryAr: "طعام سريع",
        deliveryFee: "50",
        deliveryTime: "30-45 min",
        imageFile: null, // null will use the default image from assets
        categories: ["Burgers", "Pizza", "Chicken"],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Test restaurant added with default image')),
      );
    } catch (e) {
      print("Error adding test restaurant: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding test restaurant: $e')),
      );
    }
  }

  // Debug function to directly retrieve and print restaurant documents
  void _debugRestaurants(AdminPanelCubit cubit) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Debugging restaurants - check console output')),
    );

    try {
      // Directly check if we can get the restaurant document shown in your screenshot
      const docId = "UO76KZea0RVA5hqQKw1z";
      final docSnapshot = await FirebaseFirestore.instance
          .collection("restaurants")
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        print("DIRECT ACCESS - Found restaurant document: $docId");
        print("Document data: $data");

        // Try to create a Restaurant object from this data
        try {
          final restaurantData = {
            ...data!,
            'id': docId,
          };

          Restuarants restaurant = Restuarants.fromJson(restaurantData);
          print(
              "Successfully created restaurant object: ${restaurant.toString()}");

          // Show success in UI
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Found restaurant: ${restaurant.name}')),
          );
        } catch (e) {
          print("Error creating restaurant object: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating restaurant object: $e')),
          );
        }
      } else {
        print("DIRECT ACCESS - Restaurant document not found: $docId");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Restaurant document not found: $docId')),
        );
      }

      // Also list all restaurants in the collection
      final querySnapshot =
          await FirebaseFirestore.instance.collection("restaurants").get();

      print(
          "DIRECT ACCESS - Found ${querySnapshot.docs.length} restaurant documents");
      for (var doc in querySnapshot.docs) {
        print("Document ID: ${doc.id}");
        print("Document data: ${doc.data()}");
      }
    } catch (e) {
      print("Error during direct access debug: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error debugging restaurants: $e')),
      );
    }
  }

  // This is for the multiple categories selection in the admin panel
  Widget _buildCategorySelectionUI(List<String> availableMenuCategories) {
    // Remove "All" from selection options - it's a special filter category
    var selectableCategories =
        availableMenuCategories.where((c) => c != "All").toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).select_category,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        if (selectedRestaurantId != null)
          Builder(
            builder: (context) {
              final adminCubit = BlocProvider.of<AdminPanelCubit>(context);
              return Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: adminCubit
                    .getMenuCategoriesForRestaurant(selectedRestaurantId!)
                    .where((category) =>
                        category != "Uncategorized" &&
                        !category.toLowerCase().contains("uncategorized"))
                    .map((category) {
                  final isSelected = selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedCategories.add(category);
                        } else {
                          selectedCategories.remove(category);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.green[200],
                  );
                }).toList(),
              );
            },
          )
      ],
    );
  }

  Widget _buildAllOrdersTab(AdminPanelCubit cubit, AdminPanelStates state) {
    // Create a reference to the OrderCubit for updating statuses
    final orderCubit = OrderCubit.get(context);

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).admin_orders,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _fetchAllOrders,
                  icon: const Icon(Icons.refresh),
                  label: Text(S.of(context).refresh),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (isLoadingOrders)
              const Center(child: CircularProgressIndicator())
            else if (allOrders.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 70.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      S.of(context).no_orders_found,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: RefreshIndicator(
                  onRefresh: _fetchAllOrders,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: allOrders.length,
                    itemBuilder: (context, index) {
                      return OrderCardAdmin(
                        model: allOrders[index],
                        onStatusChange: (orderId, newStatus) async {
                          try {
                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );

                            // Update the order status
                            await orderCubit.updateOrderStatus(
                                orderId, newStatus);

                            // Check if widget is still mounted before updating state
                            if (!mounted) return;

                            // Update the order in the allOrders list
                            setState(() {
                              allOrders[index].status = newStatus;
                            });

                            // Close loading dialog if context is still valid
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }

                            // Show success message if context is still valid
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(S
                                      .of(context)
                                      .order_status_updated_to(newStatus)),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (error) {
                            // Close loading dialog if context is still valid
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }

                            // Show error message if context is still valid
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(S
                                      .of(context)
                                      .error_updating_order_status(
                                          error.toString())),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCategoriesTab(
      AdminPanelCubit cubit, AdminPanelStates state) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).restaurant_categories,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Form(
              key: _categoryFormKey,
              child: Column(
                children: [
                  defaultTextField(
                    controller: _categoryNameController,
                    type: TextInputType.text,
                    label: S.of(context).category_name_english,
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter category name in English';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _categoryNameArController,
                    type: TextInputType.text,
                    label: S.of(context).category_name_arabic,
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return S
                            .of(context)
                            .please_enter_category_name_in_arabic;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final imageFile = await cubit.pickImage();
                            if (imageFile != null) {
                              setState(() {
                                _categoryImageFile = imageFile;
                              });
                            }
                          } catch (e) {
                            print("Error selecting image: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error selecting image: $e')),
                            );
                          }
                        },
                        child: Text(S.of(context).select_image),
                      ),
                      SizedBox(width: 16.w),
                      _categoryImageFile != null
                          ? Text(S.of(context).image_selected)
                          : Text(S.of(context).no_image_selected),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  state is AddingCategoryState
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if (_categoryFormKey.currentState!.validate()) {
                              try {
                                String imageUrl =
                                    'assets/images/categories/all.png';
                                final categoryName = _categoryNameController
                                    .text
                                    .toLowerCase()
                                    .replaceAll(' ', '_');

                                if (_categoryImageFile != null) {
                                  // Create storage reference with category name
                                  final storageRef = FirebaseStorage.instance
                                      .ref()
                                      .child('categories')
                                      .child('$categoryName.jpg');

                                  // Upload image
                                  await storageRef.putFile(_categoryImageFile!);

                                  // Get download URL
                                  imageUrl = await storageRef.getDownloadURL();
                                } else {
                                  // If no image selected, use the default image path with category name
                                  imageUrl =
                                      'assets/images/categories/$categoryName.png';
                                }

                                // Add to Firestore
                                await FirebaseFirestore.instance
                                    .collection('restuarants_categories')
                                    .add({
                                  'en': _categoryNameController.text,
                                  'ar': _categoryNameArController.text,
                                  'img': imageUrl,
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Category added successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Clear form
                                _categoryNameController.clear();
                                _categoryNameArController.clear();
                                setState(() {
                                  _categoryImageFile = null;
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error adding category: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(S.of(context).add_category),
                        ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              S.of(context).existing_categories,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('restuarants_categories')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = snapshot.data?.docs ?? [];

                if (categories.isEmpty) {
                  return const Center(child: Text('No categories found'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category =
                        categories[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(category['img'] ??
                            'assets/images/categories/default.png'),
                      ),
                      title: Text(category['en'] ?? ''),
                      subtitle: Text(category['ar'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          try {
                            await categories[index].reference.delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Category deleted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error deleting category: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantListItem extends StatelessWidget {
  final Restuarants restaurant;
  final VoidCallback onDelete;

  const RestaurantListItem({
    Key? key,
    required this.restaurant,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: _getImageProvider(restaurant.img),
          backgroundColor: Colors.grey,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(restaurant.name),
            Text(
              restaurant.nameAr,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${restaurant.category} • ${restaurant.deliveryTime}'),
            Text(
              restaurant.categoryAr,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }

  // Helper method to safely get an image provider
  ImageProvider _getImageProvider(String imageUrl) {
    try {
      if (imageUrl.startsWith('http')) {
        return NetworkImage(imageUrl);
      } else if (imageUrl.startsWith('assets/')) {
        return AssetImage(imageUrl);
      } else {
        // Default fallback image
        return const AssetImage('assets/images/restuarants/store.jpg');
      }
    } catch (e) {
      print("Error loading image: $e");
      return const AssetImage('assets/images/restuarants/store.jpg');
    }
  }
}

class ItemListItem extends StatelessWidget {
  final Item item;
  final VoidCallback onDelete;

  const ItemListItem({
    Key? key,
    required this.item,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: _getImageProvider(item.img),
          backgroundColor: Colors.grey,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Text(
                  " • ",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.nameAr,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.category} • \$${item.price.toStringAsFixed(2)}'),
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  " • ",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.descriptionAr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }

  // Helper method to safely get an image provider
  ImageProvider _getImageProvider(String imageUrl) {
    try {
      if (imageUrl.startsWith('http')) {
        return NetworkImage(imageUrl);
      } else if (imageUrl.startsWith('assets/')) {
        return AssetImage(imageUrl);
      } else {
        // Default fallback image
        return const AssetImage('assets/images/items/default.jpg');
      }
    } catch (e) {
      print("Error loading image: $e");
      return const AssetImage('assets/images/items/default.jpg');
    }
  }
}
