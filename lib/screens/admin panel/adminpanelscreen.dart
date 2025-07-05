import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/models/area.dart';
import 'package:foodapp/models/category.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/models/order.dart' as app_models;
import 'package:foodapp/models/resturant.dart';
import 'package:foodapp/screens/admin%20panel/cubit.dart';
import 'package:foodapp/screens/admin%20panel/states.dart';
import 'package:foodapp/screens/oredrs/cubit.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/screens/resturants/states.dart';
import 'package:foodapp/shared/colors.dart';
import 'package:foodapp/shared/components/components.dart';
import 'package:foodapp/shared/local_storage.dart';
import 'package:foodapp/widgets/ordercard_admin.dart';
import 'package:image_picker/image_picker.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final GlobalKey<FormState> _restaurantFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _itemFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _categoryFormKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _selectedTabIndex = 0;

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
  File? _bannerImageFile;
  Category? _selectedRestaurantCategory;
  String? _selectedRestaurantCityId; // Selected city for restaurant
  final List<String> _selectedMainAreas =
      []; // Selected main areas for restaurant (no out-of-area fee)
  final List<String> _selectedSecondaryAreas =
      []; // Selected secondary areas for restaurant (with out-of-area fee)

  final TextEditingController _outOfAreaFeeController = TextEditingController();

  // Add flag to prevent multiple refresh operations
  bool _isRefreshing = false;

  // Add flags to track data initialization
  bool _citiesInitialized = false;
  bool _areasInitialized = false;

  // Areas tab variables
  String? _selectedCityId;
  final TextEditingController _areaNameController = TextEditingController();
  final TextEditingController _areaNameArController = TextEditingController();

  @override
  void initState() {
    super.initState();
    try {
      selectedCategories = []; // Initialize empty categories list

      // Load restaurants when the screen initializes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            BlocProvider.of<AdminPanelCubit>(context).getRestaurants();
            BlocProvider.of<AdminPanelCubit>(context).fetchBanners();
            BlocProvider.of<AdminPanelCubit>(context)
                .fetchCities(); // Load cities for restaurant form
          } catch (e) {
            print('Error loading restaurants in initState: $e');
            _showSnackBar('Error loading restaurants',
                backgroundColor: Colors.red);
          }
        }
      });

      // Fetch orders but don't await - the method has its own mounted checks
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fetchAllOrders();
        }
      });

      // Safely initialize restaurant category
      try {
        final restCategories = Restuarantscubit.get(context)
            .categories
            .where((cat) => cat.en != 'All')
            .toList();
        if (restCategories.isNotEmpty) {
          _selectedRestaurantCategory = restCategories.first;
        }
      } catch (e) {
        print('Error initializing restaurant categories: $e');
      }
    } catch (e) {
      print('Error in initState: $e');
    }
  }

  @override
  void dispose() {
    try {
      _pageController.dispose();
      _restaurantNameController.dispose();
      _restaurantNameArController.dispose();
      _restaurantCategoryController.dispose();
      _restaurantCategoryArController.dispose();
      _deliveryFeeController.dispose();
      _deliveryTimeController.dispose();
      _itemNameController.dispose();
      _itemNameArController.dispose();
      _itemDescriptionController.dispose();
      _itemDescriptionArController.dispose();
      _itemPriceController.dispose();
      _itemCategoryController.dispose();
      _categoryNameController.dispose();
      _categoryNameArController.dispose();
      _areaNameController.dispose();
      _areaNameArController.dispose();
      _outOfAreaFeeController.dispose();
    } catch (e) {
      print('Error in dispose: $e');
    }
    super.dispose();
  }

  Future<void> _fetchAllOrders() async {
    if (!mounted) return;

    if (mounted) {
      setState(() {
        isLoadingOrders = true;
      });
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('date', descending: true)
          .limit(100) // Limit to prevent memory issues
          .get();

      if (!mounted) return;

      if (mounted) {
        setState(() {
          allOrders = snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  if (data.isEmpty) {
                    print('Empty order document: ${doc.id}');
                    return null;
                  }
                  return app_models.Order.fromJson(data);
                } catch (e) {
                  print('Error parsing order ${doc.id}: $e');
                  return null;
                }
              })
              .where((order) => order != null)
              .cast<app_models.Order>()
              .toList();
          isLoadingOrders = false;
        });
      }
    } catch (e) {
      print('Error fetching all orders: $e');
      if (!mounted) return;

      if (mounted) {
        setState(() {
          allOrders = []; // Clear orders on error
          isLoadingOrders = false;
        });
      }

      // Show error to user
      _showSnackBar('Error loading orders: $e', backgroundColor: Colors.red);
    }
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error showing snackbar: $e');
    }
  }

  void _safeNavigatorPop(BuildContext context) {
    try {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error in navigation pop: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminPanelCubit, AdminPanelStates>(
      listener: (context, state) {
        try {
          if (state is SuccessAddingRestaurantState) {
            _clearRestaurantForm();
            _showSnackBar('Restaurant added successfully',
                backgroundColor: Colors.green);
            _refreshAdminPanel(); // Refresh after adding restaurant
          } else if (state is ErrorAddingRestaurantState) {
            _showSnackBar('Error adding restaurant: ${state.error}',
                backgroundColor: Colors.red);
          } else if (state is SuccessDeletingRestaurantState) {
            _showSnackBar('Restaurant deleted successfully',
                backgroundColor: Colors.green);
            _refreshAdminPanel(); // Refresh after deleting restaurant
          } else if (state is SuccessAddingItemState) {
            _clearItemForm();
            _showSnackBar('Item added successfully',
                backgroundColor: Colors.green);
            _refreshAdminPanel(); // Refresh after adding item
          } else if (state is SuccessDeletingItemState) {
            _showSnackBar('Item deleted successfully',
                backgroundColor: Colors.green);
            _refreshAdminPanel(); // Refresh after deleting item
          } else if (state is SuccessAddingCategoryState) {
            _clearCategoryForm();
            _showSnackBar('Category added successfully',
                backgroundColor: Colors.green);
            _refreshAdminPanel(); // Refresh after adding category
          } else if (state is SuccessDeletingCategoryState) {
            _showSnackBar('Category deleted successfully',
                backgroundColor: Colors.green);
          }
        } catch (e) {
          print('Error in state listener: $e');
        }
      },
      builder: (context, state) {
        try {
          final cubit = AdminPanelCubit.get(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Admin Panel'),
              actions: _buildAppBarActions(),
            ),
            body: _buildBody(cubit, state),
          );
        } catch (e) {
          print('Error in build method: $e');
          return Scaffold(
            appBar: AppBar(
              title: const Text('Admin Panel - Error'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading admin panel: $e'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        setState(() {}); // Trigger rebuild
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  List<Widget> _buildAppBarActions() {
    try {
      return [
        IconButton(
          onPressed: () {
            try {
              Layoutcubit.get(context).changeLanguage();
            } catch (e) {
              print('Error changing language: $e');
            }
          },
          icon: Icon(Icons.language, size: 25.sp),
          tooltip: 'Toggle Language',
        ),
        IconButton(
          onPressed: () => _handleLogout(),
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
        ),
        IconButton(
          onPressed: () {
            try {
              Layoutcubit.get(context).toggletheme();
            } catch (e) {
              print('Error toggling theme: $e');
            }
          },
          icon: Icon(Icons.brightness_6_outlined, size: 25.sp),
          tooltip: 'Toggle Theme',
        ),
      ];
    } catch (e) {
      print('Error building app bar actions: $e');
      return [
        IconButton(
          onPressed: () => _handleLogout(),
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
        ),
      ];
    }
  }

  Widget _buildBody(AdminPanelCubit cubit, AdminPanelStates state) {
    try {
      return Column(
        children: [
          // Custom Tab Bar
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildTabItems(),
              ),
            ),
          ),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                if (mounted) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                }
              },
              children: _buildPages(cubit, state),
            ),
          ),
        ],
      );
    } catch (e) {
      print('Error building body: $e');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $e'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  setState(() {}); // Trigger rebuild
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  List<Widget> _buildTabItems() {
    try {
      return [
        _buildTabItem(0, S.of(context).admin_restaurants),
        _buildTabItem(1, S.of(context).admin_items),
        _buildTabItem(2, S.of(context).admin_categories),
        _buildTabItem(3, S.of(context).admin_orders),
        _buildTabItem(4, S.of(context).restaurant_categories),
        _buildTabItem(5, 'Promocodes'),
        _buildTabItem(6, 'Banners'),
        _buildTabItem(7, 'Cities'),
        _buildTabItem(8, 'Areas'),
      ];
    } catch (e) {
      print('Error building tab items: $e');
      return [
        _buildTabItem(0, 'Restaurants'),
        _buildTabItem(1, 'Items'),
        _buildTabItem(2, 'Categories'),
        _buildTabItem(3, 'Orders'),
        _buildTabItem(6, 'Banners'),
      ];
    }
  }

  List<Widget> _buildPages(AdminPanelCubit cubit, AdminPanelStates state) {
    try {
      return [
        _buildRestaurantsTab(cubit, state),
        _buildItemsTab(cubit, state),
        _buildCategoriesTab(cubit, state),
        _buildAllOrdersTab(cubit, state),
        _buildRestaurantCategoriesTab(cubit, state),
        _buildPromocodesTab(cubit),
        _buildBannersTab(cubit),
        _buildCitiesTab(cubit),
        _buildAreasTab(cubit),
      ];
    } catch (e) {
      print('Error building pages: $e');
      return [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error loading page'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    setState(() {}); // Trigger rebuild
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ];
    }
  }

  Future<void> _handleLogout() async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 74, 26, 15),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ) ??
          false;

      if (confirm && mounted) {
        try {
          // Clear cart items from local storage
          await LocalStorageService.clearCartItems();

          // Clear cart items from cubit
          if (mounted) {
            Layoutcubit.get(context).clearCart();
          }

          // First perform logout
          await FirebaseAuth.instance.signOut();

          // Then navigate only if still mounted
          if (mounted) {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          }
        } catch (e) {
          print("Error during logout: $e");
          _showSnackBar('Error during logout: $e', backgroundColor: Colors.red);
        }
      }
    } catch (e) {
      print("Error in logout dialog: $e");
      _showSnackBar('Error in logout: $e', backgroundColor: Colors.red);
    }
  }

  Widget _buildTabItem(int index, String title) {
    final bool isSelected = index == _selectedTabIndex;
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            _selectedTabIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.r, vertical: 12.r),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 3.r,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantsTab(AdminPanelCubit cubit, AdminPanelStates state) {
    List<Category> restCategories = [];
    try {
      restCategories = Restuarantscubit.get(context)
          .categories
          .where((cat) => cat.en != 'All')
          .toList();
      if (restCategories.isNotEmpty && _selectedRestaurantCategory == null) {
        _selectedRestaurantCategory = restCategories.first;
      }
    } catch (e) {
      print('Error getting restaurant categories: $e');
    }

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
                  onPressed: () {
                    try {
                      cubit.getRestaurants();
                    } catch (e) {
                      print('Error refreshing restaurants: $e');
                      _showSnackBar('Error refreshing restaurants',
                          backgroundColor: Colors.red);
                    }
                  },
                  tooltip: "Refresh",
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
                  if (restCategories.isNotEmpty)
                    DropdownButtonFormField<Category>(
                      value: _selectedRestaurantCategory,
                      items: restCategories.map((cat) {
                        return DropdownMenuItem<Category>(
                          value: cat,
                          child: Text(
                            '${cat.en} / ${cat.ar}',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (cat) {
                        if (mounted) {
                          setState(() {
                            _selectedRestaurantCategory = cat;
                            _restaurantCategoryController.text = cat?.en ?? '';
                            _restaurantCategoryArController.text =
                                cat?.ar ?? '';
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: S.of(context).category,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight,
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return S.of(context).please_fill_all_fields;
                        }
                        return null;
                      },
                    )
                  else
                    Text(
                      'No categories available',
                      style: TextStyle(color: Colors.red, fontSize: 14.sp),
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
                    controller: _outOfAreaFeeController,
                    type: TextInputType.number,
                    label: 'Out of Area Delivery Fee',
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_fill_all_fields;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Restaurant Main Areas (No Out-of-Area Fee)',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Button to load all areas
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            cubit.fetchAllAreas();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Load All Areas from All Cities'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // All areas checkboxes
                  BlocBuilder<AdminPanelCubit, AdminPanelStates>(
                    builder: (context, state) {
                      if (state is LoadingAreasState) {
                        return Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text('Loading all areas...'),
                              ],
                            ),
                          ),
                        );
                      }

                      if (cubit.allAreas.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                'No areas loaded. Click "Load All Areas" button above.',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14.sp),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      // Group areas by city for better display
                      Map<String, List<Area>> areasByCity = {};
                      for (var area in cubit.allAreas) {
                        String cityName = 'Unknown City';
                        try {
                          final city = cubit.cities.firstWhere(
                            (city) => city.id == area.cityId,
                          );
                          cityName = city.name;
                        } catch (e) {
                          // City not found, use default name
                        }
                        if (!areasByCity.containsKey(cityName)) {
                          areasByCity[cityName] = [];
                        }
                        areasByCity[cityName]!.add(area);
                      }

                      return Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header with title and action buttons
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Areas (${cubit.allAreas.length})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedMainAreas.clear();
                                            _selectedMainAreas.addAll(
                                              cubit.allAreas
                                                  .map((area) => area.name),
                                            );
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.h),
                                          textStyle: TextStyle(fontSize: 10.sp),
                                        ),
                                        child: const Text('All Main'),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedMainAreas.clear();
                                          });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.h),
                                          textStyle: TextStyle(fontSize: 10.sp),
                                        ),
                                        child: const Text('Clear'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            // Scrollable areas list
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: 250.h,
                                minHeight: 100.h,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.all(8.r),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: areasByCity.entries.map((entry) {
                                      final cityName = entry.key;
                                      final cityAreas = entry.value;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // City header
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 6.h,
                                              horizontal: 8.w,
                                            ),
                                            margin:
                                                EdgeInsets.only(bottom: 4.h),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              cityName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.sp,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ),
                                          // Areas for this city
                                          ...cityAreas.map((area) {
                                            bool isMainArea = _selectedMainAreas
                                                .contains(area.name);
                                            bool isSecondaryArea =
                                                _selectedSecondaryAreas
                                                    .contains(area.name);
                                            return Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 2.h),
                                              child: Row(
                                                children: [
                                                  // Main area checkbox
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          if (isMainArea) {
                                                            _selectedMainAreas
                                                                .remove(
                                                                    area.name);
                                                          } else {
                                                            _selectedMainAreas
                                                                .add(area.name);
                                                            // Remove from secondary if it was there
                                                            _selectedSecondaryAreas
                                                                .remove(
                                                                    area.name);
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          vertical: 6.h,
                                                          horizontal: 8.w,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isMainArea
                                                              ? Colors.green
                                                                  .withOpacity(
                                                                      0.1)
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.r),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              isMainArea
                                                                  ? Icons
                                                                      .check_box
                                                                  : Icons
                                                                      .check_box_outline_blank,
                                                              size: 18.sp,
                                                              color: isMainArea
                                                                  ? Colors.green
                                                                  : Colors.grey,
                                                            ),
                                                            SizedBox(
                                                                width: 8.w),
                                                            Expanded(
                                                              child: Text(
                                                                '${area.name} (Main)',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      13.sp,
                                                                  fontWeight: isMainArea
                                                                      ? FontWeight
                                                                          .w500
                                                                      : FontWeight
                                                                          .normal,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  // Secondary area checkbox
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          if (isSecondaryArea) {
                                                            _selectedSecondaryAreas
                                                                .remove(
                                                                    area.name);
                                                          } else {
                                                            _selectedSecondaryAreas
                                                                .add(area.name);
                                                            // Remove from main if it was there
                                                            _selectedMainAreas
                                                                .remove(
                                                                    area.name);
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          vertical: 6.h,
                                                          horizontal: 8.w,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isSecondaryArea
                                                              ? Colors.orange
                                                                  .withOpacity(
                                                                      0.1)
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      4.r),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              isSecondaryArea
                                                                  ? Icons
                                                                      .check_box
                                                                  : Icons
                                                                      .check_box_outline_blank,
                                                              size: 18.sp,
                                                              color:
                                                                  isSecondaryArea
                                                                      ? Colors
                                                                          .orange
                                                                      : Colors
                                                                          .grey,
                                                            ),
                                                            SizedBox(
                                                                width: 8.w),
                                                            Expanded(
                                                              child: Text(
                                                                '${area.name} (Secondary)',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      13.sp,
                                                                  fontWeight: isSecondaryArea
                                                                      ? FontWeight
                                                                          .w500
                                                                      : FontWeight
                                                                          .normal,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          SizedBox(height: 8.h),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            // Status message
                            if (_selectedMainAreas.isEmpty &&
                                _selectedSecondaryAreas.isEmpty)
                              Text(
                                'Please select at least one main area',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            if (_selectedMainAreas.isNotEmpty ||
                                _selectedSecondaryAreas.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_selectedMainAreas.isNotEmpty)
                                    Text(
                                      'Main Areas: ${_selectedMainAreas.length}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  if (_selectedSecondaryAreas.isNotEmpty)
                                    Text(
                                      'Secondary Areas: ${_selectedSecondaryAreas.length}',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final imageFile = await cubit.pickImage();
                            if (imageFile != null && mounted) {
                              setState(() {
                                _restaurantImageFile = imageFile;
                              });
                            }
                          } catch (e) {
                            print("Error selecting restaurant image: $e");
                            _showSnackBar('Error selecting image: $e',
                                backgroundColor: Colors.red);
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
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Existing Restaurants',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            if (cubit.restaurants.isEmpty)
              const Center(
                child: Text("No restaurants found"),
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
                    onEdit: () => _showEditRestaurantDialog(cubit, restaurant),
                  );
                },
              ),
            SizedBox(height: 16.h),
            if (false)
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("restaurants")
                    .doc(selectedRestaurantId)
                    .collection("menu_categories")
                    .orderBy("createdAt",
                        descending: true) // Order by newest first
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print("Error loading menu categories: ${snapshot.error}");
                    // Fallback to the in-memory data if we can't load from Firestore
                    try {
                      final restaurant = cubit.restaurants.firstWhere(
                        (r) => r.id == selectedRestaurantId!,
                        orElse: () => throw Exception("Restaurant not found"),
                      );

                      final menuCategories = restaurant.menuCategories ?? [];
                      final menuCategoriesAr =
                          restaurant.menuCategoriesAr ?? [];

                      if (menuCategories.isEmpty) {
                        return const Center(
                          child: Text(
                              "No menu categories found for this restaurant"),
                        );
                      }

                      return _buildCategoriesList(
                        cubit,
                        menuCategories,
                        menuCategoriesAr,
                      );
                    } catch (e) {
                      print("Error accessing fallback data: $e");
                      return const Center(
                        child: Text("Error loading categories"),
                      );
                    }
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    // Check in-memory data as fallback
                    try {
                      final restaurant = cubit.restaurants.firstWhere(
                        (r) => r.id == selectedRestaurantId!,
                        orElse: () => throw Exception("Restaurant not found"),
                      );

                      final menuCategories = restaurant.menuCategories ?? [];

                      if (menuCategories.isEmpty) {
                        return const Center(
                          child: Text(
                              "No menu categories found for this restaurant"),
                        );
                      }

                      return _buildCategoriesList(
                        cubit,
                        restaurant.menuCategories ?? [],
                        restaurant.menuCategoriesAr ?? [],
                      );
                    } catch (e) {
                      print("Error accessing fallback data: $e");
                      return const Center(
                        child: Text("No menu categories found"),
                      );
                    }
                  }

                  // Process subcollection data
                  final List<String> menuCategories = [];
                  final List<String> menuCategoriesAr = [];
                  final List<String> categoryIds = [];

                  try {
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final categoryName = data['name']?.toString();

                      if (categoryName != null && categoryName.isNotEmpty) {
                        menuCategories.add(categoryName);
                        menuCategoriesAr
                            .add(data['nameAr']?.toString() ?? categoryName);
                        categoryIds.add(doc.id);
                      }
                    }
                  } catch (e) {
                    print("Error processing subcollection data: $e");
                    return const Center(
                      child: Text("Error processing categories data"),
                    );
                  }

                  return _buildCategoriesListFromSubcollection(
                    cubit,
                    menuCategories,
                    menuCategoriesAr,
                    categoryIds,
                  );
                },
              )
            else
              Center(
                child: Text(S.of(context).select_restaurant_to_view_items),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to build categories list from in-memory data
  Widget _buildCategoriesList(
    AdminPanelCubit cubit,
    List<String> menuCategories,
    List<String> menuCategoriesAr,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuCategories.length,
      itemBuilder: (context, index) {
        if (index >= menuCategories.length) {
          return const SizedBox.shrink();
        }

        final categoryName = menuCategories[index];
        // Skip the "All" category which is just for UI filtering
        if (categoryName.toLowerCase() == "all") {
          return const SizedBox.shrink();
        }

        // Get the Arabic equivalent if available
        final categoryNameAr = index < menuCategoriesAr.length
            ? menuCategoriesAr[index]
            : categoryName;

        return ListTile(
          title: Text(categoryName),
          subtitle: Text(categoryNameAr),
          trailing: categoryName.toLowerCase() != "uncategorized"
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditMenuCategoryDialog(
                        cubit,
                        selectedRestaurantId!,
                        categoryName,
                        categoryNameAr,
                      ),
                      tooltip: "Edit Category",
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try {
                          await cubit.deleteMenuCategory(
                            restaurantId: selectedRestaurantId!,
                            categoryName: categoryName,
                          );
                          _showSnackBar("Category deleted successfully",
                              backgroundColor: Colors.green);
                        } catch (e) {
                          print("Error deleting category: $e");
                          _showSnackBar("Error deleting category",
                              backgroundColor: Colors.red);
                        }
                      },
                      tooltip: "Delete Category",
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  // Helper method to build categories list from subcollection data
  Widget _buildCategoriesListFromSubcollection(
    AdminPanelCubit cubit,
    List<String> menuCategories,
    List<String> menuCategoriesAr,
    List<String> categoryIds,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menuCategories.length,
      itemBuilder: (context, index) {
        if (index >= menuCategories.length) {
          return const SizedBox.shrink();
        }

        final categoryName = menuCategories[index];
        // Skip the "All" category which is just for UI filtering
        if (categoryName.toLowerCase() == "all") {
          return const SizedBox.shrink();
        }

        // Get the Arabic equivalent
        final categoryNameAr = index < menuCategoriesAr.length
            ? menuCategoriesAr[index]
            : categoryName;

        final categoryId = index < categoryIds.length ? categoryIds[index] : "";

        return ListTile(
          title: Text(categoryName),
          subtitle: Text(categoryNameAr),
          trailing: categoryName.toLowerCase() != "uncategorized"
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditMenuCategoryDialog(
                        cubit,
                        selectedRestaurantId!,
                        categoryName,
                        categoryNameAr,
                        categoryId: categoryId,
                      ),
                      tooltip: "Edit Category",
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try {
                          // Delete directly from subcollection using the document ID
                          if (categoryId.isNotEmpty) {
                            // First delete from subcollection
                            await FirebaseFirestore.instance
                                .collection("restaurants")
                                .doc(selectedRestaurantId)
                                .collection("menu_categories")
                                .doc(categoryId)
                                .delete();

                            // Then also update through cubit for arrays (backward compatibility)
                            await cubit.deleteMenuCategory(
                              restaurantId: selectedRestaurantId!,
                              categoryName: categoryName,
                            );
                          } else {
                            // Fall back to just the cubit method if ID is not available
                            await cubit.deleteMenuCategory(
                              restaurantId: selectedRestaurantId!,
                              categoryName: categoryName,
                            );
                          }

                          _showSnackBar("Category deleted successfully",
                              backgroundColor: Colors.green);
                        } catch (e) {
                          print("Error deleting category: $e");
                          _showSnackBar("Error deleting category",
                              backgroundColor: Colors.red);
                        }
                      },
                      tooltip: "Delete Category",
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildRestaurantCategoriesTab(
    AdminPanelCubit cubit,
    AdminPanelStates state,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Restaurant Category",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
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
                        return S.of(context).please_fill_all_fields;
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
                            if (imageFile != null && mounted) {
                              setState(() {
                                _categoryImageFile = imageFile;
                              });
                            }
                          } catch (e) {
                            print("Error selecting category image: $e");
                            _showSnackBar('Error selecting image: $e',
                                backgroundColor: Colors.red);
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
                          onPressed: _submitRestaurantCategoryForm,
                          child: Text(S.of(context).add_category),
                        ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Restaurant Categories",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            _buildRestaurantCategoriesListWidget(),
          ],
        ),
      ),
    );
  }

  // Use a StatefulBuilder to manage the categories list state separately
  Widget _buildRestaurantCategoriesListWidget() {
    return StatefulBuilder(
      builder: (context, setStateLocal) {
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('restaurants_categories')
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              print("Error loading restaurant categories: ${snapshot.error}");
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text("Error: ${snapshot.error}"),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setStateLocal(() {}); // Trigger local rebuild
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.category_outlined,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No restaurant categories found"),
                      SizedBox(height: 8),
                      Text("Add your first category above",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }

            try {
              final docs = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  // Extra safety check for index bounds
                  if (index < 0 || index >= docs.length) {
                    return const SizedBox.shrink();
                  }

                  try {
                    final doc = docs[index];
                    if (doc.data() == null) {
                      return const SizedBox.shrink();
                    }

                    final data = doc.data() as Map<String, dynamic>? ?? {};

                    // Validate document has required fields
                    final englishName = data['en']?.toString();
                    final arabicName = data['ar']?.toString();

                    if (englishName == null || englishName.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: ListTile(
                        leading: _buildCategoryLeading(data['img']?.toString()),
                        title: Text(
                          englishName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(arabicName ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _showEditRestaurantCategoryDialog(
                                      doc.id,
                                      englishName,
                                      arabicName ?? '',
                                      data['img']?.toString()),
                              tooltip: "Edit Category",
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteRestaurantCategory(
                                  doc.id, englishName, setStateLocal),
                              tooltip: "Delete Category",
                            ),
                          ],
                        ),
                      ),
                    );
                  } catch (e) {
                    print("Error rendering category item at index $index: $e");
                    return const SizedBox.shrink();
                  }
                },
              );
            } catch (e) {
              print("Error building categories list: $e");
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text("Error displaying categories"),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setStateLocal(() {}); // Trigger local rebuild
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  // Safe delete method for restaurant categories with local state update
  Future<void> _deleteRestaurantCategory(
      String docId, String categoryName, StateSetter setStateLocal) async {
    try {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Delete Category"),
          content: Text("Are you sure you want to delete '$categoryName'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(S.of(context).delete),
            ),
          ],
        ),
      );

      if (confirm != true || !mounted) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        await FirebaseFirestore.instance
            .collection('restaurants_categories')
            .doc(docId)
            .delete();

        _safeNavigatorPop(context);
        _showSnackBar("Category deleted successfully",
            backgroundColor: Colors.green);

        // Refresh the local widget and admin panel
        setStateLocal(() {});
        await _refreshAdminPanel();
      } catch (e) {
        print("Error deleting restaurant category: $e");
        _safeNavigatorPop(context);
        _showSnackBar("Error deleting category: $e",
            backgroundColor: Colors.red);
      }
    } catch (e) {
      print("Error in delete restaurant category dialog: $e");
      _showSnackBar("Error: $e", backgroundColor: Colors.red);
    }
  }

  // Add this method to handle adding a restaurant category with proper image upload
  void _submitRestaurantCategoryForm() async {
    if (!mounted) return;

    if (_categoryFormKey.currentState?.validate() != true) {
      _showSnackBar("Please fill all required fields",
          backgroundColor: Colors.red);
      return;
    }

    final englishName = _categoryNameController.text.trim();
    final arabicName = _categoryNameArController.text.trim();

    if (englishName.isEmpty || arabicName.isEmpty) {
      _showSnackBar("Please fill all required fields",
          backgroundColor: Colors.red);
      return;
    }

    try {
      print("=== STARTING RESTAURANT CATEGORY ADDITION ===");
      print("📝 English Name: $englishName");
      print("📝 Arabic Name: $arabicName");
      print(
          "📷 Image File: ${_categoryImageFile?.path ?? 'No image selected'}");

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Check if category already exists
      print("🔍 Checking if category already exists...");
      final existingQuery = await FirebaseFirestore.instance
          .collection('restaurants_categories')
          .where('en', isEqualTo: englishName)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        _safeNavigatorPop(context);
        _showSnackBar("Category '$englishName' already exists",
            backgroundColor: Colors.orange);
        return;
      }
      print("✅ Category name is unique");

      // Check authentication
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _safeNavigatorPop(context);
        _showSnackBar("User not authenticated. Please login again.",
            backgroundColor: Colors.red);
        return;
      }
      print("✅ User authenticated: ${currentUser.uid}");

      // Validate image file if provided
      if (_categoryImageFile != null) {
        print("📸 Validating image file...");
        if (!_categoryImageFile!.existsSync()) {
          _safeNavigatorPop(context);
          _showSnackBar("Selected image file not found",
              backgroundColor: Colors.red);
          return;
        }

        final fileSize = await _categoryImageFile!.length();
        print("📏 Image file size: ${(fileSize / 1024).toStringAsFixed(2)} KB");

        if (fileSize > 10 * 1024 * 1024) {
          _safeNavigatorPop(context);
          _showSnackBar("Image too large. Maximum size is 10MB",
              backgroundColor: Colors.red);
          return;
        }
        print("✅ Image file validation passed");
      }

      // Use the cubit method to add restaurant category with image upload
      print("🚀 Calling AdminPanelCubit.addRestaurantCategory...");
      final cubit = AdminPanelCubit.get(context);
      await cubit.addRestaurantCategory(
        englishName: englishName,
        arabicName: arabicName,
        imageFile: _categoryImageFile,
      );

      _safeNavigatorPop(context);

      // Clear form
      _categoryNameController.clear();
      _categoryNameArController.clear();
      if (mounted) {
        setState(() {
          _categoryImageFile = null;
        });
      }

      print("✅ Restaurant category added successfully!");
      _showSnackBar("Category added successfully",
          backgroundColor: Colors.green);

      // Refresh the admin panel
      await _refreshAdminPanel();
      print("🔄 Admin panel refreshed");
      print("=== RESTAURANT CATEGORY ADDITION COMPLETED ===");
    } catch (e, stackTrace) {
      print("💥 ERROR ADDING RESTAURANT CATEGORY:");
      print("   Type: ${e.runtimeType}");
      print("   Message: $e");
      print("   Stack trace: $stackTrace");

      _safeNavigatorPop(context);

      String errorMessage = "Error adding category";
      if (e is FirebaseException) {
        switch (e.code) {
          case 'permission-denied':
            errorMessage =
                "Permission denied. Please check your access rights.";
            print(
                "🔧 SOLUTION: Check Firebase Authentication and Firestore security rules");
            break;
          case 'network-request-failed':
            errorMessage =
                "Network error. Please check your internet connection.";
            break;
          case 'storage/unauthorized':
            errorMessage =
                "Storage access denied. Please check Firebase Storage rules.";
            print("🔧 SOLUTION: Update Firebase Storage security rules");
            break;
          case 'storage/object-not-found':
            errorMessage = "File not found during upload.";
            break;
          case 'storage/quota-exceeded':
            errorMessage = "Storage quota exceeded.";
            break;
          case 'storage/unauthenticated':
            errorMessage = "Storage authentication failed.";
            print("🔧 SOLUTION: Check Firebase Authentication status");
            break;
          case 'storage/retry-limit-exceeded':
            errorMessage = "Upload retry limit exceeded. Try again later.";
            break;
          case 'storage/invalid-format':
            errorMessage = "Invalid file format. Please select a valid image.";
            break;
          default:
            errorMessage = "Firebase error: ${e.code} - ${e.message}";
        }
      } else {
        errorMessage = "Error: $e";
      }

      print("❌ User error message: $errorMessage");
      _showSnackBar(errorMessage, backgroundColor: Colors.red);
      print("=== RESTAURANT CATEGORY ADDITION FAILED ===");
    }
  }

  // Method to refresh the entire admin panel
  Future<void> _refreshAdminPanel() async {
    if (!mounted || _isRefreshing) return;

    _isRefreshing = true;
    try {
      print("Starting admin panel refresh...");

      // Refresh restaurants data
      final adminCubit = AdminPanelCubit.get(context);
      await adminCubit.getRestaurants();

      // Refresh restaurant categories data
      try {
        final restCubit = Restuarantscubit.get(context);
        await restCubit.initializeData();
      } catch (e) {
        print("Error refreshing restaurant categories cubit: $e");
      }

      // Refresh orders
      await _fetchAllOrders();

      // Refresh promocodes
      try {
        await adminCubit.fetchPromocodes();
      } catch (e) {
        print("Error refreshing promocodes: $e");
      }

      // Force UI rebuild to reflect all changes
      if (mounted) {
        setState(() {
          // This will trigger a rebuild of the entire admin panel
        });
      }

      print("Admin panel refreshed successfully");
    } catch (e) {
      print("Error refreshing admin panel: $e");
    }
  }

  Widget _buildPromocodesTab(AdminPanelCubit cubit) {
    // Controllers defined outside StatefulBuilder to persist
    final TextEditingController codeController = TextEditingController();
    final TextEditingController discountController = TextEditingController();

    // Remove the automatic fetch that causes refresh loop
    // Only fetch when explicitly requested via refresh button

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Generate Promos section
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Generate Promo Codes",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),

                // Code input
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: codeController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: "Promo Code",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value?.isEmpty ?? true)
                            ? "Enter promo code"
                            : null,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          // Generate random 10-digit alphanumeric code
                          const String chars =
                              'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                          final Random random = Random();
                          String randomCode = '';

                          // Generate a truly random 10-digit code
                          for (int i = 0; i < 10; i++) {
                            randomCode += chars[random.nextInt(chars.length)];
                          }

                          codeController.text = randomCode;
                        } catch (e) {
                          print('Error generating code: $e');
                          _showSnackBar('Error generating code',
                              backgroundColor: Colors.red);
                        }
                      },
                      child: const Text("Generate"),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Discount amount input
                TextFormField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Discount Amount",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value?.isEmpty ?? true) ? "Enter amount" : null,
                ),
                SizedBox(height: 20.h),

                // Add promo button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                    ),
                    onPressed: () async {
                      try {
                        // Validate inputs
                        final code = codeController.text.trim();
                        final discountText = discountController.text.trim();

                        if (code.isEmpty || discountText.isEmpty) {
                          _showSnackBar(S.of(context).please_fill_all_fields,
                              backgroundColor: Colors.red);
                          return;
                        }

                        double discount;
                        try {
                          discount = double.parse(discountText);
                        } catch (e) {
                          _showSnackBar("Please enter a valid number",
                              backgroundColor: Colors.red);
                          return;
                        }

                        // Show loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogContext) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );

                        try {
                          // Add promocode using cubit
                          await cubit.addPromocode(
                              code: code, discount: discount);

                          // Clear fields
                          codeController.clear();
                          discountController.clear();

                          // Close loading dialog
                          _safeNavigatorPop(context);

                          _showSnackBar("Promocode added successfully",
                              backgroundColor: Colors.green);

                          // Refresh the admin panel
                          await _refreshAdminPanel();
                        } catch (e) {
                          print('Error adding promocode: $e');
                          // Close loading dialog
                          _safeNavigatorPop(context);

                          _showSnackBar("Error adding promocode: $e",
                              backgroundColor: Colors.red);
                        }
                      } catch (e) {
                        print('Error in promocode submission: $e');
                        _showSnackBar("Error: $e", backgroundColor: Colors.red);
                      }
                    },
                    child: const Text("Add Promo"),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Current promocodes section
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Current Promo Codes",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        try {
                          cubit.fetchPromocodes();
                        } catch (e) {
                          print('Error refreshing promocodes: $e');
                          _showSnackBar('Error refreshing promocodes',
                              backgroundColor: Colors.red);
                        }
                      },
                      tooltip: "Refresh Promocodes",
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // Promo list based on cubit state
                Builder(
                  builder: (context) {
                    try {
                      final state = cubit.state;
                      if (state is LoadingPromocodesState) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ErrorLoadingPromocodesState) {
                        return Center(
                          child: Text(
                              "Error loading promocodes: ${(state).error}"),
                        );
                      } else if (cubit.promocodes.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.r),
                            child: const Text("No promocodes available"),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cubit.promocodes.length,
                          itemBuilder: (context, index) {
                            if (index >= cubit.promocodes.length) {
                              return const SizedBox.shrink();
                            }

                            final promo = cubit.promocodes[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: ListTile(
                                title: Text(
                                  promo.code,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${promo.discount} EGP discount',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    try {
                                      // Confirm delete
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: const Text("Delete Promocode"),
                                          content: const Text(
                                              "Are you sure you want to delete this promocode?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                dialogContext,
                                                false,
                                              ),
                                              child: Text(S.of(context).cancel),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                dialogContext,
                                                true,
                                              ),
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: Text(S.of(context).delete),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true && mounted) {
                                        try {
                                          await cubit
                                              .deletePromocode(promo.code);
                                          _showSnackBar("Promocode deleted",
                                              backgroundColor: Colors.green);

                                          // Refresh the admin panel
                                          await _refreshAdminPanel();
                                        } catch (e) {
                                          print('Error deleting promocode: $e');
                                          _showSnackBar(
                                              "Error deleting promocode",
                                              backgroundColor: Colors.red);
                                        }
                                      }
                                    } catch (e) {
                                      print('Error in delete dialog: $e');
                                      _showSnackBar("Error: $e",
                                          backgroundColor: Colors.red);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }
                    } catch (e) {
                      print('Error building promocodes list: $e');
                      return Center(
                        child: Text("Error loading promocodes: $e"),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to safely get an image provider with comprehensive fallback handling
  ImageProvider _getImageProvider(String? imageUrl) {
    try {
      // Return default if URL is null or empty
      if (imageUrl == null || imageUrl.isEmpty) {
        return const AssetImage('assets/images/categories/all.png');
      }

      // Handle different types of image URLs
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        // Network image with error handling
        return NetworkImage(imageUrl);
      } else if (imageUrl.startsWith('assets/')) {
        // Asset image
        return AssetImage(imageUrl);
      } else if (imageUrl.startsWith('/') || imageUrl.contains('\\')) {
        // File path (shouldn't happen in production but handling it)
        try {
          return FileImage(File(imageUrl));
        } catch (e) {
          print("Error loading file image: $e");
          return const AssetImage('assets/images/categories/all.png');
        }
      } else {
        // Fallback for unknown format
        print("Unknown image URL format: $imageUrl");
        return const AssetImage('assets/images/categories/all.png');
      }
    } catch (e) {
      print("Error in _getImageProvider for URL '$imageUrl': $e");
      // Always return a safe fallback
      return const AssetImage('assets/images/categories/all.png');
    }
  }

  // Helper method to build category leading widget safely
  Widget _buildCategoryLeading(String? imageUrl) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
      ),
      child: ClipOval(
        child: _buildCategoryImageWidget(imageUrl),
      ),
    );
  }

  Widget _buildCategoryImageWidget(String? imageUrl) {
    try {
      if (imageUrl == null || imageUrl.isEmpty) {
        return const Icon(
          Icons.category,
          color: Colors.blue,
          size: 24,
        );
      }

      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        // Network image from Firebase Storage
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print("Error loading network category image '$imageUrl': $error");
            return const Icon(
              Icons.category,
              color: Colors.red,
              size: 24,
            );
          },
        );
      } else if (imageUrl.startsWith('assets/')) {
        // Asset image
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading asset category image '$imageUrl': $error");
            return const Icon(
              Icons.category,
              color: Colors.orange,
              size: 24,
            );
          },
        );
      } else {
        // Try as asset path
        return Image.asset(
          'assets/images/categories/${imageUrl.toLowerCase()}.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading category image '$imageUrl': $error");
            return const Icon(
              Icons.category,
              color: Colors.grey,
              size: 24,
            );
          },
        );
      }
    } catch (e) {
      print("Exception in _buildCategoryImageWidget for '$imageUrl': $e");
      return const Icon(
        Icons.error,
        color: Colors.red,
        size: 24,
      );
    }
  }

  void _submitRestaurantForm(AdminPanelCubit cubit) async {
    if (_restaurantFormKey.currentState?.validate() != true) {
      _showSnackBar("Please fill all required fields",
          backgroundColor: Colors.red);
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Validate that at least main areas are selected
      if (_selectedMainAreas.isEmpty) {
        _safeNavigatorPop(context);
        _showSnackBar("Please select at least one main area",
            backgroundColor: Colors.red);
        return;
      }

      print("Selected main areas: $_selectedMainAreas");
      print("Selected secondary areas: $_selectedSecondaryAreas");

      // Let the cubit handle the image upload
      await cubit.addRestaurant(
        name: _restaurantNameController.text.trim(),
        nameAr: _restaurantNameArController.text.trim(),
        category: _selectedRestaurantCategory?.en ?? '',
        categoryAr: _selectedRestaurantCategory?.ar ?? '',
        deliveryFee: _deliveryFeeController.text.trim(),
        deliveryTime: _deliveryTimeController.text.trim(),
        imageFile:
            _restaurantImageFile, // Pass the file, let cubit handle upload
        categories: [],
        mainAreas: _selectedMainAreas, // Pass main areas
        secondaryAreas: _selectedSecondaryAreas, // Pass secondary areas
        outOfAreaFee: _outOfAreaFeeController.text.trim(),
      );

      // Close loading dialog
      _safeNavigatorPop(context);

      // Clear form and show success message
      _clearRestaurantForm();
      _showSnackBar("Restaurant added successfully",
          backgroundColor: Colors.green);

      // Refresh the admin panel
      await _refreshAdminPanel();
    } catch (e) {
      print('Error adding restaurant: $e');
      // Close loading dialog
      _safeNavigatorPop(context);

      // Show error message
      _showSnackBar("Error adding restaurant: $e", backgroundColor: Colors.red);
    }
  }

  void _deleteRestaurant(AdminPanelCubit cubit, String restaurantId) {
    try {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Delete Restaurant"),
          content: const Text(
              "Are you sure you want to delete this restaurant? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                // Close confirmation dialog first to prevent deactivated widget error
                Navigator.pop(dialogContext);

                if (!mounted) return;

                // Store the parent context for later use
                final BuildContext parentContext = context;

                // Reset state if we're deleting the currently selected restaurant
                if (selectedRestaurantId == restaurantId && mounted) {
                  setState(() {
                    selectedRestaurantId = null;
                    selectedCategories = [];
                    _itemCategoryController.clear();
                  });
                }

                // Show loading indicator
                showDialog(
                  context: parentContext,
                  barrierDismissible: false,
                  builder: (loadingContext) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                try {
                  await cubit.deleteRestaurant(restaurantId);

                  // Check if still mounted before using context
                  if (!mounted) return;

                  // Close loading dialog if possible
                  _safeNavigatorPop(parentContext);

                  // Show success message if still mounted
                  _showSnackBar("Restaurant deleted successfully",
                      backgroundColor: Colors.green);

                  // Refresh the admin panel
                  await _refreshAdminPanel();
                } catch (e) {
                  print('Error deleting restaurant: $e');
                  // Check if still mounted before using context
                  if (!mounted) return;

                  // Close loading dialog if possible
                  _safeNavigatorPop(parentContext);

                  // Show error message if still mounted
                  _showSnackBar("Error deleting restaurant: ${e.toString()}",
                      backgroundColor: Colors.red);
                }
              },
              child: Text(S.of(context).delete),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error showing delete dialog: $e');
      _showSnackBar('Error: $e', backgroundColor: Colors.red);
    }
  }

  void _deleteItem(AdminPanelCubit cubit, String restaurantId, String itemId) {
    try {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Delete Item"),
          content: const Text(
              "Are you sure you want to delete this item? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                // Close confirmation dialog first to prevent deactivated widget error
                Navigator.pop(dialogContext);

                if (!mounted) return;

                // Show loading indicator using the parent context
                final BuildContext parentContext = context;
                showDialog(
                  context: parentContext,
                  barrierDismissible: false,
                  builder: (loadingContext) {
                    return const Center(child: CircularProgressIndicator());
                  },
                );

                try {
                  await cubit.deleteItem(
                    restaurantId: restaurantId,
                    itemId: itemId,
                  );

                  // Check if still mounted before using context
                  if (!mounted) return;

                  // Close loading dialog if possible
                  _safeNavigatorPop(parentContext);

                  // Show success message if still mounted
                  _showSnackBar("Item deleted successfully",
                      backgroundColor: Colors.green);

                  // Refresh the admin panel
                  await _refreshAdminPanel();
                } catch (e) {
                  print('Error deleting item: $e');
                  // Check if still mounted before using context
                  if (!mounted) return;

                  // Close loading dialog if possible
                  _safeNavigatorPop(parentContext);

                  // Show error message if still mounted
                  _showSnackBar("Error deleting item: ${e.toString()}",
                      backgroundColor: Colors.red);
                }
              },
              child: Text(S.of(context).delete),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error showing delete item dialog: $e');
      _showSnackBar('Error: $e', backgroundColor: Colors.red);
    }
  }

  void _clearRestaurantForm() {
    try {
      _restaurantNameController.clear();
      _restaurantNameArController.clear();
      _restaurantCategoryController.clear();
      _restaurantCategoryArController.clear();
      _deliveryFeeController.clear();
      _deliveryTimeController.clear();
      _outOfAreaFeeController.clear();
      if (mounted) {
        setState(() {
          _restaurantImageFile = null;
          _selectedRestaurantCityId = null;
          _selectedMainAreas.clear();
          _selectedSecondaryAreas.clear();
        });
      }
    } catch (e) {
      print('Error clearing restaurant form: $e');
    }
  }

  void _clearItemForm() {
    try {
      _itemNameController.clear();
      _itemNameArController.clear();
      _itemDescriptionController.clear();
      _itemDescriptionArController.clear();
      _itemPriceController.clear();
      _itemCategoryController.clear();
      if (mounted) {
        setState(() {
          _itemImageFile = null;
          selectedCategories = [];
        });
      }
    } catch (e) {
      print('Error clearing item form: $e');
    }
  }

  void _clearCategoryForm() {
    try {
      _categoryNameController.clear();
      _categoryNameArController.clear();
    } catch (e) {
      print('Error clearing category form: $e');
    }
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

      _showSnackBar("Test restaurant added with default image",
          backgroundColor: Colors.green);
    } catch (e) {
      print("Error adding test restaurant: $e");
      _showSnackBar("Error adding test restaurant: $e",
          backgroundColor: Colors.red);
    }
  }

  // This is for the multiple categories selection in the admin panel
  Widget _buildCategorySelectionUI(List<String> availableMenuCategories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).select_category,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Primary Category",
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primaryDark
                    : AppColors.primaryLight,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primaryDark
                    : AppColors.primaryLight,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primaryDark
                    : AppColors.primaryLight,
                width: 2.0,
              ),
            ),
            labelStyle: TextStyle(color: Theme.of(context).primaryColor),
          ),
          value: availableMenuCategories.contains(_itemCategoryController.text)
              ? _itemCategoryController.text
              : (availableMenuCategories.isNotEmpty
                  ? availableMenuCategories.first
                  : null),
          items: availableMenuCategories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(
                category,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (mounted && newValue != null) {
              setState(() {
                _itemCategoryController.text = newValue;
                // Clear selected categories when changing the main category
                selectedCategories = [];
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildAllOrdersTab(AdminPanelCubit cubit, AdminPanelStates state) {
    // Create a reference to the OrderCubit for updating statuses
    OrderCubit? orderCubit;
    try {
      orderCubit = OrderCubit.get(context);
    } catch (e) {
      print('Error getting OrderCubit: $e');
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      S.of(context).admin_orders,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      try {
                        _fetchAllOrders();
                      } catch (e) {
                        print('Error in refresh orders: $e');
                        _showSnackBar('Error refreshing orders',
                            backgroundColor: Colors.red);
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(S.of(context).refresh),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (isLoadingOrders)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Loading orders..."),
                      ],
                    ),
                  ),
                )
              else if (allOrders.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 70.sp, color: Colors.grey),
                        SizedBox(height: 20.h),
                        Text(
                          S.of(context).no_orders_found,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () {
                            try {
                              _fetchAllOrders();
                            } catch (e) {
                              print('Error refreshing orders: $e');
                              _showSnackBar('Error refreshing orders',
                                  backgroundColor: Colors.red);
                            }
                          },
                          child: Text(S.of(context).refresh),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      try {
                        await _fetchAllOrders();
                      } catch (e) {
                        print('Error in pull to refresh: $e');
                        _showSnackBar('Error refreshing orders',
                            backgroundColor: Colors.red);
                      }
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: allOrders.length,
                      itemBuilder: (context, index) {
                        if (index < 0 || index >= allOrders.length) {
                          return const SizedBox.shrink();
                        }

                        try {
                          final order = allOrders[index];

                          return OrderCardAdmin(
                            model: order,
                            onStatusChange: (orderId, newStatus) async {
                              await _handleOrderStatusChange(
                                  orderCubit, orderId, newStatus, index);
                            },
                          );
                        } catch (e) {
                          print('Error rendering order at index $index: $e');
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            child: ListTile(
                              leading:
                                  const Icon(Icons.error, color: Colors.red),
                              title: const Text('Error loading order'),
                              subtitle: Text('Index: $index'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  if (mounted && index < allOrders.length) {
                                    setState(() {
                                      allOrders.removeAt(index);
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Separate method to handle order status changes safely
  Future<void> _handleOrderStatusChange(OrderCubit? orderCubit, String orderId,
      String newStatus, int index) async {
    if (orderCubit == null) {
      _showSnackBar("Error: Unable to update order status",
          backgroundColor: Colors.red);
      return;
    }

    if (!mounted) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Update the order status
      await orderCubit.updateOrderStatus(orderId, newStatus);

      // Check if widget is still mounted before updating state
      if (!mounted) return;

      // Update the order in the allOrders list
      if (mounted && index >= 0 && index < allOrders.length) {
        setState(() {
          allOrders[index].status = newStatus;
        });
      }

      // Close loading dialog if context is still valid
      _safeNavigatorPop(context);

      // Show success message if context is still valid
      _showSnackBar("Order status updated to $newStatus",
          backgroundColor: Colors.green);
    } catch (error) {
      print('Error updating order status: $error');

      // Close loading dialog if context is still valid
      _safeNavigatorPop(context);

      // Show error message if context is still valid
      String errorMessage = "Error updating order status";
      if (error is FirebaseException) {
        errorMessage = "Firebase error: ${error.message}";
      } else {
        errorMessage = "Error: $error";
      }

      _showSnackBar(errorMessage, backgroundColor: Colors.red);
    }
  }

  void _submitCategoryForm(AdminPanelCubit cubit) {
    if (_categoryFormKey.currentState?.validate() == true &&
        selectedRestaurantId != null) {
      try {
        cubit.addMenuCategory(
          restaurantId: selectedRestaurantId!,
          categoryName: _categoryNameController.text,
          categoryNameAr: _categoryNameArController.text,
          img: '', // No image for menu categories
        );
        _categoryNameController.clear();
        _categoryNameArController.clear();

        // Refresh the admin panel after adding category
        _refreshAdminPanel();
      } catch (e) {
        print('Error submitting category form: $e');
        _showSnackBar('Error adding category: $e', backgroundColor: Colors.red);
      }
    }
  }

  // Enhanced debug method to test image upload functionality for all folders
  Future<void> _testImageUpload() async {
    try {
      print("=== TESTING IMAGE UPLOAD FUNCTIONALITY ===");

      // Show selection dialog for which folder to test
      final String? selectedFolder = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Test Image Upload"),
          content: const Text("Select which folder to test:"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'restaurants'),
              child: const Text('Restaurants'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'items'),
              child: const Text('Items'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, 'restaurant_categories'),
              child: const Text('Categories'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (selectedFolder == null) return;

      print("Testing folder: $selectedFolder");

      final cubit = AdminPanelCubit.get(context);
      final picker = ImagePicker();

      // Test picking an image
      print("Opening image picker...");
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print("✅ Image picked successfully!");
        print("📍 File path: ${pickedFile.path}");
        print("📄 File name: ${pickedFile.name}");

        final file = File(pickedFile.path);
        final fileExists = await file.exists();
        final fileSize = fileExists ? await file.length() : 0;

        print("📊 File exists: $fileExists");
        print(
            "📏 File size: $fileSize bytes (${(fileSize / 1024).toStringAsFixed(2)} KB)");

        if (!fileExists) {
          _showSnackBar("❌ Selected file does not exist!",
              backgroundColor: Colors.red);
          return;
        }

        if (fileSize == 0) {
          _showSnackBar("❌ Selected file is empty!",
              backgroundColor: Colors.red);
          return;
        }

        // Show loading dialog with progress
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text("Uploading to $selectedFolder folder..."),
                const SizedBox(height: 8),
                const Text("Check console for detailed progress"),
              ],
            ),
          ),
        );

        try {
          print("🚀 Starting upload to Firebase Storage...");
          print("📂 Target folder: $selectedFolder");

          // Test upload with enhanced logging
          final uploadedUrl = await cubit.uploadImage(file, selectedFolder);

          _safeNavigatorPop(context);

          if (uploadedUrl.isNotEmpty) {
            print("✅ Upload successful!");
            print("🔗 Download URL: $uploadedUrl");
            print("📂 Folder structure created: $selectedFolder/");

            // Show success dialog with details
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("✅ Upload Successful!"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📂 Folder: $selectedFolder"),
                    const SizedBox(height: 8),
                    Text("📏 Size: ${(fileSize / 1024).toStringAsFixed(2)} KB"),
                    const SizedBox(height: 8),
                    const Text("🔗 URL:"),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        uploadedUrl,
                        style: const TextStyle(fontSize: 10),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );

            _showSnackBar("✅ Upload test successful! Check Firebase Storage.",
                backgroundColor: Colors.green);
          } else {
            print("❌ Upload returned empty URL");
            _showSnackBar("❌ Upload returned empty URL",
                backgroundColor: Colors.red);
          }
        } catch (e) {
          _safeNavigatorPop(context);
          print("❌ Upload failed: $e");

          String errorDetails = "Unknown error";
          if (e is FirebaseException) {
            errorDetails = "Firebase Error: ${e.code} - ${e.message}";
          } else {
            errorDetails = "Error: $e";
          }

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("❌ Upload Failed"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📂 Folder: $selectedFolder"),
                  const SizedBox(height: 8),
                  const Text("🔍 Error Details:"),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      errorDetails,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );

          _showSnackBar("❌ Upload failed: Check console for details",
              backgroundColor: Colors.red);
        }
      } else {
        print("❌ No image selected");
        _showSnackBar("❌ No image selected", backgroundColor: Colors.orange);
      }
    } catch (e) {
      print("❌ Error in test image upload: $e");
      _showSnackBar("❌ Test failed: $e", backgroundColor: Colors.red);
    }
  }

  // Enhanced debug method to test restaurant category image upload specifically
  Future<void> _testRestaurantCategoryUpload() async {
    try {
      print("=== TESTING RESTAURANT CATEGORY IMAGE UPLOAD ===");

      // Check authentication first
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showSnackBar("❌ Not authenticated. Please login first.",
            backgroundColor: Colors.red);
        return;
      }
      print("✅ User authenticated: ${currentUser.uid}");

      // Test picking an image
      final picker = ImagePicker();
      print("📷 Opening image picker...");

      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        _showSnackBar("❌ No image selected", backgroundColor: Colors.orange);
        return;
      }

      final file = File(pickedFile.path);
      final fileExists = await file.exists();
      final fileSize = fileExists ? await file.length() : 0;

      print("✅ Image selected successfully");
      print("📍 File path: ${file.path}");
      print("📏 File size: ${(fileSize / 1024).toStringAsFixed(2)} KB");
      print("📄 File exists: $fileExists");

      if (!fileExists || fileSize == 0) {
        _showSnackBar("❌ Invalid image file", backgroundColor: Colors.red);
        return;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text("Testing restaurant category upload..."),
              const SizedBox(height: 8),
              Text("File: ${(fileSize / 1024).toStringAsFixed(2)} KB"),
            ],
          ),
        ),
      );

      try {
        print("🚀 Testing direct Firebase Storage upload...");

        // Test Firebase Storage upload directly
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('restaurant_categories')
            .child('test_${DateTime.now().millisecondsSinceEpoch}.jpg');

        print("📂 Storage path: ${storageRef.fullPath}");

        // Upload with metadata
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'test': 'true',
            'uploaded_by': 'admin_panel_test',
            'user_id': currentUser.uid,
          },
        );

        final uploadTask = storageRef.putFile(file, metadata);

        // Monitor progress
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print("📊 Upload progress: ${(progress * 100).toStringAsFixed(1)}%");
        });

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        _safeNavigatorPop(context);

        print("✅ Upload successful!");
        print("🔗 Download URL: $downloadUrl");

        // Test adding a category with this image
        await _testAddCategoryWithUrl(downloadUrl);
      } catch (uploadError) {
        _safeNavigatorPop(context);
        print("❌ Upload failed: $uploadError");

        String errorDetails = "Unknown upload error";
        if (uploadError is FirebaseException) {
          errorDetails =
              "Firebase Error: ${uploadError.code} - ${uploadError.message}";
          print("🔧 Error code: ${uploadError.code}");
          print("🔧 Error message: ${uploadError.message}");
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("❌ Upload Test Failed"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Error Details:"),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child:
                      Text(errorDetails, style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(height: 16),
                const Text("Possible Solutions:"),
                const Text("• Check Firebase Storage Rules"),
                const Text("• Verify user authentication"),
                const Text("• Check internet connection"),
                const Text("• Verify Firebase project configuration"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print("❌ Test failed: $e");
      _showSnackBar("❌ Test failed: $e", backgroundColor: Colors.red);
    }
  }

  Future<void> _testAddCategoryWithUrl(String imageUrl) async {
    try {
      print("🧪 Testing category addition with uploaded image...");

      final testCategoryName =
          "Test Category ${DateTime.now().millisecondsSinceEpoch}";

      await FirebaseFirestore.instance
          .collection('restaurants_categories')
          .add({
        'en': testCategoryName,
        'ar': "تصنيف تجريبي",
        'img': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'test': true, // Mark as test data
      });

      print("✅ Test category created successfully!");

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("✅ Test Successful!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  "Restaurant category upload test completed successfully!"),
              const SizedBox(height: 8),
              Text("Category: $testCategoryName"),
              const SizedBox(height: 8),
              const Text("Image URL:"),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(imageUrl, style: const TextStyle(fontSize: 10)),
              ),
              const SizedBox(height: 8),
              const Text(
                  "Your restaurant category image upload is working correctly!"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Refresh the admin panel to show the new test category
                _refreshAdminPanel();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("❌ Category addition test failed: $e");
      _showSnackBar("❌ Category addition failed: $e",
          backgroundColor: Colors.red);
    }
  }

  // Add the missing tab methods
  Widget _buildItemsTab(AdminPanelCubit cubit, AdminPanelStates state) {
    // Get available menu categories for the selected restaurant
    List<String> availableMenuCategories = [];

    if (selectedRestaurantId != null) {
      try {
        availableMenuCategories =
            cubit.getMenuCategoriesForRestaurant(selectedRestaurantId!);
      } catch (e) {
        print('Error getting menu categories: $e');
        availableMenuCategories = ['All', 'Uncategorized'];
      }
    } else {
      availableMenuCategories = ['All', 'Uncategorized'];
    }

    // Make sure categories are unique to avoid dropdown errors
    availableMenuCategories = availableMenuCategories.toSet().toList();

    // Add "All" as the first category if not present
    if (!availableMenuCategories.contains("All")) {
      availableMenuCategories.insert(0, "All");
    }

    // Remove any variations of "Uncategorized" to avoid issues
    availableMenuCategories.removeWhere(
      (category) => category.toLowerCase().contains("uncategorized"),
    );

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
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: S.of(context).select_restaurant,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                    width: 2.0,
                  ),
                ),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
              value: selectedRestaurantId,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.white,
                fontSize: 16.sp,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).primaryColor,
              ),
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
                if (value != selectedRestaurantId && mounted) {
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
                            if (imageFile != null && mounted) {
                              setState(() {
                                _itemImageFile = imageFile;
                              });
                            }
                          } catch (e) {
                            print("Error selecting image: $e");
                            _showSnackBar('Error selecting image: $e',
                                backgroundColor: Colors.red);
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
                            if (_itemFormKey.currentState?.validate() == true) {
                              if (selectedRestaurantId == null) {
                                _showSnackBar(
                                    "Please select a restaurant for the item",
                                    backgroundColor: Colors.red);
                                return;
                              }

                              try {
                                // Show loading indicator
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext dialogContext) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                );

                                // Make sure we include the primary category in selectedCategories
                                final allCategories =
                                    List<String>.from(selectedCategories);
                                if (!allCategories.contains(
                                        _itemCategoryController.text) &&
                                    _itemCategoryController.text != "All") {
                                  allCategories
                                      .add(_itemCategoryController.text);
                                }

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
                                  categories: allCategories,
                                  imageFile: _itemImageFile,
                                );

                                // Close loading dialog
                                _safeNavigatorPop(context);

                                _clearItemForm();
                                _itemImageFile = null;
                                if (mounted) {
                                  setState(() {});
                                }

                                _showSnackBar("Item added successfully",
                                    backgroundColor: Colors.green);

                                // Refresh the admin panel
                                await _refreshAdminPanel();
                              } catch (e) {
                                print('Error adding item: $e');
                                _safeNavigatorPop(context);
                                _showSnackBar('Error adding item: $e',
                                    backgroundColor: Colors.red);
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
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            if (selectedRestaurantId != null)
              Builder(
                builder: (context) {
                  try {
                    return _buildItemsForRestaurant(
                      cubit,
                      selectedRestaurantId!,
                    );
                  } catch (e) {
                    print("Error building items for restaurant: $e");
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          SizedBox(height: 16.h),
                          const Text("Error displaying items"),
                          SizedBox(height: 8.h),
                          ElevatedButton(
                            onPressed: () {
                              try {
                                cubit.getRestaurants();
                              } catch (e) {
                                print('Error refreshing data: $e');
                              }
                            },
                            child: const Text("Refresh data"),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(AdminPanelCubit cubit, AdminPanelStates state) {
    // This tab is for menu categories within a restaurant
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).add_new_category,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: S.of(context).select_restaurant,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight,
                    width: 2.0,
                  ),
                ),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
              value: selectedRestaurantId,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.white,
                fontSize: 16.sp,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).primaryColor,
              ),
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
                if (value != selectedRestaurantId && mounted) {
                  setState(() {
                    selectedRestaurantId = value;
                    // Reset relevant state when restaurant changes
                    _categoryNameController.clear();
                    _categoryNameArController.clear();
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
                    label: S.of(context).category_name_english,
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return S.of(context).please_fill_all_fields;
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
                        return S.of(context).please_fill_all_fields;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  state is AddingCategoryState
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () => _submitCategoryForm(cubit),
                          child: Text(S.of(context).add_category),
                        ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              S.of(context).restaurant_items,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            if (selectedRestaurantId != null)
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection("restaurants")
                    .doc(selectedRestaurantId)
                    .collection("menu_categories")
                    .orderBy("createdAt",
                        descending: true) // Order by newest first
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print("Error loading menu categories: ${snapshot.error}");
                    // Fallback to the in-memory data if we can't load from Firestore
                    try {
                      final restaurant = cubit.restaurants.firstWhere(
                        (r) => r.id == selectedRestaurantId!,
                        orElse: () => throw Exception("Restaurant not found"),
                      );

                      final menuCategories = restaurant.menuCategories ?? [];
                      final menuCategoriesAr =
                          restaurant.menuCategoriesAr ?? [];

                      if (menuCategories.isEmpty) {
                        return const Center(
                          child: Text(
                              "No menu categories found for this restaurant"),
                        );
                      }

                      return _buildCategoriesList(
                        cubit,
                        menuCategories,
                        menuCategoriesAr,
                      );
                    } catch (e) {
                      print("Error accessing fallback data: $e");
                      return const Center(
                        child: Text("Error loading categories"),
                      );
                    }
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    // Check in-memory data as fallback
                    try {
                      final restaurant = cubit.restaurants.firstWhere(
                        (r) => r.id == selectedRestaurantId!,
                        orElse: () => throw Exception("Restaurant not found"),
                      );

                      final menuCategories = restaurant.menuCategories ?? [];

                      if (menuCategories.isEmpty) {
                        return const Center(
                          child: Text(
                              "No menu categories found for this restaurant"),
                        );
                      }

                      return _buildCategoriesList(
                        cubit,
                        restaurant.menuCategories ?? [],
                        restaurant.menuCategoriesAr ?? [],
                      );
                    } catch (e) {
                      print("Error accessing fallback data: $e");
                      return const Center(
                        child: Text("No menu categories found"),
                      );
                    }
                  }

                  // Process subcollection data
                  final List<String> menuCategories = [];
                  final List<String> menuCategoriesAr = [];
                  final List<String> categoryIds = [];

                  try {
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final categoryName = data['name']?.toString();

                      if (categoryName != null && categoryName.isNotEmpty) {
                        menuCategories.add(categoryName);
                        menuCategoriesAr
                            .add(data['nameAr']?.toString() ?? categoryName);
                        categoryIds.add(doc.id);
                      }
                    }
                  } catch (e) {
                    print("Error processing subcollection data: $e");
                    return const Center(
                      child: Text("Error processing categories data"),
                    );
                  }

                  return _buildCategoriesListFromSubcollection(
                    cubit,
                    menuCategories,
                    menuCategoriesAr,
                    categoryIds,
                  );
                },
              )
            else
              Center(
                child: Text(S.of(context).select_restaurant_to_view_items),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsForRestaurant(AdminPanelCubit cubit, String restaurantId) {
    try {
      final restaurant = cubit.restaurants.firstWhere(
        (r) => r.id == restaurantId,
        orElse: () => throw Exception('Restaurant not found'),
      );

      if (restaurant.menuItems.isEmpty) {
        return const Center(child: Text("No items found for this restaurant"));
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
            .where(
              (item) =>
                  item.category == selectedCategory ||
                  (item.categories.contains(selectedCategory)),
            )
            .toList();
      }

      // Items are already ordered by creation date (newest first) from the cubit
      // No additional sorting needed since the cubit now fetches items in descending order by createdAt

      if (displayedItems.isEmpty) {
        return const Center(
          child: Text("No items found in category"),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayedItems.length,
        itemBuilder: (context, index) {
          if (index >= displayedItems.length) {
            return const SizedBox.shrink();
          }
          final item = displayedItems[index];
          return ItemListItem(
            item: item,
            onDelete: () => _deleteItem(cubit, restaurantId, item.id),
          );
        },
      );
    } catch (e) {
      print('Error building items for restaurant: $e');
      return const Center(child: Text("Error loading restaurant items"));
    }
  }

  Widget _buildBannersTab(AdminPanelCubit cubit) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Banner section
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Banner',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),

                // Image picker
                GestureDetector(
                  onTap: () async {
                    try {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );

                      if (image != null) {
                        setState(() {
                          _bannerImageFile = File(image.path);
                        });
                      }
                    } catch (e) {
                      print('Error picking banner image: $e');
                      _showSnackBar('Error picking image',
                          backgroundColor: Colors.red);
                    }
                  },
                  child: Container(
                    height: 150.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: _bannerImageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.file(
                              _bannerImageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 50.sp, color: Colors.grey),
                              SizedBox(height: 8.h),
                              const Text('Tap to select banner image',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _bannerImageFile != null
                        ? () async {
                            try {
                              await cubit.addBanner(
                                  imageFile: _bannerImageFile!);
                              setState(() {
                                _bannerImageFile = null;
                              });
                              _showSnackBar('Banner added successfully',
                                  backgroundColor: Colors.green);
                            } catch (e) {
                              print('Error adding banner: $e');
                              _showSnackBar(
                                  'Error adding banner: ${e.toString()}',
                                  backgroundColor: Colors.red);
                            }
                          }
                        : null,
                    child: const Text('Add Banner'),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Banners List section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Banners',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  cubit.fetchBanners();
                },
                tooltip: "Refresh",
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Banners list
          BlocBuilder<AdminPanelCubit, AdminPanelStates>(
            builder: (context, state) {
              if (state is LoadingBannersState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ErrorLoadingBannersState) {
                return Center(
                  child: Column(
                    children: [
                      Text('Error: ${state.error}'),
                      ElevatedButton(
                        onPressed: () => cubit.fetchBanners(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else {
                if (cubit.banners.isEmpty) {
                  return const Center(
                    child: Text(
                        'No banners found. Add some banners to get started.'),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cubit.banners.length,
                    itemBuilder: (context, index) {
                      final banner = cubit.banners[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              banner.imageUrl,
                              width: 60.w,
                              height: 40.h,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60.w,
                                  height: 40.h,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.error),
                                );
                              },
                            ),
                          ),
                          title: Text('Banner ${index + 1}'),
                          subtitle: Text(
                              'Created: ${banner.createdAt.toString().split(' ')[0]}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              try {
                                bool confirm = await showDialog(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Delete Banner'),
                                        content: const Text(
                                            'Are you sure you want to delete this banner?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                dialogContext, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(
                                                dialogContext, true),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;

                                if (confirm) {
                                  await cubit.deleteBanner(banner.id);
                                  _showSnackBar('Banner deleted successfully',
                                      backgroundColor: Colors.green);
                                }
                              } catch (e) {
                                print('Error deleting banner: $e');
                                _showSnackBar('Error deleting banner',
                                    backgroundColor: Colors.red);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Cities Tab
  Widget _buildCitiesTab(AdminPanelCubit cubit) {
    // Initialize cities data only once
    if (!_citiesInitialized) {
      _citiesInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          cubit.fetchCities();
        }
      });
    }

    // Controllers for the form
    final TextEditingController cityNameController = TextEditingController();
    final TextEditingController cityNameArController = TextEditingController();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add City section
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New City',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),

                // City name in English
                TextFormField(
                  controller: cityNameController,
                  decoration: const InputDecoration(
                    labelText: 'City Name (English)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.h),

                // City name in Arabic
                TextFormField(
                  controller: cityNameArController,
                  decoration: const InputDecoration(
                    labelText: 'City Name (Arabic)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.h),

                // Add button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (cityNameController.text.isNotEmpty &&
                          cityNameArController.text.isNotEmpty) {
                        try {
                          await cubit.addCity(
                            name: cityNameController.text.trim(),
                            nameAr: cityNameArController.text.trim(),
                          );
                          cityNameController.clear();
                          cityNameArController.clear();
                          _showSnackBar('City added successfully',
                              backgroundColor: Colors.green);
                        } catch (e) {
                          _showSnackBar('Error adding city: $e',
                              backgroundColor: Colors.red);
                        }
                      } else {
                        _showSnackBar('Please fill all fields',
                            backgroundColor: Colors.red);
                      }
                    },
                    child: const Text('Add City'),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Cities List section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Cities',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  cubit.fetchCities();
                },
                tooltip: "Refresh",
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Cities list
          BlocBuilder<AdminPanelCubit, AdminPanelStates>(
            builder: (context, state) {
              if (state is LoadingCitiesState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ErrorLoadingCitiesState) {
                return Center(
                  child: Column(
                    children: [
                      Text('Error: ${state.error}'),
                      ElevatedButton(
                        onPressed: () => cubit.fetchCities(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else {
                if (cubit.cities.isEmpty) {
                  return const Center(
                    child: Text(
                        'No cities found. Add some cities to get started.'),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cubit.cities.length,
                    itemBuilder: (context, index) {
                      final city = cubit.cities[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.location_city,
                              color: Colors.blue),
                          title: Text(city.name),
                          subtitle: Text(city.nameAr),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              try {
                                bool confirm = await showDialog(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Delete City'),
                                        content: const Text(
                                            'Are you sure you want to delete this city? This will also delete all areas within this city.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                dialogContext, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(
                                                dialogContext, true),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;

                                if (confirm) {
                                  await cubit.deleteCity(city.id);
                                  _showSnackBar('City deleted successfully',
                                      backgroundColor: Colors.green);
                                }
                              } catch (e) {
                                print('Error deleting city: $e');
                                _showSnackBar('Error deleting city',
                                    backgroundColor: Colors.red);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Areas Tab
  Widget _buildAreasTab(AdminPanelCubit cubit) {
    // Initialize cities data only once for areas tab
    if (!_areasInitialized) {
      _areasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          cubit.fetchCities();
        }
      });
    }

    // Using class-level controllers for proper state management

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Area section
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Area',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // City selection dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCityId,
                      decoration: const InputDecoration(
                        labelText: 'Select City',
                        border: OutlineInputBorder(),
                      ),
                      items: cubit.cities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city.id,
                          child: Text(
                            '${city.name} - ${city.nameAr}',
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCityId = value;
                        });
                        if (value != null) {
                          cubit.fetchAreas(value);
                        }
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Area name in English
                    TextFormField(
                      controller: _areaNameController,
                      decoration: const InputDecoration(
                        labelText: 'Area Name (English)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() {}), // Trigger rebuild
                    ),
                    SizedBox(height: 12.h),

                    // Area name in Arabic
                    TextFormField(
                      controller: _areaNameArController,
                      decoration: const InputDecoration(
                        labelText: 'Area Name (Arabic)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() {}), // Trigger rebuild
                    ),
                    SizedBox(height: 16.h),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedCityId != null &&
                                _areaNameController.text.isNotEmpty &&
                                _areaNameArController.text.isNotEmpty
                            ? () async {
                                try {
                                  await cubit.addArea(
                                    cityId: _selectedCityId!,
                                    name: _areaNameController.text.trim(),
                                    nameAr: _areaNameArController.text.trim(),
                                  );
                                  _areaNameController.clear();
                                  _areaNameArController.clear();
                                  _showSnackBar('Area added successfully',
                                      backgroundColor: Colors.green);
                                } catch (e) {
                                  _showSnackBar('Error adding area: $e',
                                      backgroundColor: Colors.red);
                                }
                              }
                            : null,
                        child: const Text('Add Area'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: 24.h),

          // Areas List section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Areas in Selected City',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  if (_selectedCityId != null) {
                    cubit.fetchAreas(_selectedCityId!);
                  }
                },
                tooltip: "Refresh",
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Areas list
          BlocBuilder<AdminPanelCubit, AdminPanelStates>(
            builder: (context, state) {
              if (state is LoadingAreasState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ErrorLoadingAreasState) {
                return Center(
                  child: Column(
                    children: [
                      Text('Error: ${state.error}'),
                      ElevatedButton(
                        onPressed: () {
                          if (_selectedCityId != null) {
                            cubit.fetchAreas(_selectedCityId!);
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else {
                if (_selectedCityId == null) {
                  return const Center(
                    child: Text('Please select a city to view its areas.'),
                  );
                } else if (cubit.areas.isEmpty) {
                  return const Center(
                    child: Text('No areas found for the selected city.'),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cubit.areas.length,
                    itemBuilder: (context, index) {
                      final area = cubit.areas[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.location_on,
                              color: Colors.green),
                          title: Text(area.name),
                          subtitle: Text(area.nameAr),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              try {
                                bool confirm = await showDialog(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Delete Area'),
                                        content: const Text(
                                            'Are you sure you want to delete this area?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                dialogContext, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(
                                                dialogContext, true),
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;

                                if (confirm) {
                                  await cubit.deleteArea(area.cityId, area.id);
                                  _showSnackBar('Area deleted successfully',
                                      backgroundColor: Colors.green);
                                }
                              } catch (e) {
                                print('Error deleting area: $e');
                                _showSnackBar('Error deleting area',
                                    backgroundColor: Colors.red);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Show edit restaurant dialog
  void _showEditRestaurantDialog(
      AdminPanelCubit cubit, Restuarants restaurant) {
    // Create separate controllers for editing
    final TextEditingController editRestaurantNameController =
        TextEditingController(text: restaurant.name);
    final TextEditingController editRestaurantNameArController =
        TextEditingController(text: restaurant.nameAr);
    final TextEditingController editDeliveryFeeController =
        TextEditingController(text: restaurant.deliveryFee);
    final TextEditingController editDeliveryTimeController =
        TextEditingController(text: restaurant.deliveryTime);
    final TextEditingController editOutOfAreaFeeController =
        TextEditingController(text: restaurant.outOfAreaFee ?? '0');

    File? editRestaurantImageFile;
    Category? editSelectedRestaurantCategory;
    List<String> editSelectedMainAreas = List.from(restaurant.mainAreas);
    List<String> editSelectedSecondaryAreas =
        List.from(restaurant.secondaryAreas);

    // Find the current category
    try {
      final restCategories = Restuarantscubit.get(context)
          .categories
          .where((cat) => cat.en != 'All')
          .toList();
      if (restCategories.isNotEmpty) {
        editSelectedRestaurantCategory = restCategories.firstWhere(
          (cat) => cat.en == restaurant.category,
          orElse: () => restCategories.first,
        );
      }
    } catch (e) {
      print('Error finding restaurant category: $e');
    }

    // Load all areas from all cities immediately
    print('Loading all areas for edit dialog...');
    cubit.fetchAllAreas();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title:
              Text('${S.of(context).Edit} ${S.of(context).admin_restaurants}'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.75,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Restaurant Name
                  TextFormField(
                    controller: editRestaurantNameController,
                    decoration: InputDecoration(
                      labelText: S.of(context).Name,
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Restaurant Name Arabic
                  TextFormField(
                    controller: editRestaurantNameArController,
                    decoration: InputDecoration(
                      labelText:
                          '${S.of(context).Name} (${S.of(context).arabic})',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Out of Area Fee
                  TextFormField(
                    controller: editOutOfAreaFeeController,
                    decoration: InputDecoration(
                      labelText: 'Out of Area Delivery Fee',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 2.0,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12.h),

                  // Category Dropdown
                  BlocBuilder<Restuarantscubit, ResturantsStates>(
                    builder: (context, state) {
                      final restCategories = Restuarantscubit.get(context)
                          .categories
                          .where((cat) => cat.en != 'All')
                          .toList();

                      return DropdownButtonFormField<Category>(
                        value: editSelectedRestaurantCategory,
                        decoration: InputDecoration(
                          labelText: S.of(context).category,
                          labelStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          hintStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black54,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              width: 2.0,
                            ),
                          ),
                        ),
                        items: restCategories.map((cat) {
                          return DropdownMenuItem<Category>(
                            value: cat,
                            child: Text(
                              '${cat.en} / ${cat.ar}',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (cat) {
                          setState(() {
                            editSelectedRestaurantCategory = cat;
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Delivery Fee
                  TextFormField(
                    controller: editDeliveryFeeController,
                    decoration: InputDecoration(
                      labelText: S.of(context).delivery_fee,
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 2.0,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 12.h),

                  // Delivery Time
                  TextFormField(
                    controller: editDeliveryTimeController,
                    decoration: InputDecoration(
                      labelText: S.of(context).delivery_time,
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Main and Secondary Areas Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Service Areas',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          print('Refreshing all areas from edit dialog...');
                          cubit.fetchAllAreas();
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh Areas'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          textStyle: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  BlocBuilder<AdminPanelCubit, AdminPanelStates>(
                    builder: (context, state) {
                      print('Edit dialog areas state: $state');
                      print('Areas count: ${cubit.allAreas.length}');

                      if (state is LoadingAreasState) {
                        return Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            children: [
                              const CircularProgressIndicator(),
                              SizedBox(height: 8.h),
                              const Text('Loading areas from all cities...'),
                            ],
                          ),
                        );
                      }

                      if (cubit.allAreas.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 48, color: Colors.orange),
                              SizedBox(height: 8.h),
                              const Text('No areas loaded'),
                              SizedBox(height: 8.h),
                              ElevatedButton(
                                onPressed: () {
                                  print('Manually triggering fetchAllAreas...');
                                  cubit.fetchAllAreas();
                                },
                                child: const Text('Load Areas'),
                              ),
                            ],
                          ),
                        );
                      }

                      // Remove any selected areas that no longer exist in the current areas list
                      final currentAreaNames =
                          cubit.allAreas.map((area) => area.name).toSet();
                      editSelectedMainAreas.removeWhere(
                          (areaName) => !currentAreaNames.contains(areaName));
                      editSelectedSecondaryAreas.removeWhere(
                          (areaName) => !currentAreaNames.contains(areaName));

                      return Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Service Areas',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                // Main Areas Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(3.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Main (${editSelectedMainAreas.length})',
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'No extra fee',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                // Secondary Areas Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(3.r),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Secondary (${editSelectedSecondaryAreas.length})',
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange.shade700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'With extra fee',
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.15,
                                minHeight: 80.h,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Scrollbar(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(4.r),
                                  itemCount: cubit.allAreas.length,
                                  itemBuilder: (context, index) {
                                    final area = cubit.allAreas[index];
                                    bool isMainArea = editSelectedMainAreas
                                        .contains(area.name);
                                    bool isSecondaryArea =
                                        editSelectedSecondaryAreas
                                            .contains(area.name);

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 2.h),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 2.h, horizontal: 4.w),
                                      child: Row(
                                        children: [
                                          // Area name - compact
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              area.name,
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                fontWeight: (isMainArea ||
                                                        isSecondaryArea)
                                                    ? FontWeight.w500
                                                    : FontWeight.normal,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          // Main button - compact
                                          Expanded(
                                            flex: 2,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (isMainArea) {
                                                    editSelectedMainAreas
                                                        .remove(area.name);
                                                  } else {
                                                    editSelectedMainAreas
                                                        .add(area.name);
                                                    editSelectedSecondaryAreas
                                                        .remove(area.name);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 3.h,
                                                    horizontal: 3.w),
                                                decoration: BoxDecoration(
                                                  color: isMainArea
                                                      ? Colors.green
                                                          .withOpacity(0.2)
                                                      : Colors.grey
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          3.r),
                                                  border: Border.all(
                                                    color: isMainArea
                                                        ? Colors.green
                                                        : Colors.grey.shade400,
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      isMainArea
                                                          ? Icons.check_circle
                                                          : Icons
                                                              .radio_button_unchecked,
                                                      size: 12.sp,
                                                      color: isMainArea
                                                          ? Colors.green
                                                          : Colors.grey,
                                                    ),
                                                    SizedBox(width: 2.w),
                                                    Flexible(
                                                      child: Text(
                                                        'M',
                                                        style: TextStyle(
                                                          fontSize: 9.sp,
                                                          color: isMainArea
                                                              ? Colors.green
                                                                  .shade700
                                                              : Colors.grey,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 2.w),
                                          // Secondary button - compact
                                          Expanded(
                                            flex: 2,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (isSecondaryArea) {
                                                    editSelectedSecondaryAreas
                                                        .remove(area.name);
                                                  } else {
                                                    editSelectedSecondaryAreas
                                                        .add(area.name);
                                                    editSelectedMainAreas
                                                        .remove(area.name);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 3.h,
                                                    horizontal: 3.w),
                                                decoration: BoxDecoration(
                                                  color: isSecondaryArea
                                                      ? Colors.orange
                                                          .withOpacity(0.2)
                                                      : Colors.grey
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          3.r),
                                                  border: Border.all(
                                                    color: isSecondaryArea
                                                        ? Colors.orange
                                                        : Colors.grey.shade400,
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      isSecondaryArea
                                                          ? Icons.check_circle
                                                          : Icons
                                                              .radio_button_unchecked,
                                                      size: 12.sp,
                                                      color: isSecondaryArea
                                                          ? Colors.orange
                                                          : Colors.grey,
                                                    ),
                                                    SizedBox(width: 2.w),
                                                    Flexible(
                                                      child: Text(
                                                        'S',
                                                        style: TextStyle(
                                                          fontSize: 9.sp,
                                                          color: isSecondaryArea
                                                              ? Colors.orange
                                                                  .shade700
                                                              : Colors.grey,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Image Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              final imageFile = await cubit.pickImage();
                              if (imageFile != null) {
                                setState(() {
                                  editRestaurantImageFile = imageFile;
                                });
                              }
                            } catch (e) {
                              print("Error selecting image: $e");
                            }
                          },
                          child: Text(S.of(context).select_image),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        editRestaurantImageFile != null
                            ? '✅ ${S.of(context).image_selected}'
                            : '📷 Keep current image',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: editRestaurantImageFile != null
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                S.of(context).cancel,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (loadingContext) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  await cubit.editRestaurant(
                    restaurantId: restaurant.id,
                    name: editRestaurantNameController.text.trim(),
                    nameAr: editRestaurantNameArController.text.trim(),
                    category: editSelectedRestaurantCategory?.en ??
                        restaurant.category,
                    categoryAr: editSelectedRestaurantCategory?.ar ??
                        restaurant.categoryAr,
                    deliveryFee: editDeliveryFeeController.text.trim(),
                    deliveryTime: editDeliveryTimeController.text.trim(),
                    imageFile: editRestaurantImageFile,
                    categories: [],
                    mainAreas: editSelectedMainAreas,
                    secondaryAreas: editSelectedSecondaryAreas,
                    outOfAreaFee: editOutOfAreaFeeController.text.trim(),
                  );

                  // Close loading dialog
                  Navigator.pop(context);
                  // Close edit dialog
                  Navigator.pop(dialogContext);

                  _showSnackBar('Restaurant updated successfully',
                      backgroundColor: Colors.green);
                } catch (e) {
                  // Close loading dialog
                  Navigator.pop(context);
                  _showSnackBar('Error updating restaurant: $e',
                      backgroundColor: Colors.red);
                }
              },
              child: Text(S.of(context).UpdateProfile),
            ),
          ],
        ),
      ),
    );
  }

  // Show edit menu category dialog
  void _showEditMenuCategoryDialog(
    AdminPanelCubit cubit,
    String restaurantId,
    String currentEnglishName,
    String currentArabicName, {
    String? categoryId,
  }) {
    final TextEditingController editCategoryNameController =
        TextEditingController(text: currentEnglishName);
    final TextEditingController editCategoryNameArController =
        TextEditingController(text: currentArabicName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${S.of(context).Edit} ${S.of(context).admin_categories}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // English Name
              TextFormField(
                controller: editCategoryNameController,
                decoration: InputDecoration(
                  labelText: S.of(context).category_name_english,
                  labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Arabic Name
              TextFormField(
                controller: editCategoryNameArController,
                decoration: InputDecoration(
                  labelText: S.of(context).category_name_arabic,
                  labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                  hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (editCategoryNameController.text.trim().isEmpty ||
                  editCategoryNameArController.text.trim().isEmpty) {
                _showSnackBar(S.of(context).please_fill_all_fields,
                    backgroundColor: Colors.red);
                return;
              }

              try {
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (loadingContext) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                // Update menu category
                await cubit.editMenuCategory(
                  restaurantId: restaurantId,
                  oldCategoryName: currentEnglishName,
                  newCategoryName: editCategoryNameController.text.trim(),
                  newCategoryNameAr: editCategoryNameArController.text.trim(),
                  categoryId: categoryId,
                );

                // Close loading dialog
                Navigator.pop(context);
                // Close edit dialog
                Navigator.pop(dialogContext);

                _showSnackBar('Menu category updated successfully',
                    backgroundColor: Colors.green);

                // Refresh the admin panel
                await _refreshAdminPanel();
              } catch (e) {
                // Close loading dialog
                Navigator.pop(context);
                _showSnackBar('Error updating menu category: $e',
                    backgroundColor: Colors.red);
              }
            },
            child: Text(S.of(context).UpdateProfile),
          ),
        ],
      ),
    );
  }

  // Show edit restaurant category dialog
  void _showEditRestaurantCategoryDialog(
      String categoryId,
      String currentEnglishName,
      String currentArabicName,
      String? currentImageUrl) {
    final TextEditingController editCategoryNameController =
        TextEditingController(text: currentEnglishName);
    final TextEditingController editCategoryNameArController =
        TextEditingController(text: currentArabicName);
    File? editCategoryImageFile;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
              '${S.of(context).Edit} ${S.of(context).restaurant_categories}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // English Name
                TextFormField(
                  controller: editCategoryNameController,
                  decoration: InputDecoration(
                    labelText: S.of(context).category_name_english,
                    labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Arabic Name
                TextFormField(
                  controller: editCategoryNameArController,
                  decoration: InputDecoration(
                    labelText: S.of(context).category_name_arabic,
                    labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Current Image Display
                if (currentImageUrl != null && currentImageUrl.isNotEmpty)
                  Column(
                    children: [
                      const Text('Current Image:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      Container(
                        height: 100.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            currentImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error, color: Colors.red);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),

                // Image Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final cubit = AdminPanelCubit.get(context);
                            final imageFile = await cubit.pickImage();
                            if (imageFile != null) {
                              setState(() {
                                editCategoryImageFile = imageFile;
                              });
                            }
                          } catch (e) {
                            print("Error selecting image: $e");
                          }
                        },
                        child: Text(S.of(context).select_image),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      editCategoryImageFile != null
                          ? '✅ ${S.of(context).image_selected}'
                          : '📷 Keep current image',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: editCategoryImageFile != null
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                S.of(context).cancel,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (editCategoryNameController.text.trim().isEmpty ||
                    editCategoryNameArController.text.trim().isEmpty) {
                  _showSnackBar(S.of(context).please_fill_all_fields,
                      backgroundColor: Colors.red);
                  return;
                }

                try {
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (loadingContext) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  final cubit = AdminPanelCubit.get(context);
                  await cubit.editRestaurantCategory(
                    categoryId: categoryId,
                    englishName: editCategoryNameController.text.trim(),
                    arabicName: editCategoryNameArController.text.trim(),
                    imageFile: editCategoryImageFile,
                  );

                  // Close loading dialog
                  Navigator.pop(context);
                  // Close edit dialog
                  Navigator.pop(dialogContext);

                  _showSnackBar('Category updated successfully',
                      backgroundColor: Colors.green);

                  // Refresh the admin panel
                  await _refreshAdminPanel();
                } catch (e) {
                  // Close loading dialog
                  Navigator.pop(context);
                  _showSnackBar('Error updating category: $e',
                      backgroundColor: Colors.red);
                }
              },
              child: Text(S.of(context).UpdateProfile),
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
  final VoidCallback? onEdit;

  const RestaurantListItem({
    Key? key,
    required this.restaurant,
    required this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          backgroundImage: _getImageProvider(restaurant.img),
          onBackgroundImageError: (exception, stackTrace) {
            print("Error loading restaurant image: $exception");
          },
          child: restaurant.img.isEmpty
              ? const Icon(Icons.restaurant, color: Colors.grey)
              : null,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(restaurant.name),
            Text(
              restaurant.nameAr,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${restaurant.category} • ${restaurant.deliveryTime}'),
            Text(
              restaurant.categoryAr,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            if (restaurant.areas.isNotEmpty)
              Text(
                'Delivery Areas: ${restaurant.areas.length}',
                style: TextStyle(fontSize: 12.sp, color: Colors.blue),
              ),
            if (restaurant.mainAreas.isNotEmpty)
              Text(
                'Main Areas: ${restaurant.mainAreas.join(", ")}',
                style: TextStyle(fontSize: 12.sp, color: Colors.green),
              ),
            if (restaurant.secondaryAreas.isNotEmpty)
              Text(
                'Secondary Areas: ${restaurant.secondaryAreas.join(", ")}',
                style: TextStyle(fontSize: 12.sp, color: Colors.orange),
              ),
            if (restaurant.outOfAreaFee != null &&
                restaurant.outOfAreaFee != '0')
              Text(
                'Out-of-area fee: ${restaurant.outOfAreaFee}',
                style: TextStyle(fontSize: 12.sp, color: Colors.orange),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
                tooltip: "Edit Restaurant",
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: "Delete Restaurant",
            ),
          ],
        ),
      ),
    );
  }

  // Static helper method to safely get an image provider
  static ImageProvider _getImageProvider(String? imageUrl) {
    try {
      if (imageUrl == null || imageUrl.isEmpty) {
        return const AssetImage('assets/images/restuarants/store.jpg');
      }

      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return NetworkImage(imageUrl);
      } else if (imageUrl.startsWith('assets/')) {
        return AssetImage(imageUrl);
      } else {
        return const AssetImage('assets/images/restuarants/store.jpg');
      }
    } catch (e) {
      print("Error loading restaurant image: $e");
      return const AssetImage('assets/images/restuarants/store.jpg');
    }
  }
}

class ItemListItem extends StatelessWidget {
  final Item item;
  final VoidCallback onDelete;

  const ItemListItem({Key? key, required this.item, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          backgroundImage: _getImageProvider(item.img),
          onBackgroundImageError: (exception, stackTrace) {
            print("Error loading item image: $exception");
          },
          child: item.img.isEmpty
              ? const Icon(Icons.fastfood, color: Colors.grey)
              : null,
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
                const Text(" • ", style: TextStyle(color: Colors.grey)),
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
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  " • ",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
                Expanded(
                  child: Text(
                    item.descriptionAr,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
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

  // Static helper method to safely get an image provider
  static ImageProvider _getImageProvider(String? imageUrl) {
    try {
      if (imageUrl == null || imageUrl.isEmpty) {
        return const AssetImage('assets/images/items/default.jpg');
      }

      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return NetworkImage(imageUrl);
      } else if (imageUrl.startsWith('assets/')) {
        return AssetImage(imageUrl);
      } else {
        return const AssetImage('assets/images/items/default.jpg');
      }
    } catch (e) {
      print("Error loading item image: $e");
      return const AssetImage('assets/images/items/default.jpg');
    }
  }
}
