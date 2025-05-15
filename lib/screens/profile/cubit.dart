import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/user.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/screens/profile/states.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/shared/local_storage.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  static ProfileCubit get(context) => BlocProvider.of(context);
  late User user = User(
      name: "Loading...",
      phone: "0000000000",
      email: "loading@example.com",
      uid: "temp_uid");

  void getuserdata() async {
    // Don't emit multiple loading states if we're already loading
    if (state is ProfileLoading) return;

    emit(ProfileLoading());

    // Make sure current user exists
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      emit(ProfileError());
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        user = User.fromJson(userDoc.data()!);

        try {
          // Load saved addresses from SharedPreferences
          List<Address> localAddresses =
              await LocalStorageService.getAddresses();

          if (localAddresses.isNotEmpty) {
            // Create a map using a custom key to ensure uniqueness
            final Map<String, Address> uniqueAddresses = {};

            // Add Firestore addresses
            for (var addr in user.addresses) {
              String key = "${addr.title}_${addr.address}";
              uniqueAddresses[key] = addr;
            }

            // Add local addresses (will override Firestore addresses with same key)
            for (var addr in localAddresses) {
              String key = "${addr.title}_${addr.address}";
              uniqueAddresses[key] = addr;
            }

            // Convert back to list
            user.addresses = uniqueAddresses.values.toList();

            print("Loaded ${user.addresses.length} unique addresses");

            // Make sure there's only one default address
            bool hasDefault = false;
            for (int i = 0; i < user.addresses.length; i++) {
              if (user.addresses[i].isDefault) {
                if (hasDefault) {
                  user.addresses[i].isDefault = false;
                } else {
                  hasDefault = true;
                }
              }
            }

            // If no default address, set the first one as default
            if (!hasDefault && user.addresses.isNotEmpty) {
              user.addresses[0].isDefault = true;
            }

            // Update addresses in Firestore to ensure consistency
            await FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser.uid)
                .update({
              'addresses': user.addresses.map((addr) => addr.toJson()).toList(),
            });

            // Save the merged addresses back to local storage
            await LocalStorageService.saveAddresses(user.addresses);
          }

          // Load cart items from local storage
          user.cart = await LocalStorageService.getCartItems();
        } catch (e) {
          print("Error loading local storage data: $e");
          // Continue with default values from Firestore
        }

        // Use microtask to make sure this happens after the current execution
        Future.microtask(() {
          emit(ProfileLoaded(user));
        });
      } else {
        print("User document doesn't exist or data is null");
        emit(ProfileError());
      }
    } catch (error) {
      print("Error loading user data: $error");
      emit(ProfileError());
    }
  }

  Future<void> logout(BuildContext context) async {
    emit(ProfileLoading());
    try {
      await auth.FirebaseAuth.instance.signOut();
      await LocalStorageService.clearAll(); // Clear local storage on logout
      emit(ProfileLogoutSuccess());
      navigateAndFinish(context, const Loginscreen());
    } catch (error) {
      print("Error during logout: $error");
      emit(ProfileError());
    }
  }

  // Delete user account permanently
  Future<void> deleteAccount(BuildContext context) async {
    emit(ProfileLoading());
    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(ProfileError());
        return;
      }

      final String userId = currentUser.uid;

      // Delete user data from Firestore collections
      await _deleteUserData(userId);

      // Delete the user authentication account
      await currentUser.delete();

      // Clear local storage
      await LocalStorageService.clearAll();

      emit(ProfileAccountDeleted());
      navigateAndFinish(context, const Loginscreen());
    } catch (error) {
      print("Error deleting account: $error");

      // Handle specific error cases
      if (error is auth.FirebaseAuthException) {
        if (error.code == 'requires-recent-login') {
          // If the user needs to re-authenticate first
          _showReauthenticateDialog(context);
        }
      }

      emit(ProfileError());
    }
  }

  // Helper method to delete user data from Firestore
  Future<void> _deleteUserData(String userId) async {
    // Delete user document from users collection
    await FirebaseFirestore.instance.collection("users").doc(userId).delete();

    // Delete user's orders
    final orderSnapshot = await FirebaseFirestore.instance
        .collection("orders")
        .where("userId", isEqualTo: userId)
        .get();

    for (var doc in orderSnapshot.docs) {
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(doc.id)
          .delete();
    }

    // Delete any other user-related data from other collections
    // e.g., reviews, favorites, etc.
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection("reviews")
        .where("userId", isEqualTo: userId)
        .get();

    for (var doc in reviewsSnapshot.docs) {
      await FirebaseFirestore.instance
          .collection("reviews")
          .doc(doc.id)
          .delete();
    }
  }

  // Show dialog to reauthenticate the user if needed
  void _showReauthenticateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Authentication Required"),
        content: const Text(
          "For security reasons, you need to log in again before deleting your account.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Log user out and redirect to login screen
              logout(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Add a new address
  Future<void> addAddress(Address address) async {
    try {
      // Add to Firestore
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(ProfileError());
        return;
      }

      if (address.isDefault) {
        // Make sure only one address is default
        for (var addr in user.addresses) {
          addr.isDefault = false;
        }
      }

      user.addresses.add(address);

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .update({
        'addresses': user.addresses.map((addr) => addr.toJson()).toList(),
      });

      // Save to local storage
      await LocalStorageService.saveAddresses(user.addresses);

      emit(AddressAdded());
      emit(ProfileLoaded(user));
    } catch (error) {
      print("Error adding address: $error");
      emit(ProfileError());
    }
  }

  // Update an existing address
  Future<void> updateAddress(int index, Address updatedAddress) async {
    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(ProfileError());
        return;
      }

      if (updatedAddress.isDefault) {
        // Make sure only one address is default
        for (var addr in user.addresses) {
          addr.isDefault = false;
        }
      }

      user.addresses[index] = updatedAddress;

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .update({
        'addresses': user.addresses.map((addr) => addr.toJson()).toList(),
      });

      // Save to local storage
      await LocalStorageService.saveAddresses(user.addresses);

      emit(AddressUpdated());
      emit(ProfileLoaded(user));
    } catch (error) {
      print("Error updating address: $error");
      emit(ProfileError());
    }
  }

  // Delete an address
  Future<void> deleteAddress(int index) async {
    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(ProfileError());
        return;
      }

      user.addresses.removeAt(index);

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .update({
        'addresses': user.addresses.map((addr) => addr.toJson()).toList(),
      });

      // Save to local storage
      await LocalStorageService.saveAddresses(user.addresses);

      emit(AddressDeleted());
      emit(ProfileLoaded(user));
    } catch (error) {
      print("Error deleting address: $error");
      emit(ProfileError());
    }
  }

  // Set an address as default
  Future<void> setDefaultAddress(int index) async {
    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(ProfileError());
        return;
      }

      // Update default status
      for (int i = 0; i < user.addresses.length; i++) {
        user.addresses[i].isDefault = (i == index);
      }

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .update({
        'addresses': user.addresses.map((addr) => addr.toJson()).toList(),
      });

      // Save to local storage
      await LocalStorageService.saveAddresses(user.addresses);

      emit(AddressUpdated());
      emit(ProfileLoaded(user));
    } catch (error) {
      print("Error setting default address: $error");
      emit(ProfileError());
    }
  }

  // Update user's phone number
  Future<void> updateUserPhone(String phoneNumber) async {
    try {
      emit(ProfileLoading());

      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(ProfileError());
        return;
      }

      // Update the phone number in the user model
      user.phone = phoneNumber;

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .update({
        'phone': phoneNumber,
      });

      emit(ProfileLoaded(user));
    } catch (error) {
      print("Error updating phone number: $error");
      emit(ProfileError());
    }
  }

  // Update user's profile information
  Future<void> updateUserProfile({
    required String name,
    required String phone,
  }) async {
    try {
      emit(ProfileLoading());

      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(ProfileError());
        return;
      }

      // Update the user model
      user.name = name;
      user.phone = phone;

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .update({
        'name': name,
        'phone': phone,
      });

      emit(ProfileLoaded(user));
    } catch (error) {
      print("Error updating profile: $error");
      emit(ProfileError());
    }
  }

  // Add a used promocode to the user's profile
  Future<void> addUsedPromocode(String promocode) async {
    try {
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(ProfileError());
        return;
      }

      // Add to used promocodes list
      if (!user.usedPromocodes.contains(promocode)) {
        user.usedPromocodes.add(promocode);

        // Update in Firestore
        await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .update({
          'usedPromocodes': user.usedPromocodes,
        });

        print("Added promocode $promocode to user's used promocodes");
        emit(ProfileLoaded(user));
      }
    } catch (error) {
      print("Error adding used promocode: $error");
      emit(ProfileError());
    }
  }

  // Check if user has used a specific promocode
  bool hasUsedPromocode(String promocode) {
    return user.usedPromocodes.contains(promocode);
  }
}
