import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/shared/constants.dart';

class AuthHelper {
  /// Check if user is logged in
  static bool isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Get current user
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  /// Check authentication and navigate to login if not authenticated
  /// Returns true if user is authenticated, false if redirected to login
  static bool requireAuthentication(BuildContext context, {String? message}) {
    if (!isUserLoggedIn()) {
      // Show message if provided
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Navigate to login screen
      navigateTo(context, const Loginscreen());
      return false;
    }
    return true;
  }

  /// Check authentication for specific features
  static bool requireAuthenticationForFeature(
      BuildContext context, String feature) {
    String message = 'Please login to access $feature';
    return requireAuthentication(context, message: message);
  }

  /// Check authentication for orders
  static bool requireAuthenticationForOrders(BuildContext context) {
    return requireAuthenticationForFeature(context, 'your orders');
  }

  /// Check authentication for favorites
  static bool requireAuthenticationForFavorites(BuildContext context) {
    return requireAuthenticationForFeature(context, 'your favorites');
  }

  /// Check authentication for placing orders
  static bool requireAuthenticationForPlaceOrder(BuildContext context) {
    return requireAuthenticationForFeature(context, 'place an order');
  }

  /// Check authentication for profile
  static bool requireAuthenticationForProfile(BuildContext context) {
    return requireAuthenticationForFeature(context, 'your profile');
  }
}
