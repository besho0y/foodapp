import 'dart:convert';

import 'package:foodapp/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String CART_ITEMS_KEY = 'cart_items';
  static const String THEME_MODE_KEY = 'theme_mode';
  static const String SAVED_ADDRESSES_KEY = 'saved_addresses';
  static const String SAVED_PAYMENT_METHODS_KEY = 'saved_payment_methods';

  // Save cart items to local storage
  static Future<void> saveCartItems(List<CartItem> cartItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartItemsJson =
          cartItems.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(CART_ITEMS_KEY, cartItemsJson);
    } catch (e) {
      print("Error saving cart items: $e");
      // Silent fail - just log error
    }
  }

  // Get cart items from local storage
  static Future<List<CartItem>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartItemsJson = prefs.getStringList(CART_ITEMS_KEY) ?? [];
      return cartItemsJson
          .map((itemJson) => CartItem.fromJson(jsonDecode(itemJson)))
          .toList();
    } catch (e) {
      print("Error getting cart items: $e");
      // Return empty list on error
      return [];
    }
  }

  // Save theme mode to local storage
  static Future<void> saveThemeMode(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(THEME_MODE_KEY, isDarkMode);
    } catch (e) {
      print("Error saving theme mode: $e");
      // Silent fail - just log error
    }
  }

  // Get theme mode from local storage
  static Future<bool> isDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(THEME_MODE_KEY) ?? false;
    } catch (e) {
      print("Error getting theme mode: $e");
      // Default to light mode on error
      return false;
    }
  }

  // Save addresses to local storage
  static Future<void> saveAddresses(List<Address> addresses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson =
          addresses.map((address) => jsonEncode(address.toJson())).toList();
      await prefs.setStringList(SAVED_ADDRESSES_KEY, addressesJson);
    } catch (e) {
      print("Error saving addresses: $e");
      // Silent fail - just log error
    }
  }

  // Get addresses from local storage
  static Future<List<Address>> getAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getStringList(SAVED_ADDRESSES_KEY) ?? [];
      return addressesJson
          .map((addressJson) => Address.fromJson(jsonDecode(addressJson)))
          .toList();
    } catch (e) {
      print("Error getting addresses: $e");
      // Return empty list on error
      return [];
    }
  }

  // Save payment methods to local storage
  static Future<void> savePaymentMethod(
      Map<String, dynamic> paymentInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentMethods = await getPaymentMethods();
      final updatedPaymentMethods = [...paymentMethods, paymentInfo];

      final paymentMethodsJson =
          updatedPaymentMethods.map((method) => jsonEncode(method)).toList();

      await prefs.setStringList(SAVED_PAYMENT_METHODS_KEY, paymentMethodsJson);
    } catch (e) {
      print("Error saving payment method: $e");
      // Silent fail - just log error
    }
  }

  // Get payment methods from local storage
  static Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentMethodsJson =
          prefs.getStringList(SAVED_PAYMENT_METHODS_KEY) ?? [];

      return paymentMethodsJson
          .map((methodJson) => jsonDecode(methodJson) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error getting payment methods: $e");
      // Return empty list on error
      return [];
    }
  }

  // Clear all local storage data
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print("Error clearing local storage: $e");
      // Silent fail - just log error
    }
  }
}
