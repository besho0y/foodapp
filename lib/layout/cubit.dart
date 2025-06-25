import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/states.dart';
import 'package:foodapp/main.dart';
import 'package:foodapp/models/user.dart';
import 'package:foodapp/screens/admin%20panel/adminpanelscreen.dart';
import 'package:foodapp/screens/favourits/favouritsScreen.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/screens/oredrs/ordersScreeen.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/screens/profile/states.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/screens/resturants/resturantScreen.dart';
import 'package:foodapp/screens/settings/settingsScreen.dart';
import 'package:foodapp/shared/local_storage.dart';
import 'package:foodapp/shared/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Layoutcubit extends Cubit<Layoutstates> {
  Layoutcubit() : super(LayoutInitState()) {
    // Initialize asynchronously but handle errors
    _safeInitialize();
  }

  static Layoutcubit get(context) => BlocProvider.of(context);

  // Admin user ID
  static const String adminUserId = "yzPSwbiWTgXywHPVyBXhjfZGjR42";
  bool isAdminUser = false;

  ThemeData isdark = lightTheme;
  int currentindex = 0;
  List<IconData> bottomnav = [
    Icons.home,
    Icons.favorite_outline,
    Icons.list_alt_rounded,
    Icons.account_circle_outlined,
  ];

  // Default screens for regular users
  List<Widget> screens = [
    const Resturantscreen(),
    const FavouritsScreen(),
    const Ordersscreeen(),
    const Settingsscreen(),
  ];

  // Default titles for regular users
  List<String> titles(BuildContext context) {
    if (isAdminUser) {
      return ["Restaurants", S.of(context).admin_panel];
    } else {
      return [
        "Restaurants",
        S.of(context).favourits,
        S.of(context).orders,
        S.of(context).settings,
      ];
    }
  }

  List<CartItem> cartitems = [];

  bool isArabic = false;

  // Safe initialization method that won't crash the app
  Future<void> _safeInitialize() async {
    try {
      await _initializeTheme();
      await _loadCartItems();
    } catch (e) {
      print("Error during initialization: $e");
      // Emit default state to ensure UI renders something
      emit(LayoutInitState());
    }
  }

  // Initialize theme from shared preferences
  Future<void> _initializeTheme() async {
    try {
      bool isDarkMode = await LocalStorageService.isDarkMode();
      isdark = isDarkMode ? darkTheme : lightTheme;
      emit(LayoutChangeThemeState());
    } catch (e) {
      print("Error initializing theme: $e");
      // Default to light theme on error
      isdark = lightTheme;
      emit(LayoutChangeThemeState());
    }
  }

  // Load cart items from local storage
  Future<void> _loadCartItems() async {
    try {
      print('\n=== CUBIT: Loading cart items on app startup ===');

      // Check if this is a fresh install or if user wants to start clean
      final prefs = await SharedPreferences.getInstance();
      bool isFirstRun = prefs.getBool('first_run') ?? true;

      if (isFirstRun) {
        print('CUBIT: First run detected - clearing any existing cart data');
        await LocalStorageService.clearCartItems();
        await prefs.setBool('first_run', false);
        print('CUBIT: Cart cleared for fresh start');
        return;
      }

      List<CartItem> savedItems = await LocalStorageService.getCartItems();
      print('CUBIT: Found ${savedItems.length} saved cart items');

      if (savedItems.isNotEmpty) {
        cartitems = savedItems;
        print('CUBIT: Loaded cart items into cubit');
        for (int i = 0; i < cartitems.length; i++) {
          print(
            'CUBIT: Item #${i + 1}: ${cartitems[i].name} from ${cartitems[i].restaurantName}',
          );
        }
        emit(LayoutCartUpdatedState());
      } else {
        print('CUBIT: No cart items to load');
      }
      print('=== END CUBIT CART LOADING ===\n');
    } catch (e) {
      print("Error loading cart items: $e");
      // Continue with empty cart
    }
  }

  // Check if current user is admin and update UI accordingly
  void checkAndSetAdminStatus(String userId) {
    // Check both the hardcoded admin ID and the isAdmin field
    const adminId = "yzPSwbiWTgXywHPVyBXhjfZGjR42";
    isAdminUser = (userId == adminId);

    // If the cubit is already initialized and user data is loaded
    if (navigatorKey.currentContext != null) {
      final profileCubit = ProfileCubit.get(navigatorKey.currentContext!);
      if (profileCubit.state is ProfileLoaded) {
        isAdminUser = isAdminUser || profileCubit.user.isAdmin;
      }
    }

    if (isAdminUser) {
      // Admin user should only see Home and Admin Panel
      bottomnav = [Icons.home, Icons.admin_panel_settings];

      screens = [const Resturantscreen(), const AdminPanelScreen()];

      // If admin is on a screen that's no longer available, reset to home
      if (currentindex > 1) {
        currentindex = 0;
      }
    } else {
      // Regular user sees all screens
      bottomnav = [
        Icons.home,
        Icons.favorite_outline,
        Icons.list_alt_rounded,
        Icons.account_circle_outlined,
      ];

      screens = [
        const Resturantscreen(),
        const FavouritsScreen(),
        const Ordersscreeen(),
        const Settingsscreen(),
      ];
    }

    // Use a microtask to ensure this happens after any current build cycle
    Future.microtask(() {
      emit(LayoutChangeNavBar());
    });
  }

  // Check if user is logged in and show login dialog if not
  bool checkUserLoggedIn(BuildContext context, {required String feature}) {
    if (FirebaseAuth.instance.currentUser == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.of(context).login_required),
          content: Text(feature),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Loginscreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 74, 26, 15),
                foregroundColor: Colors.white,
              ),
              child: Text(S.of(context).log_in),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  void addToCart({
    required BuildContext context,
    required String name,
    required String nameAr,
    required double price,
    required int quantity,
    required String img,
    String? comment,
    required String restaurantId,
    required String restaurantName,
    required String restaurantNameAr,
    required String deliveryFee,
  }) {
    // Don't allow admin to add to cart
    if (isAdminUser) return;

    // Check if user is logged in
    if (!checkUserLoggedIn(context, feature: "add items to cart")) {
      return;
    }

    print("\n=== Adding Item to Cart ===");
    print("Restaurant: $restaurantName");
    print("Restaurant ID: $restaurantId");
    print("Item: $name");
    print("Quantity to add: $quantity");
    print("Original Delivery Fee: $deliveryFee");
    print("Comment: '${comment ?? 'null'}'");
    print("Current cart has ${cartitems.length} items");

    // Clean and trim restaurant ID
    String cleanRestaurantId = restaurantId.trim();

    // Clean delivery fee before creating cart item
    String cleanFee = deliveryFee.replaceAll(RegExp(r'[^0-9.]'), '');
    print("Cleaned Delivery Fee: $cleanFee");

    try {
      double parsedFee = double.parse(cleanFee);
      print("Parsed Delivery Fee: $parsedFee");
    } catch (e) {
      print("Error parsing delivery fee: $e");
    }

    // Validate and sanitize image URL to prevent invalid URIs
    String sanitizedImg = img;
    if (img.isEmpty ||
        (!img.startsWith('http') && !img.startsWith('assets/'))) {
      sanitizedImg = 'assets/images/items/default.jpg';
    }

    // Check if the same item from the same restaurant already exists in cart
    int existingItemIndex = findExistingCartItemIndex(
      name: name,
      restaurantId: cleanRestaurantId,
      price: price,
      comment: comment,
    );

    if (existingItemIndex != -1) {
      print(
        "🔄 Found existing item at index $existingItemIndex with quantity ${cartitems[existingItemIndex].quantity}",
      );
    }

    if (existingItemIndex != -1) {
      // Item already exists - increase quantity instead of adding duplicate
      cartitems[existingItemIndex].quantity += quantity;
      print(
        "✅ Updated existing item quantity to ${cartitems[existingItemIndex].quantity}",
      );
    } else {
      // Item doesn't exist - create new cart item
      CartItem newItem = CartItem(
        id: DateTime.now().toString(),
        name: name,
        nameAr: nameAr,
        price: price,
        quantity: quantity,
        img: sanitizedImg,
        comment: comment,
        restaurantId: cleanRestaurantId,
        restaurantName: restaurantName,
        restaurantNameAr: restaurantNameAr,
        deliveryFee: deliveryFee,
      );

      print("✅ Created new CartItem with delivery fee: ${newItem.deliveryFee}");
      print("Restaurant ID in CartItem: ${newItem.restaurantId}");

      cartitems.add(newItem);
    }

    LocalStorageService.saveCartItems(cartitems);
    emit(LayoutCartUpdatedState());

    // Also update the user's cart in the ProfileCubit if available
    try {
      ProfileCubit profileCubit = ProfileCubit.get(
        navigatorKey.currentContext!,
      );
      profileCubit.user.cart = cartitems;
    } catch (e) {
      print("Could not sync cart with ProfileCubit: $e");
    }

    print("=== Cart Updated ===\n");
  }

  void changenavbar(index) {
    // Don't emit a state if we're already on this tab
    if (currentindex == index) return;

    // Ensure index is within bounds based on admin status
    if (isAdminUser && index >= bottomnav.length) {
      index = 0;
    }

    // If trying to access favorites or orders, check login status
    if (index == 1 && !isAdminUser) {
      // This is the favorites tab for regular users
      if (!checkUserLoggedIn(
        navigatorKey.currentContext!,
        feature: S.of(navigatorKey.currentContext!).login_to_favorites,
      )) {
        return; // Stay on current tab
      }
    }

    if (index == 2 && !isAdminUser) {
      // This is the orders tab for regular users
      if (!checkUserLoggedIn(
        navigatorKey.currentContext!,
        feature: S.of(navigatorKey.currentContext!).login_to_orders,
      )) {
        return; // Stay on current tab
      }
    }

    currentindex = index;
    emit(LayoutChangeNavBar());
  }

  void increaseQuantity(int index) {
    if (isAdminUser) return;

    cartitems[index].quantity++;
    LocalStorageService.saveCartItems(cartitems);
    emit(UpdateCartState());
  }

  void decreaseQuantity(int index) {
    if (isAdminUser) return;

    if (cartitems[index].quantity > 1) {
      cartitems[index].quantity--;
      LocalStorageService.saveCartItems(cartitems);
      emit(UpdateCartState());
    }
  }

  void removeItemFromCart(int index) {
    if (isAdminUser) return;

    cartitems.removeAt(index);
    LocalStorageService.saveCartItems(cartitems);
    emit(UpdateCartState());
  }

  // Calculate total delivery fees from all restaurants
  double calculateDeliveryFees() {
    Map<String, double> restaurantFees = {};

    print('\nCalculating delivery fees:');
    for (var item in cartitems) {
      if (!restaurantFees.containsKey(item.restaurantId)) {
        // Parse delivery fee
        String cleanFee = item.deliveryFee.replaceAll(RegExp(r'[^0-9.]'), '');
        print('Original delivery fee: ${item.deliveryFee}');
        print('Cleaned fee string: $cleanFee');

        double fee = 0.0;
        try {
          fee = double.parse(cleanFee);
        } catch (e) {
          print('Error parsing delivery fee: $e');
          fee = 0.0;
        }
        print('Parsed fee: $fee');

        if (fee > 0) {
          restaurantFees[item.restaurantId] = fee;
          print('Restaurant: ${item.restaurantName}');
          print('- Original fee: ${item.deliveryFee}');
          print('- Parsed fee: $fee EGP');
        }
      }
    }

    double totalFees = restaurantFees.values.fold(0, (sum, fee) => sum + fee);
    print('\nDelivery fees breakdown:');
    restaurantFees.forEach((restaurantId, fee) {
      print(
        '- ${cartitems.firstWhere((item) => item.restaurantId == restaurantId).restaurantName}: $fee EGP',
      );
    });
    print('Total delivery fees: $totalFees EGP\n');
    return totalFees;
  }

  // Calculate subtotal (items only)
  double calculateSubtotal() {
    print('\nCalculating subtotal:');
    double total = cartitems.fold(0, (sum, item) {
      double itemTotal = item.price * item.quantity;
      print('- ${item.name}:');
      print('  * Price: ${item.price} EGP');
      print('  * Quantity: ${item.quantity}');
      print('  * Total: $itemTotal EGP');
      return sum + itemTotal;
    });
    print('Subtotal: $total EGP\n');
    return total;
  }

  // Calculate total price including delivery fees and out-of-area fees
  double calculateTotalPrice({double? promoDiscount}) {
    print('\n=== DEBUGGING Cart Total Calculation ===');

    // Calculate subtotal (items only)
    double subtotal = cartitems.fold(0, (sum, item) {
      double itemTotal = item.price * item.quantity;
      print(
        '- ${item.name}: ${item.price} × ${item.quantity} = $itemTotal EGP',
      );
      return sum + itemTotal;
    });
    print('Subtotal (items only): $subtotal EGP');

    // Print all cart items with restaurant information for debugging
    print('\nCurrent cart contains ${cartitems.length} items:');
    for (int i = 0; i < cartitems.length; i++) {
      print('ITEM #$i');
      print('- Name: ${cartitems[i].name}');
      print('- Restaurant: ${cartitems[i].restaurantName}');
      print(
        '- Restaurant ID: "${cartitems[i].restaurantId}"',
      ); // Note the quotes to see whitespace
      print('- Delivery Fee: ${cartitems[i].deliveryFee}');
    }

    // Group items by restaurant to avoid duplicate fees
    Map<String, List<CartItem>> itemsByRestaurant = {};
    print('\nGrouping items by restaurant ID:');
    for (var item in cartitems) {
      String resId = item.restaurantId.trim();
      print(
        'Processing item ${item.name} from restaurant ${item.restaurantName} with ID "$resId"',
      );

      if (!itemsByRestaurant.containsKey(resId)) {
        itemsByRestaurant[resId] = [];
        print(
          '  - Created new group for restaurant: ${item.restaurantName} (ID: $resId)',
        );
      } else {
        print(
          '  - Adding to existing group for restaurant: ${item.restaurantName} (ID: $resId)',
        );
      }
      itemsByRestaurant[resId]!.add(item);
    }

    print(
      '\nAfter grouping: Found ${itemsByRestaurant.length} unique restaurants in cart',
    );
    itemsByRestaurant.forEach((resId, items) {
      print(
        'Restaurant group "$resId": ${items.length} items from ${items.first.restaurantName}',
      );
    });

    // Calculate delivery fees INCLUDING out-of-area fees
    double totalDeliveryFees = 0.0;
    double totalOutOfAreaFees = 0.0;
    print('\nCalculating Delivery Fees with Out-of-Area Logic:');

    itemsByRestaurant.forEach((restaurantId, items) {
      if (items.isNotEmpty) {
        try {
          // Get the context from the navigator key
          BuildContext? context = navigatorKey.currentContext;
          if (context != null) {
            // Use the helper method that calculates the breakdown correctly
            Map<String, double> feeBreakdown =
                _calculateDeliveryFeeBreakdownInCubit(
                    context, restaurantId, items.first.deliveryFee);

            double baseFee = feeBreakdown['baseFee'] ?? 0.0;
            double outOfAreaFee = feeBreakdown['outOfAreaFee'] ?? 0.0;

            totalDeliveryFees += baseFee;
            totalOutOfAreaFees += outOfAreaFee;

            print(
              '- ${items.first.restaurantName} (ID: "$restaurantId"): Base Fee $baseFee EGP, Out-of-Area $outOfAreaFee EGP',
            );
          } else {
            // Fallback to simple parsing if no context available
            String baseFee = items.first.deliveryFee;
            String cleanFee = baseFee.replaceAll(RegExp(r'[^0-9.]'), '');
            double fee = double.parse(cleanFee.isEmpty ? '0' : cleanFee);
            totalDeliveryFees += fee;
            print(
              '- ${items.first.restaurantName} (ID: "$restaurantId"): $fee EGP (fallback)',
            );
          }
        } catch (e) {
          print(
            'Error calculating delivery fee for ${items.first.restaurantName}: $e',
          );
          // Use default fee on error
          totalDeliveryFees += 50.0;
        }
      }
    });

    print(
      'Total base delivery fees from all restaurants: $totalDeliveryFees EGP',
    );
    print('Total out-of-area fees: $totalOutOfAreaFees EGP');

    // Calculate final total INCLUDING out-of-area fees
    double total = subtotal + totalDeliveryFees + totalOutOfAreaFees;

    // Apply promocode discount if provided
    if (promoDiscount != null && promoDiscount > 0) {
      print('\nApplying promocode discount: $promoDiscount EGP');
      total = total - promoDiscount;
      // Ensure total is never negative
      if (total < 0) total = 0;
    }

    // Print breakdown of total
    print('\nFinal Breakdown:');
    print('- Subtotal (all items): $subtotal EGP');
    print(
      '- Base Delivery Fees (${itemsByRestaurant.length} restaurants): $totalDeliveryFees EGP',
    );
    if (totalOutOfAreaFees > 0) {
      print('- Out-of-Area Fees: $totalOutOfAreaFees EGP');
    }
    if (promoDiscount != null && promoDiscount > 0) {
      print('- Promocode Discount: -$promoDiscount EGP');
    }
    print('- TOTAL: $total EGP');
    print('=== End of Cart Calculation ===\n');

    return total;
  }

  // Helper method to calculate delivery fee breakdown (matching layout.dart logic)
  Map<String, double> _calculateDeliveryFeeBreakdownInCubit(
      BuildContext context, String restaurantId, String baseFee) {
    try {
      // Get necessary cubits
      final profileCubit = ProfileCubit.get(context);
      final restaurantCubit = Restuarantscubit.get(context);
      String userArea = profileCubit.user.selectedArea;

      // Parse base delivery fee
      double baseDeliveryFee = 0.0;
      try {
        String cleanBaseFee = baseFee.replaceAll(RegExp(r'[^0-9.]'), '');
        if (cleanBaseFee.isEmpty) {
          baseDeliveryFee = 50.0;
        } else {
          baseDeliveryFee = double.parse(cleanBaseFee);
        }
      } catch (e) {
        baseDeliveryFee = 50.0; // Default fallback
      }

      // If user area is empty/default, return base fee only
      if (userArea.isEmpty || userArea == 'Cairo' || userArea == 'All') {
        return {'baseFee': baseDeliveryFee, 'outOfAreaFee': 0.0};
      }

      // Try to find the restaurant in the cubit to get the real out-of-area fee
      try {
        // Try exact match first
        var restaurant = restaurantCubit.restaurants.firstWhere(
          (r) => r.id == restaurantId,
          orElse: () => throw Exception('Restaurant not found'),
        );

        // Check if user is in restaurant's main areas (no out-of-area fee)
        bool userIsInMainAreas = restaurant.mainAreas.any((mainArea) =>
            mainArea.trim().toLowerCase() == userArea.trim().toLowerCase());

        if (userIsInMainAreas) {
          // User is in main service area - no out-of-area fee
          return {'baseFee': baseDeliveryFee, 'outOfAreaFee': 0.0};
        } else {
          // Check if user is in secondary areas (charge out-of-area fee)
          bool userIsInSecondaryAreas = restaurant.secondaryAreas.any((area) =>
              area.trim().toLowerCase() == userArea.trim().toLowerCase());

          if (userIsInSecondaryAreas) {
            // Parse the restaurant's specific out-of-area fee
            double outOfAreaFee = 0.0;
            try {
              String cleanOutOfAreaFee = (restaurant.outOfAreaFee ?? '0')
                  .replaceAll(RegExp(r'[^0-9.]'), '');
              if (cleanOutOfAreaFee.isNotEmpty) {
                outOfAreaFee = double.parse(cleanOutOfAreaFee);
              }
            } catch (e) {
              outOfAreaFee = 20.0; // Default fallback
            }

            // If no specific out-of-area fee is set, use default
            if (outOfAreaFee == 0) {
              outOfAreaFee = 20.0;
            }

            return {'baseFee': baseDeliveryFee, 'outOfAreaFee': outOfAreaFee};
          } else {
            // User is not in any service area - restaurant doesn't serve this area
            return {'baseFee': baseDeliveryFee, 'outOfAreaFee': 0.0};
          }
        }
      } catch (e) {
        // Restaurant not found in cubit, try trimmed comparison
        try {
          var restaurant = restaurantCubit.restaurants.firstWhere(
            (r) => r.id.trim() == restaurantId.trim(),
            orElse: () => throw Exception('Restaurant not found'),
          );

          // Same logic as above for trimmed match
          bool userIsInMainAreas = restaurant.mainAreas.any((mainArea) =>
              mainArea.trim().toLowerCase() == userArea.trim().toLowerCase());

          if (userIsInMainAreas) {
            return {'baseFee': baseDeliveryFee, 'outOfAreaFee': 0.0};
          } else {
            bool userIsInSecondaryAreas = restaurant.secondaryAreas.any(
                (area) =>
                    area.trim().toLowerCase() == userArea.trim().toLowerCase());

            if (userIsInSecondaryAreas) {
              double outOfAreaFee = 0.0;
              try {
                String cleanOutOfAreaFee = (restaurant.outOfAreaFee ?? '0')
                    .replaceAll(RegExp(r'[^0-9.]'), '');
                if (cleanOutOfAreaFee.isNotEmpty) {
                  outOfAreaFee = double.parse(cleanOutOfAreaFee);
                }
              } catch (e) {
                outOfAreaFee = 20.0;
              }

              if (outOfAreaFee == 0) {
                outOfAreaFee = 20.0;
              }

              return {'baseFee': baseDeliveryFee, 'outOfAreaFee': outOfAreaFee};
            } else {
              return {'baseFee': baseDeliveryFee, 'outOfAreaFee': 0.0};
            }
          }
        } catch (e2) {
          print('Restaurant not found in cubit: $restaurantId');
          // Fallback - if user is not in default areas, apply default out-of-area fee
          if (userArea != 'Cairo' && userArea != 'All' && userArea.isNotEmpty) {
            return {'baseFee': baseDeliveryFee, 'outOfAreaFee': 20.0};
          }
          return {'baseFee': baseDeliveryFee, 'outOfAreaFee': 0.0};
        }
      }
    } catch (e) {
      print('Error in delivery fee breakdown calculation: $e');
      // Return parsed base fee as fallback
      try {
        String cleanBaseFee = baseFee.replaceAll(RegExp(r'[^0-9.]'), '');
        double fallbackFee = double.parse(cleanBaseFee);
        return {'baseFee': fallbackFee, 'outOfAreaFee': 0.0};
      } catch (e2) {
        return {'baseFee': 50.0, 'outOfAreaFee': 0.0};
      }
    }
  }

  void toggletheme() async {
    if (isdark == lightTheme) {
      isdark = darkTheme;
      await LocalStorageService.saveThemeMode(true);
    } else {
      isdark = lightTheme;
      await LocalStorageService.saveThemeMode(false);
    }
    emit(LayoutChangeThemeState());
  }

  // Clear cart items
  void clearCart() {
    cartitems.clear();
    LocalStorageService.saveCartItems(cartitems);
    emit(UpdateCartState());
  }

  void changeLanguage() {
    isArabic = !isArabic;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isArabic', isArabic);
    });
    emit(ChangeLanguageState());
  }

  void loadSavedLanguage() {
    SharedPreferences.getInstance().then((prefs) {
      isArabic = prefs.getBool('isArabic') ?? false;
      S.load(isArabic ? const Locale('ar') : const Locale('en'));
      emit(LoadSavedLanguageState());
    });
  }

  // Helper method to find existing cart item
  int findExistingCartItemIndex({
    required String name,
    required String restaurantId,
    required double price,
    String? comment,
  }) {
    String cleanRestaurantId = restaurantId.trim();

    print("\n🔍 === SEARCHING FOR EXISTING CART ITEM ===");
    print("Looking for:");
    print("- Name: '$name'");
    print("- Restaurant ID: '$cleanRestaurantId'");
    print("- Price: $price");
    print("- Comment: '${(comment ?? '').trim()}'");
    print("\nChecking against ${cartitems.length} existing cart items:");

    for (int i = 0; i < cartitems.length; i++) {
      CartItem item = cartitems[i];
      print("\nItem #$i:");
      print("- Name: '${item.name}' (match: ${item.name == name})");
      print(
        "- Restaurant ID: '${item.restaurantId.trim()}' (match: ${item.restaurantId.trim() == cleanRestaurantId})",
      );
      print(
        "- Price: ${item.price} (match: ${(item.price - price).abs() < 0.01})",
      );
      print(
        "- Comment: '${(item.comment ?? '').trim()}' (match: ${(item.comment ?? '').trim() == (comment ?? '').trim()})",
      );

      bool nameMatch = item.name == name;
      bool restaurantMatch = item.restaurantId.trim() == cleanRestaurantId;
      bool priceMatch = (item.price - price).abs() <
          0.01; // Use epsilon comparison for doubles
      bool commentMatch = (item.comment ?? '').trim() ==
          (comment ?? '').trim(); // Normalize comment comparison

      print(
        "- Overall match: ${nameMatch && restaurantMatch && priceMatch && commentMatch}",
      );

      if (nameMatch && restaurantMatch && priceMatch && commentMatch) {
        print("✅ FOUND EXISTING ITEM AT INDEX $i");
        return i;
      }
    }

    print("❌ NO EXISTING ITEM FOUND");
    print("=== END SEARCH ===\n");
    return -1;
  }

  // Debug method to check cart storage
  Future<void> debugCartStorage() async {
    print('=== CART STORAGE DEBUG ===');
    print('Current cart items: ${cartitems.length}');
    for (int i = 0; i < cartitems.length; i++) {
      print(
          'Item $i: ${cartitems[i].name} from ${cartitems[i].restaurantName}');
    }
    print('=== END DEBUG ===');
  }

  // Force clear cart storage (for debugging)
  Future<void> forceClearCartStorage() async {
    print('=== FORCE CLEARING CART STORAGE ===');
    cartitems.clear();
    await LocalStorageService.clearCartItems();
    emit(UpdateCartState());
    print('Cart storage and cubit cart cleared');
  }
}
