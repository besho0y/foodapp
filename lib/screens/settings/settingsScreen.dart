import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/screens/profile/profileScreen.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class Settingsscreen extends StatelessWidget {
  const Settingsscreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      print('Attempting to sign out...');
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
        Fluttertoast.showToast(
            msg: "Failed to sign out: ${error.toString()}",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  Future<void> _openWhatsApp() async {
    const phoneNumber = '+201274939902';
    final whatsappUrl = 'https://wa.me/$phoneNumber';

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        Fluttertoast.showToast(
            msg: "Could not launch WhatsApp",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error opening WhatsApp: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
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
            onTap: _openWhatsApp,
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
