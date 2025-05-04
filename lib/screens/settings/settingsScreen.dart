import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:foodapp/screens/admin%20panel/adminpanelscreen.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/screens/profile/profileScreen.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class Settingsscreen extends StatelessWidget {
  const Settingsscreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      print('Current user before sign out: ${currentUser?.email}');

      await FirebaseAuth.instance.signOut();

      final userAfterSignOut = FirebaseAuth.instance.currentUser;
      print('User after sign out: $userAfterSignOut');

      if (context.mounted) {
        print('Navigating to login screen...');
        navigateAndFinish(context, Loginscreen());
      }
    } catch (error) {
      print('Sign out error: $error');
      if (context.mounted) {
        showToast(
          "Failed to sign out: ${error.toString()}",
          context: context,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
          textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
          position: StyledToastPosition.bottom,
        );
      }
    }
  }

  Future<void> _openWhatsAppWithContext(BuildContext context) async {
    const phoneNumber = '+201274939902';
    final whatsappUrl = 'https://wa.me/$phoneNumber';

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        showToast(
          "Could not launch WhatsApp",
          context: context,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
          textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
          position: StyledToastPosition.bottom,
        );
      }
    } catch (e) {
      showToast(
        "Error opening WhatsApp: ${e.toString()}",
        context: context,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
        textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
        position: StyledToastPosition.bottom,
      );
    }
  }

  // Check if user is an admin
  Future<bool> _isUserAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // You can implement your admin check logic here
      // For example, checking if the user's email is in an admin list
      // or checking a specific field in the user's document in Firestore

      // For demonstration purposes, let's make a simple check
      // This should be replaced with your actual admin verification logic
      return user.email == 'admin@example.com';
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () => navigateTo(context, Profilescreen()),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 5.w),
                    Text(
                      "Profile",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart_outlined),
                  SizedBox(width: 5.w),
                  Text("Cart", style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _openWhatsAppWithContext(context),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                child: Row(
                  children: [
                    Icon(Icons.call),
                    SizedBox(width: 5.w),
                    Text(
                      "Contact Us",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
          FutureBuilder<bool>(
            future: _isUserAdmin(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return GestureDetector(
                  onTap: () => navigateTo(context, AdminPanelScreen()),
                  child: Card(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings),
                          SizedBox(width: 5.w),
                          Text(
                            "Admin Panel",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
          GestureDetector(
            onTap: () => _signOut(context),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 5.w),
                    Text("Logout",
                        style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
