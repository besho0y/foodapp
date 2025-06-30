import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/states.dart';
import 'package:foodapp/main.dart';
import 'package:foodapp/models/resturant.dart';
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
    print('\n=== CART TOTAL CALCULATION WITH AREA LOGIC ===');

    // Step 1: Calculate subtotal (items only)
    double subtotal = cartitems.fold(0, (sum, item) {
      double itemTotal = item.price * item.quantity;
      print(
          '- ${item.name}: ${item.price} × ${item.quantity} = $itemTotal EGP');
      return sum + itemTotal;
    });
    print('Subtotal (items only): $subtotal EGP');

    // Step 2: Calculate delivery fees with area logic if context is available
    double totalDeliveryFees = 0.0;
    double totalOutOfAreaFees = 0.0;

    BuildContext? context = navigatorKey.currentContext;
    if (context != null) {
      try {
        // Use area-based calculation when context is available
        Map<String, double> feeBreakdown =
            calculateDeliveryFeesWithAreaLogic(context);
        totalDeliveryFees = feeBreakdown['baseFee'] ?? 0.0;
        totalOutOfAreaFees = feeBreakdown['outOfAreaFee'] ?? 0.0;
        print('Using area-based calculation:');
        print('- Base delivery fees: $totalDeliveryFees EGP');
        print('- Out-of-area fees: $totalOutOfAreaFees EGP');
      } catch (e) {
        print('Error in area-based calculation, falling back to simple: $e');
        // Fallback to simple calculation
        totalDeliveryFees = _calculateSimpleDeliveryFees();
        totalOutOfAreaFees = 0.0;
      }
    } else {
      print('No context available, using simple delivery fee calculation');
      // Fallback to simple calculation when no context
      totalDeliveryFees = _calculateSimpleDeliveryFees();
      totalOutOfAreaFees = 0.0;
    }

    // Step 3: Calculate total before discount
    double total = subtotal + totalDeliveryFees + totalOutOfAreaFees;
    print('Total before discount: $total EGP');

    // Step 4: Apply promocode discount if provided
    if (promoDiscount != null && promoDiscount > 0) {
      print('Applying promocode discount: $promoDiscount EGP');
      total = total - promoDiscount;
      // Ensure total is never negative
      if (total < 0) total = 0;
    }

    // Step 5: Print final breakdown
    print('\nFinal Breakdown:');
    print('- Subtotal (all items): $subtotal EGP');
    print('- Base delivery fees: $totalDeliveryFees EGP');
    if (totalOutOfAreaFees > 0) {
      print('- Out-of-area fees: $totalOutOfAreaFees EGP');
    }
    if (promoDiscount != null && promoDiscount > 0) {
      print('- Promocode discount: -$promoDiscount EGP');
    }
    print('- FINAL TOTAL: $total EGP');
    print('=== End of Cart Calculation ===\n');

    return total;
  }

  // Helper method for simple delivery fee calculation (fallback)
  double _calculateSimpleDeliveryFees() {
    // Group items by restaurant to avoid duplicate fees
    Map<String, List<CartItem>> itemsByRestaurant = {};
    for (var item in cartitems) {
      String resId = item.restaurantId.trim();
      if (!itemsByRestaurant.containsKey(resId)) {
        itemsByRestaurant[resId] = [];
      }
      itemsByRestaurant[resId]!.add(item);
    }

    double totalDeliveryFees = 0.0;
    itemsByRestaurant.forEach((restaurantId, items) {
      if (items.isNotEmpty) {
        try {
          String cleanFee =
              items.first.deliveryFee.replaceAll(RegExp(r'[^0-9.]'), '');
          double fee = double.parse(cleanFee.isEmpty ? '50' : cleanFee);
          totalDeliveryFees += fee;
        } catch (e) {
          totalDeliveryFees += 50.0; // Default fallback
        }
      }
    });

    return totalDeliveryFees;
  }

  // Calculate delivery fees with area-based logic (for UI breakdown display)
  Map<String, double> calculateDeliveryFeesWithAreaLogic(BuildContext context) {
    double totalBaseFee = 0.0;
    double totalOutOfAreaFee = 0.0;

    try {
      // Get user's selected area
      final profileCubit = ProfileCubit.get(context);
      final restaurantCubit = Restuarantscubit.get(context);
      String userArea = profileCubit.user.selectedArea;

      print('\n🏪 === AREA-BASED FEE CALCULATION ===');
      print('User selected area: "$userArea" (length: ${userArea.length})');
      print(
          'User data: ${profileCubit.user.name}, email: ${profileCubit.user.email}');
      print(
          'Available restaurants in cubit: ${restaurantCubit.restaurants.length}');

      // Debug: Show all restaurants and their areas
      print('\n🔍 === ALL RESTAURANTS AREAS DEBUG ===');
      for (int i = 0; i < restaurantCubit.restaurants.length; i++) {
        var restaurant = restaurantCubit.restaurants[i];
        print('Restaurant #$i: "${restaurant.name}"');
        print('  ID: "${restaurant.id}"');
        print('  Main Areas: ${restaurant.mainAreas}');
        print('  Secondary Areas: ${restaurant.secondaryAreas}');
        print('  Out-of-area Fee: "${restaurant.outOfAreaFee}"');
      }
      print('=== END ALL RESTAURANTS DEBUG ===\n');

      // Group items by restaurant
      Map<String, List<CartItem>> itemsByRestaurant = {};
      for (var item in cartitems) {
        String resId = item.restaurantId.trim();
        if (!itemsByRestaurant.containsKey(resId)) {
          itemsByRestaurant[resId] = [];
        }
        itemsByRestaurant[resId]!.add(item);
      }

      // Calculate fees for each restaurant with area logic
      itemsByRestaurant.forEach((restaurantId, items) {
        if (items.isNotEmpty) {
          // Parse base delivery fee
          double baseFee = 0.0;
          try {
            String cleanFee =
                items.first.deliveryFee.replaceAll(RegExp(r'[^0-9.]'), '');
            baseFee = double.parse(cleanFee.isEmpty ? '50' : cleanFee);
          } catch (e) {
            baseFee = 50.0;
          }

          totalBaseFee += baseFee;
          print('Restaurant: ${items.first.restaurantName}');
          print('- Base delivery fee: $baseFee EGP');

          // Check if we need to apply out-of-area fee
          double outOfAreaFee = _calculateOutOfAreaFee(
              context, restaurantId, userArea, restaurantCubit);

          if (outOfAreaFee > 0) {
            totalOutOfAreaFee += outOfAreaFee;
            print('- Out-of-area fee: $outOfAreaFee EGP');
          } else {
            print('- No out-of-area fee (user in main service area)');
          }
        }
      });

      print('Total base fees: $totalBaseFee EGP');
      print('Total out-of-area fees: $totalOutOfAreaFee EGP');
      print('=== END AREA-BASED CALCULATION ===\n');
    } catch (e) {
      print('Error in area-based calculation: $e');
      // Fallback to simple calculation
      Map<String, List<CartItem>> itemsByRestaurant = {};
      for (var item in cartitems) {
        String resId = item.restaurantId.trim();
        if (!itemsByRestaurant.containsKey(resId)) {
          itemsByRestaurant[resId] = [];
        }
        itemsByRestaurant[resId]!.add(item);
      }

      itemsByRestaurant.forEach((restaurantId, items) {
        if (items.isNotEmpty) {
          try {
            String cleanFee =
                items.first.deliveryFee.replaceAll(RegExp(r'[^0-9.]'), '');
            double fee = double.parse(cleanFee.isEmpty ? '50' : cleanFee);
            totalBaseFee += fee;
          } catch (e) {
            totalBaseFee += 50.0;
          }
        }
      });
    }

    return {
      'baseFee': totalBaseFee,
      'outOfAreaFee': totalOutOfAreaFee,
      'total': totalBaseFee + totalOutOfAreaFee
    };
  }

  // Helper method to calculate out-of-area fee for a specific restaurant
  double _calculateOutOfAreaFee(BuildContext context, String restaurantId,
      String userArea, dynamic restaurantCubit) {
    print('\n🔍 === OUT-OF-AREA FEE CALCULATION DEBUG ===');
    print('Restaurant ID: "$restaurantId"');
    print('User Area: "$userArea"');

    // If user area is empty or default, no out-of-area fee
    if (userArea.isEmpty || userArea == 'Cairo' || userArea == 'All') {
      print('❌ User area is empty/default - no out-of-area fee');
      print('=== END OUT-OF-AREA FEE CALCULATION ===\n');
      return 0.0;
    }

    try {
      // Try to find the restaurant in the cubit
      Restuarants? restaurant;
      try {
        restaurant = restaurantCubit.restaurants.firstWhere(
          (r) => r.id.trim() == restaurantId.trim(),
        );
      } catch (e) {
        restaurant = null;
      }

      if (restaurant == null) {
        print('❌ Restaurant not found in cubit for ID: $restaurantId');
        print(
            'Available restaurant IDs: ${restaurantCubit.restaurants.map((r) => r.id).toList()}');
        print('=== END OUT-OF-AREA FEE CALCULATION ===\n');
        return 0.0; // Changed: don't charge fee if restaurant not found
      }

      print('✅ Found restaurant: ${restaurant.name}');
      print('📍 Restaurant main areas: ${restaurant.mainAreas}');
      print('📍 Restaurant secondary areas: ${restaurant.secondaryAreas}');
      print(
          '💰 Restaurant out-of-area fee: "${restaurant.outOfAreaFee ?? 'null'}"');

      // Detailed area matching analysis
      print('\n🔍 AREA MATCHING ANALYSIS:');
      print('User area: "$userArea" (length: ${userArea.length})');
      print('User area cleaned: "${userArea.trim().toLowerCase()}"');

      // Check if user is in restaurant's main areas (no out-of-area fee)
      print('\n🏠 CHECKING MAIN AREAS (no fee):');
      bool userIsInMainAreas = false;
      for (int i = 0; i < restaurant.mainAreas.length; i++) {
        String mainArea = restaurant.mainAreas[i];
        String cleanMainArea = mainArea.trim().toLowerCase();
        String cleanUserArea = userArea.trim().toLowerCase();
        bool matches = cleanMainArea == cleanUserArea;

        print('  [$i] "$mainArea" → "$cleanMainArea" | Match: $matches');
        if (matches) {
          userIsInMainAreas = true;
        }
      }

      if (userIsInMainAreas) {
        print(
            '✅ RESULT: User "$userArea" is in MAIN service areas - NO EXTRA FEE');
        print('=== END OUT-OF-AREA FEE CALCULATION ===\n');
        return 0.0;
      }

      // Check if user is in restaurant's secondary areas (charge out-of-area fee)
      print('\n🏪 CHECKING SECONDARY AREAS (with fee):');
      bool userIsInSecondaryAreas = false;
      for (int i = 0; i < restaurant.secondaryAreas.length; i++) {
        String secondaryArea = restaurant.secondaryAreas[i];
        String cleanSecondaryArea = secondaryArea.trim().toLowerCase();
        String cleanUserArea = userArea.trim().toLowerCase();
        bool matches = cleanSecondaryArea == cleanUserArea;

        print(
            '  [$i] "$secondaryArea" → "$cleanSecondaryArea" | Match: $matches');
        if (matches) {
          userIsInSecondaryAreas = true;
        }
      }

      if (userIsInSecondaryAreas) {
        print(
            '⚠️ RESULT: User "$userArea" is in SECONDARY service areas - APPLYING OUT-OF-AREA FEE');

        // Parse the restaurant's specific out-of-area fee
        double outOfAreaFee = 0.0;
        try {
          String cleanOutOfAreaFee = (restaurant.outOfAreaFee ?? '0')
              .replaceAll(RegExp(r'[^0-9.]'), '');
          print(
              '💰 Parsing out-of-area fee: "${restaurant.outOfAreaFee}" → "$cleanOutOfAreaFee"');

          if (cleanOutOfAreaFee.isNotEmpty) {
            outOfAreaFee = double.parse(cleanOutOfAreaFee);
          }
        } catch (e) {
          print('❌ Error parsing restaurant out-of-area fee: $e');
        }

        // If no specific out-of-area fee is set, use default
        if (outOfAreaFee == 0) {
          outOfAreaFee = 20.0; // Default out-of-area fee
          print('💰 Using DEFAULT out-of-area fee: $outOfAreaFee EGP');
        } else {
          print(
              '💰 Using RESTAURANT-SPECIFIC out-of-area fee: $outOfAreaFee EGP');
        }

        print('=== END OUT-OF-AREA FEE CALCULATION ===\n');
        return outOfAreaFee;
      } else {
        print(
            '❌ RESULT: User "$userArea" is NOT in any restaurant service areas');
        print('🚫 Restaurant does not serve this area - no fee charged');
        print('=== END OUT-OF-AREA FEE CALCULATION ===\n');
        return 0.0; // Restaurant doesn't serve this area
      }
    } catch (e) {
      print('💥 Error checking restaurant areas: $e');
      print('=== END OUT-OF-AREA FEE CALCULATION ===\n');
      return 0.0; // Changed: don't charge fee on error
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
