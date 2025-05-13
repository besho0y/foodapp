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
      List<CartItem> savedItems = await LocalStorageService.getCartItems();
      if (savedItems.isNotEmpty) {
        cartitems = savedItems;
        emit(LayoutCartUpdatedState());
      }
    } catch (e) {
      print("Error loading cart items: $e");
      // Continue with empty cart
    }
  }

  // Check if current user is admin and update UI accordingly
  void checkAndSetAdminStatus(String userId) {
    isAdminUser = (userId == adminUserId);

    if (isAdminUser) {
      // Admin user should only see Home and Admin Panel
      bottomnav = [
        Icons.home,
        Icons.admin_panel_settings,
      ];

      screens = [
        const Resturantscreen(),
        const AdminPanelScreen(),
      ];

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

    emit(LayoutChangeNavBar());
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
                backgroundColor: Colors.red,
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
    print("Original Delivery Fee: $deliveryFee");

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

    CartItem newItem = CartItem(
      id: DateTime.now().toString(),
      name: name,
      nameAr: nameAr,
      price: price,
      quantity: quantity,
      img: sanitizedImg,
      comment: comment,
      restaurantId: restaurantId.trim(), // Ensure ID is trimmed
      restaurantName: restaurantName,
      restaurantNameAr: restaurantNameAr,
      deliveryFee: deliveryFee,
    );

    print("Created CartItem with delivery fee: ${newItem.deliveryFee}");
    print("Parsed fee from CartItem: ${newItem.getDeliveryFeeAsDouble()}");
    print("Restaurant ID in CartItem: ${newItem.restaurantId}");

    cartitems.add(newItem);
    LocalStorageService.saveCartItems(cartitems);
    emit(LayoutCartUpdatedState());

    // Also update the user's cart in the ProfileCubit if available
    try {
      ProfileCubit profileCubit =
          ProfileCubit.get(navigatorKey.currentContext!);
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
      if (!checkUserLoggedIn(navigatorKey.currentContext!,
          feature: S.of(navigatorKey.currentContext!).login_to_favorites)) {
        return; // Stay on current tab
      }
    }

    if (index == 2 && !isAdminUser) {
      // This is the orders tab for regular users
      if (!checkUserLoggedIn(navigatorKey.currentContext!,
          feature: S.of(navigatorKey.currentContext!).login_to_orders)) {
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
          '- ${cartitems.firstWhere((item) => item.restaurantId == restaurantId).restaurantName}: $fee EGP');
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

  // Calculate total price including delivery fees
  double calculateTotalPrice() {
    print('\n=== DEBUGGING Cart Total Calculation ===');

    // Calculate subtotal (items only)
    double subtotal = cartitems.fold(0, (sum, item) {
      double itemTotal = item.price * item.quantity;
      print(
          '- ${item.name}: ${item.price} × ${item.quantity} = $itemTotal EGP');
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
          '- Restaurant ID: "${cartitems[i].restaurantId}"'); // Note the quotes to see whitespace
      print('- Delivery Fee: ${cartitems[i].deliveryFee}');
    }

    // Group items by restaurant to avoid duplicate fees
    Map<String, List<CartItem>> itemsByRestaurant = {};
    print('\nGrouping items by restaurant ID:');
    for (var item in cartitems) {
      String resId = item.restaurantId.trim();
      print(
          'Processing item ${item.name} from restaurant ${item.restaurantName} with ID "$resId"');

      if (!itemsByRestaurant.containsKey(resId)) {
        itemsByRestaurant[resId] = [];
        print(
            '  - Created new group for restaurant: ${item.restaurantName} (ID: $resId)');
      } else {
        print(
            '  - Adding to existing group for restaurant: ${item.restaurantName} (ID: $resId)');
      }
      itemsByRestaurant[resId]!.add(item);
    }

    print(
        '\nAfter grouping: Found ${itemsByRestaurant.length} unique restaurants in cart');
    itemsByRestaurant.forEach((resId, items) {
      print(
          'Restaurant group "$resId": ${items.length} items from ${items.first.restaurantName}');
    });

    // Calculate delivery fees (one fee per restaurant)
    double totalDeliveryFees = 0.0;
    print('\nCalculating Delivery Fees:');

    itemsByRestaurant.forEach((restaurantId, items) {
      if (items.isNotEmpty) {
        // Use the delivery fee from the first item of each restaurant
        try {
          double fee = double.parse(items.first.deliveryFee);
          totalDeliveryFees += fee;
          print(
              '- ${items.first.restaurantName} (ID: "$restaurantId"): $fee EGP');
        } catch (e) {
          print(
              'Error parsing delivery fee for ${items.first.restaurantName}: $e');
        }
      }
    });

    print('Total delivery fees from all restaurants: $totalDeliveryFees EGP');

    // Calculate final total
    double total = subtotal + totalDeliveryFees;

    // Print breakdown of total
    print('\nFinal Breakdown:');
    print('- Subtotal (all items): $subtotal EGP');
    print(
        '- Delivery Fees (${itemsByRestaurant.length} restaurants): $totalDeliveryFees EGP');
    print('- Total: $total EGP');
    print('=== End of Cart Calculation ===\n');

    return total;
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
}
