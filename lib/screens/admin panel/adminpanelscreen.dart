import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _restaurantCategoryController =
      TextEditingController();
  final TextEditingController _deliveryFeeController = TextEditingController();
  final TextEditingController _deliveryTimeController = TextEditingController();
  final TextEditingController _categoriesController = TextEditingController();

  // Item form controllers
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final TextEditingController _itemCategoryController = TextEditingController();

  // Category form controllers
  final TextEditingController _categoryNameController = TextEditingController();

  String? selectedRestaurantId;
  File? _restaurantImageFile;
  File? _itemImageFile;
  String? selectedItemCategory;
  List<String> selectedCategories = [];
  List<app_models.Order> allOrders = [];
  bool isLoadingOrders = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    _restaurantCategoryController.dispose();
    _deliveryFeeController.dispose();
    _deliveryTimeController.dispose();
    _categoriesController.dispose();
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _itemPriceController.dispose();
    _itemCategoryController.dispose();
    _categoryNameController.dispose();
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
                              child: Text(S.of(context).logout),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
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
                icon: Icon(Icons.logout),
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
              tabs: const [
                Tab(text: 'Restaurants'),
                Tab(text: 'Items'),
                Tab(text: 'Categories'),
                Tab(text: 'All Orders'),
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
                  'Add New Restaurant',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => cubit.getRestaurants(),
                  tooltip: 'Refresh restaurants',
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
                    label: 'Restaurant Name',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter restaurant name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _restaurantCategoryController,
                    type: TextInputType.text,
                    label: 'Main Category',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter main category';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _deliveryFeeController,
                    type: TextInputType.number,
                    label: 'Delivery Fee',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter delivery fee';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _deliveryTimeController,
                    type: TextInputType.text,
                    label: 'Delivery Time',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter delivery time';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _categoriesController,
                    type: TextInputType.text,
                    label: 'Categories (comma separated)',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter at least one category';
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
                                  content: Text('Error selecting image: $e')),
                            );
                          }
                        },
                        child: const Text('Select Image'),
                      ),
                      SizedBox(width: 16.w),
                      _restaurantImageFile != null
                          ? Text('Image selected')
                          : const Text('No image selected'),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  state is AddingRestaurantState
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _submitRestaurantForm(cubit),
                          child: const Text('Add Restaurant'),
                        ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Existing Restaurants',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Count: ${cubit.restaurants.length}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () => _addTestRestaurant(cubit),
                      tooltip: 'Add test restaurant (Debug)',
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
                  CircularProgressIndicator(),
                  SizedBox(height: 10.h),
                  Text('Loading restaurants...'),
                ],
              ))
            else if (cubit.restaurants.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.no_food, size: 60, color: Colors.grey),
                    SizedBox(height: 10.h),
                    Text('No restaurants found'),
                    SizedBox(height: 10.h),
                    ElevatedButton(
                      onPressed: () => cubit.getRestaurants(),
                      child: Text('Refresh'),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
              'Add New Item',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Restaurant',
                border: OutlineInputBorder(),
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
                    label: 'Item Name',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter item name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _itemDescriptionController,
                    type: TextInputType.multiline,
                    label: 'Description',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  defaultTextField(
                    controller: _itemPriceController,
                    type: TextInputType.number,
                    label: 'Price',
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
                        child: const Text('Select Image'),
                      ),
                      SizedBox(width: 16.w),
                      _itemImageFile != null
                          ? const Text('Image selected')
                          : const Text('No image selected'),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  state is AddingItemState
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: selectedRestaurantId == null
                              ? null
                              : () => _submitItemForm(cubit),
                          child: const Text('Add Item'),
                        ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Restaurant Items',
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
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          SizedBox(height: 16.h),
                          Text('Error displaying items: ${e.toString()}'),
                          SizedBox(height: 8.h),
                          ElevatedButton(
                            onPressed: () => cubit.getRestaurants(),
                            child: Text('Refresh Data'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              )
            else
              const Center(child: Text('Select a restaurant to view items')),
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
              (item.categories != null &&
                  item.categories.contains(selectedCategory)))
          .toList();
    }

    if (displayedItems.isEmpty) {
      return Center(
          child: Text('No items found in category "$selectedCategory"'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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
              'Add New Category',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Restaurant',
                border: OutlineInputBorder(),
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
                    label: 'Category Name',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter category name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  state is AddingCategoryState
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: selectedRestaurantId == null
                              ? null
                              : () => _submitCategoryForm(cubit),
                          child: const Text('Add Category'),
                        ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Restaurant Categories',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            if (selectedRestaurantId != null)
              _buildCategoriesForRestaurant(cubit, selectedRestaurantId!)
            else
              const Center(
                  child: Text('Select a restaurant to view categories')),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesForRestaurant(
      AdminPanelCubit cubit, String restaurantId) {
    final restaurant = cubit.restaurants.firstWhere(
      (r) => r.id == restaurantId,
      orElse: () => throw Exception('Restaurant not found'),
    );

    if (restaurant.categories.isEmpty) {
      return const Center(
          child: Text('No categories found for this restaurant'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: restaurant.categories.length,
      itemBuilder: (context, index) {
        final category = restaurant.categories[index];
        return ListTile(
          title: Text(category),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteCategory(cubit, restaurantId, category),
          ),
        );
      },
    );
  }

  void _submitRestaurantForm(AdminPanelCubit cubit) {
    if (_restaurantFormKey.currentState!.validate()) {
      final categoriesList = _categoriesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      cubit.addRestaurant(
        name: _restaurantNameController.text,
        category: _restaurantCategoryController.text,
        deliveryFee: _deliveryFeeController.text,
        deliveryTime: _deliveryTimeController.text,
        imageFile: _restaurantImageFile,
        categories: categoriesList,
      );
    }
  }

  void _submitItemForm(AdminPanelCubit cubit) {
    if (_itemFormKey.currentState!.validate() && selectedRestaurantId != null) {
      // Make sure we have at least one category
      if (selectedCategories.isEmpty) {
        // Show an error message if no categories selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one category')),
        );
        return;
      }

      // Use the first selected category as the main category
      String mainCategory = selectedCategories.first;

      cubit.addItem(
        restaurantId: selectedRestaurantId!,
        name: _itemNameController.text,
        description: _itemDescriptionController.text,
        price: double.parse(_itemPriceController.text),
        category: mainCategory, // First selected category as main
        categories: selectedCategories, // All selected categories
        imageFile: _itemImageFile,
      );
    }
  }

  void _submitCategoryForm(AdminPanelCubit cubit) {
    if (_categoryFormKey.currentState!.validate() &&
        selectedRestaurantId != null) {
      cubit.addCategory(
        restaurantId: selectedRestaurantId!,
        categoryName: _categoryNameController.text,
      );
    }
  }

  void _deleteRestaurant(AdminPanelCubit cubit, String restaurantId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Restaurant'),
        content: const Text('Are you sure you want to delete this restaurant?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // Reset state if we're deleting the currently selected restaurant
              if (selectedRestaurantId == restaurantId) {
                setState(() {
                  selectedRestaurantId = null;
                  selectedCategories = [];
                  _itemCategoryController.clear();
                  _categoryNameController.clear();
                });
              }

              // Then delete the restaurant
              cubit.deleteRestaurant(restaurantId);
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
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cubit.deleteItem(
                restaurantId: restaurantId,
                itemId: itemId,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(
      AdminPanelCubit cubit, String restaurantId, String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cubit.deleteCategory(
                restaurantId: restaurantId,
                categoryName: categoryName,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _clearRestaurantForm() {
    _restaurantNameController.clear();
    _restaurantCategoryController.clear();
    _deliveryFeeController.clear();
    _deliveryTimeController.clear();
    _categoriesController.clear();
    setState(() {
      _restaurantImageFile = null;
    });
  }

  void _clearItemForm() {
    _itemNameController.clear();
    _itemDescriptionController.clear();
    _itemPriceController.clear();
    _itemCategoryController.clear();
    setState(() {
      _itemImageFile = null;
      selectedCategories = [];
    });
  }

  void _clearCategoryForm() {
    _categoryNameController.clear();
  }

  // Debug function to add a test restaurant
  void _addTestRestaurant(AdminPanelCubit cubit) async {
    try {
      // Using null for imageFile - will use the default image from assets/images/restuarants/store.jpg
      await cubit.addRestaurant(
        name: "Test Restaurant ${DateTime.now().millisecondsSinceEpoch}",
        category: "Fast Food",
        deliveryFee: "50",
        deliveryTime: "30-45 min",
        imageFile: null, // null will use the default image from assets
        categories: ["Burgers", "Pizza", "Chicken"],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test restaurant added with default image')),
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
      SnackBar(content: Text('Debugging restaurants - check console output')),
    );

    try {
      // Directly check if we can get the restaurant document shown in your screenshot
      final docId = "UO76KZea0RVA5hqQKw1z";
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
          SnackBar(content: Text('Restaurant document not found: $docId')),
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
          'Select Categories:',
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
                      style: TextStyle(
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
                  'All Orders',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _fetchAllOrders,
                  icon: Icon(Icons.refresh),
                  label: Text('Refresh'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (isLoadingOrders)
              Center(child: CircularProgressIndicator())
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
                      "No orders found",
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
                    physics: AlwaysScrollableScrollPhysics(),
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
                                return Center(
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
                                  content: Text(
                                      'Order status updated to: $newStatus'),
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
                                  content: Text(
                                      'Error updating order status: $error'),
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
        title: Text(restaurant.name),
        subtitle: Text('${restaurant.category} • ${restaurant.deliveryTime}'),
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
        return AssetImage('assets/images/restuarants/store.jpg');
      }
    } catch (e) {
      print("Error loading image: $e");
      return AssetImage('assets/images/restuarants/store.jpg');
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
        title: Text(item.name),
        subtitle: Text('${item.category} • \$${item.price.toStringAsFixed(2)}'),
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
        return AssetImage('assets/images/items/default.jpg');
      }
    } catch (e) {
      print("Error loading image: $e");
      return AssetImage('assets/images/items/default.jpg');
    }
  }
}
