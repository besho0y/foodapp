import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/models/user.dart' as AppUser;
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/screens/signup/states.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/shared/local_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Signupcubit extends Cubit<SignupStates> {
  Signupcubit() : super(SignupInitialState());

  static Signupcubit get(context) => BlocProvider.of(context);

  void userRegister({
    required String email,
    required String password,
    required String phone,
    required String name,
    required context,
  }) async {
    emit(RegisterLoadingState());

    try {
      UserCredential value = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = value.user;
      if (user != null) {
        // Optionally send verification email
        await user.sendEmailVerification();

        // Create user data in Firestore
        await _createUser(
          uid: user.uid,
          name: name,
          phone: phone,
          email: user.email!,
          context: context,
        );

        emit(RegisterSuccessState());
      } else {
        emit(RegisterErrorState());
      }
    } catch (e) {
      print("Auth Error: $e");
      emit(RegisterErrorState());
    }
  }

  Future<void> _createUser({
    required String uid,
    required String name,
    required String phone,
    required String email,
    required context,
  }) async {
    emit(CreateUserLoadingState());

    AppUser.User userModel = AppUser.User(
      name: name,
      phone: phone,
      email: email,
      uid: uid,
      orderIds: [],
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userModel.tomap());

      emit(CreateUserSuccessState());

      // Load user data after creating the user but before navigation
      ProfileCubit profileCubit = ProfileCubit.get(context);
      profileCubit.getuserdata();

      // Initialize favorites after user creation
      try {
        Favouritecubit favCubit = Favouritecubit.get(context);
        await favCubit.initializeFavoriteIds();
        await favCubit.loadFavourites();
      } catch (e) {
        print("Error initializing favorites after signup: $e");
      }

      navigateAndFinish(context, const Layout());

      // After navigation, ensure we're on the first tab
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          final layoutCubit = Layoutcubit.get(context);
          layoutCubit.changenavbar(0); // Change to the first tab
        } catch (e) {
          print("Error setting initial tab: $e");
        }
      });
    } catch (e) {
      print("Firestore Error: $e");
      emit(CreateUserErrorState());
    }
  }

  // Check if Google Sign-In is configured properly
  Future<bool> isGoogleSignInConfigured({BuildContext? context}) async {
    try {
      // Check if Firebase project has Google Sign-In method enabled
      var methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        "test@example.com",
      );
      print("Available sign-in methods: $methods");

      // Try to initialize GoogleSignIn to check if it's configured
      final GoogleSignIn googleSignIn = GoogleSignIn();
      return true; // If we can create an instance, it's likely configured
    } catch (e) {
      print("Google Sign-In configuration error: $e");
      if (context != null) {
        showToast(
          "Google Sign-In is not properly configured: ${e.toString().substring(0, math.min(100, e.toString().length))}",
          context: context,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.amber,
          textStyle: const TextStyle(color: Colors.black, fontSize: 16.0),
          position: StyledToastPosition.bottom,
        );
      }
      return false;
    }
  }

  void signinwithgoogle({BuildContext? context}) async {
    emit(RegisterLoadingState());

    // First, check if Google Sign-In is configured
    if (context != null) {
      bool isConfigured = await isGoogleSignInConfigured(context: context);
      if (!isConfigured) {
        emit(CreateUserErrorState());
        return;
      }
    }

    try {
      // Initialize and authenticate with Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        // User canceled the sign-in
        emit(CreateUserErrorState());
        return;
      }

      try {
        // Get authentication tokens
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        // Create Firebase credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in to Firebase
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        final User? user = userCredential.user;

        if (user != null) {
          // Check if user exists in Firestore
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            // Create user in Firestore if they don't exist
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
              'name': user.displayName ?? '',
              'email': user.email ?? '',
              'phone': user.phoneNumber ?? '',
              'uid': user.uid,
              'orderIds': [],
            });
          }

          // Save user login state
          await LocalStorageService.saveUserLogin(user.uid, user.email ?? '');

          emit(CreateUserSuccessState());

          if (context != null) {
            // Load user data before navigation
            ProfileCubit profileCubit = ProfileCubit.get(context);
            profileCubit.getuserdata();

            // Initialize favorites after sign-in
            try {
              Favouritecubit favCubit = Favouritecubit.get(context);
              await favCubit.initializeFavoriteIds();
              await favCubit.loadFavourites();
            } catch (e) {
              print("Error initializing favorites after Google signup: $e");
            }

            navigateAndFinish(context, const Layout());

            // After navigation, ensure we're on the first tab
            Future.delayed(const Duration(milliseconds: 100), () {
              try {
                final layoutCubit = Layoutcubit.get(context);
                layoutCubit.changenavbar(0); // Change to the first tab
              } catch (e) {
                print("Error setting initial tab: $e");
              }
            });
          }
        } else {
          throw Exception("Firebase user is null after sign-in");
        }
      } catch (authError) {
        print("Firebase Authentication Error: $authError");
        emit(CreateUserErrorState());
        if (context != null) {
          showToast(
            "Firebase Auth Error: ${authError.toString().substring(0, math.min(100, authError.toString().length))}",
            context: context,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
            position: StyledToastPosition.bottom,
          );
        }
      }
    } catch (error) {
      print("Google Sign-In Error: $error");
      emit(CreateUserErrorState());
      if (context != null) {
        showToast(
          "Google Sign-In Error: ${error.toString().substring(0, math.min(100, error.toString().length))}",
          context: context,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
          position: StyledToastPosition.bottom,
        );
      }
    }
  }
}
