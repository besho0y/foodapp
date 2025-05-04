import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/screens/admin%20panel/adminpanelscreen.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/shared/constants.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserAuth();
  }

  void _checkUserAuth() async {
    // Add a slight delay to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is logged in
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // User is logged in, get user data and navigate to layout
      ProfileCubit.get(context).getuserdata();
      navigateAndFinish(context, Layout());
    } else {
      // User is not logged in, navigate to login screen
      navigateAndFinish(context, Loginscreen());
    }
  }

  // For development and testing purposes
  void _goToAdminPanel() {
    navigateAndFinish(context, const AdminPanelScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or name
            const Icon(
              Icons.restaurant,
              size: 80,
              color: Colors.deepOrange,
            ),
            const SizedBox(height: 20),
            const Text(
              "Food App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
            const SizedBox(height: 50),
            // Test button for admin panel - REMOVE IN PRODUCTION
            ElevatedButton(
              onPressed: _goToAdminPanel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepOrange,
              ),
              child: const Text('Test Admin Panel'),
            ),
          ],
        ),
      ),
    );
  }
}
