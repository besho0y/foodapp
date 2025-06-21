import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/favourits/states.dart';
import 'package:foodapp/shared/auth_helper.dart';
import 'package:foodapp/shared/colors.dart';
import 'package:foodapp/widgets/itemcard.dart';

class FavouritsScreen extends StatelessWidget {
  const FavouritsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    if (!AuthHelper.isUserLoggedIn()) {
      return ThemeBasedBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 100.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Please login to view your favorites',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () =>
                      AuthHelper.requireAuthenticationForFavorites(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocBuilder<Favouritecubit, FavouriteState>(
      builder: (context, state) {
        var cubit = Favouritecubit.get(context);

        if (state is FavouriteLoadingState) {
          return const ThemeBasedBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (cubit.favourites.isEmpty) {
          return ThemeBasedBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 100.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      S.of(context).no_favorites,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ThemeBasedBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: RefreshIndicator(
              onRefresh: () async {
                await cubit.loadFavourites();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: cubit.favourites.length,
                itemBuilder: (context, index) {
                  return itemcard(
                    context,
                    true,
                    cubit.favourites[index],
                    null,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDebugInfo(BuildContext context) {
    // Get user ID and favorites data from Firestore
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showDebugDialog(
          context, "Not logged in", "No user is currently logged in.");
      return;
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get()
        .then((userDoc) {
      if (!userDoc.exists || userDoc.data() == null) {
        _showDebugDialog(context, "User Not Found",
            "User document doesn't exist in Firestore.");
        return;
      }

      final userData = userDoc.data()!;
      final favourites = userData['favourites'] ?? [];
      final addresses = userData['addresses'] ?? [];

      String message = """
User ID: ${currentUser.uid}

Favourites IDs (${favourites.length}): 
${favourites.join('\n')}

Addresses (${addresses.length})
""";

      _showDebugDialog(context, "User Data", message);
    }).catchError((error) {
      _showDebugDialog(context, "Error", "Failed to load user data: $error");
    });
  }

  void _showDebugDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
