import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/favourits/states.dart';
import 'package:foodapp/widgets/itemcard.dart';

class Favouritsscreen extends StatefulWidget {
  const Favouritsscreen({super.key});

  @override
  State<Favouritsscreen> createState() => _FavouritsscreenState();
}

class _FavouritsscreenState extends State<Favouritsscreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites when the screen is initialized
    Favouritecubit.get(context).loadFavourites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<Favouritecubit, FavouriteState>(
        listener: (context, state) {
          if (state is FavouriteErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          var cubit = Favouritecubit.get(context);

          if (state is FavouriteLoadingState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (cubit.favourites.isEmpty) {
            return RefreshIndicator(
              color: Colors.deepOrange,
              onRefresh: () {
                return cubit.loadFavourites();
              },
              child: ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 80.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "No Favorites Yet",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Items you mark as favorite will appear here",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return cubit.loadFavourites();
            },
            color: Colors.deepOrange,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: itemcard(context, true, cubit.favourites[index], []),
                  );
                },
                itemCount: cubit.favourites.length,
              ),
            ),
          );
        },
      ),
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
            child: Text("Close"),
          ),
        ],
      ),
    );
  }
}
