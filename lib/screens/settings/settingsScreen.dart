import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/screens/admin%20panel/adminpanelscreen.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/screens/profile/profileScreen.dart';
import 'package:foodapp/screens/settingdetailsscreen/settingdetails.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/shared/local_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class Settingsscreen extends StatelessWidget {
  const Settingsscreen({super.key});

  Future<void> _showLogoutConfirmation(BuildContext context) async {
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
                      color: Theme.of(context).brightness == Brightness.dark
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

    if (confirm && context.mounted) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        print('Current user before sign out: ${currentUser?.email}');

        // Clear cart items from local storage
        await LocalStorageService.clearCartItems();

        // Clear cart items from cubit
        Layoutcubit.get(context).clearCart();

        // Clear favorites from cubit
        try {
          Favouritecubit.get(context).clearFavorites();
        } catch (e) {
          print("Error clearing favorites on logout: $e");
        }

        await FirebaseAuth.instance.signOut();

        final userAfterSignOut = FirebaseAuth.instance.currentUser;
        print('User after sign out: $userAfterSignOut');

        if (context.mounted) {
          print('Navigating to home screen after logout');

          // Get the Layout from the widget tree
          const layoutWidget = Layout();

          // Navigate to Layout with reset navigation
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => layoutWidget),
            (route) => false,
          );

          // Access the Layoutcubit to ensure we're on the first tab (index 0)
          if (context.mounted) {
            Future.delayed(const Duration(milliseconds: 100), () {
              final layoutCubit = Layoutcubit.get(context);
              layoutCubit.changenavbar(0); // Change to the first tab
            });
          }
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
  }

  Future<void> _openWhatsAppWithContext(BuildContext context) async {
    const phoneNumber = '+201274939902';
    const whatsappUrl = 'https://wa.me/$phoneNumber';

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
    // Check if user is logged in
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),

          // Show Profile option only if logged in
          if (isLoggedIn)
            GestureDetector(
              onTap: () => navigateTo(context, const Profilescreen()),
              child: Card(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      SizedBox(width: 5.w),
                      Text(
                        S.of(context).profile,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          GestureDetector(
            onTap: () => navigateTo(context, const Settingdetails()),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                child: Row(
                  children: [
                    const Icon(Icons.settings),
                    SizedBox(width: 5.w),
                    Text(
                      S.of(context).settings,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contact us is always shown
          GestureDetector(
            onTap: () => _openWhatsAppWithContext(context),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                child: Row(
                  children: [
                    const Icon(Icons.call),
                    SizedBox(width: 5.w),
                    Text(
                      S.of(context).contact_us,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Admin panel option
          if (isLoggedIn)
            FutureBuilder<bool>(
              future: _isUserAdmin(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return GestureDetector(
                    onTap: () => navigateTo(context, const AdminPanelScreen()),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.h, horizontal: 5.w),
                        child: Row(
                          children: [
                            const Icon(Icons.admin_panel_settings),
                            SizedBox(width: 5.w),
                            Text(
                              S.of(context).admin_panel,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

          // Show Login or Logout based on authentication state
          GestureDetector(
            onTap: isLoggedIn
                ? () => _showLogoutConfirmation(context)
                : () => navigateTo(context, const Loginscreen()),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                child: Row(
                  children: [
                    Icon(isLoggedIn ? Icons.logout : Icons.login),
                    SizedBox(width: 5.w),
                    Text(
                      isLoggedIn ? S.of(context).logout : S.of(context).login,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
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
