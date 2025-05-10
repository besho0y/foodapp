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
    Resturantscreen(),
    Favouritsscreen(),
    Ordersscreeen(),
    Settingsscreen(),
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
        Resturantscreen(),
        AdminPanelScreen(),
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
        Resturantscreen(),
        Favouritsscreen(),
        Ordersscreeen(),
        Settingsscreen(),
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
                  MaterialPageRoute(builder: (context) => Loginscreen()),
                );
              },
              child: Text(S.of(context).log_in),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
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
    required double price,
    required int quantity,
    required String img,
    String? comment,
  }) {
    // Don't allow admin to add to cart
    if (isAdminUser) return;

    // Check if user is logged in
    if (!checkUserLoggedIn(context, feature: "add items to cart")) {
      return;
    }

    // Validate and sanitize image URL to prevent invalid URIs
    String sanitizedImg = img;

    // If image is empty or invalid, set a default asset path
    if (img.isEmpty ||
        (!img.startsWith('http') && !img.startsWith('assets/'))) {
      sanitizedImg = 'assets/images/items/default.jpg';
    }

    CartItem newItem = CartItem(
      id: DateTime.now().toString(),
      name: name,
      price: price,
      quantity: quantity,
      img: sanitizedImg,
      comment: comment,
    );

    cartitems.add(newItem);

    // Save to shared preferences
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

  double calculateTotalPrice() {
    double total = 0;
    for (var item in cartitems) {
      total += item.price * item.quantity;
    }
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

  void toggleLanguage() {
    isArabic = !isArabic;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isArabic', isArabic);
    });
    S.load(isArabic ? const Locale('ar') : const Locale('en'));
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
