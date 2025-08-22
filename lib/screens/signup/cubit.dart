// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
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
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
      UserCredential value = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

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
      await FirebaseFirestore.instance.collection('users').doc(uid).set(userModel.tomap());

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

  void signinwithgoogle({BuildContext? context}) async {
    emit(RegisterLoadingState());

    try {
      // Initialize and authenticate with Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      final GoogleSignInAccount googleSignInAccount = await googleSignIn.authenticate();

      try {
        // Get authentication tokens
        final GoogleSignInAuthentication googleSignInAuthentication = googleSignInAccount.authentication;
        await googleSignIn.initialize(clientId: '167788515229-fo7rsgf1tqo7oo9q5i3buj3354l1jf97.apps.googleusercontent.com'); // Ensure previous sessions are cleared

        // Create Firebase credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in to Firebase
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        final User? user = userCredential.user;

        if (user != null) {
          // Check if user exists in Firestore
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

          if (!userDoc.exists) {
            // Create user in Firestore if they don't exist
            await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
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

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final random = math.Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signinwithapple({BuildContext? context}) async {
    emit(RegisterLoadingState());
    print("Starting Apple Sign-In for registration");

    // Check if Apple Sign-In is available on this device
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        emit(CreateUserErrorState());
        if (context != null) {
          showToast(
            "Apple Sign-In is not available on this device",
            context: context,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.amber,
            textStyle: const TextStyle(color: Colors.black, fontSize: 16.0),
            position: StyledToastPosition.bottom,
          );
        }
        return;
      }
    } catch (e) {
      print("Error checking Apple Sign-In availability: $e");
      emit(CreateUserErrorState());
      if (context != null) {
        showToast(
          "Apple Sign-In is not supported",
          context: context,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.amber,
          textStyle: const TextStyle(color: Colors.black, fontSize: 16.0),
          position: StyledToastPosition.bottom,
        );
      }
      return;
    }

    try {
      // Generate nonce for security
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      print("Generated nonce successfully");

      // Request credential for Apple Sign-In
      print("Requesting Apple Sign-In credential");
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      print("Successfully received Apple credential");

      // Create an `OAuthCredential` from the credential returned by Apple
      print("Creating OAuth credential");
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );
      print("OAuth credential created successfully");

      // Sign in the user with Firebase
      print("Signing in with Firebase");
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      print("Firebase sign-in successful");

      final User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Create user in Firestore if they don't exist
          // For Apple Sign-In, use the name from appleCredential if displayName is null
          String displayName = user.displayName ?? '';
          if (displayName.isEmpty && appleCredential.givenName != null && appleCredential.familyName != null) {
            displayName = '${appleCredential.givenName} ${appleCredential.familyName}';
          }

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': displayName,
            'email': user.email ?? appleCredential.email ?? '',
            'phone': user.phoneNumber ?? '',
            'uid': user.uid,
            'orderIds': [],
          });
        }

        // Save user login state
        await LocalStorageService.saveUserLogin(user.uid, user.email ?? appleCredential.email ?? '');

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
            print("Error initializing favorites after Apple signup: $e");
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
          print("Apple Sign-In successful for registration, user: ${user.uid}");
        }
      } else {
        print("Apple Sign-In user is null after sign-in");
        emit(CreateUserErrorState());
        if (context != null) {
          showToast(
            'Unknown error occurred during Apple Sign-In',
            context: context,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
            position: StyledToastPosition.bottom,
          );
        }
      }
    } catch (error) {
      print("Apple Sign-In Error: $error");
      emit(CreateUserErrorState());
      if (context != null) {
        String errorMessage = "Apple Sign-In failed";

        if (error is FirebaseAuthException) {
          switch (error.code) {
            case 'invalid-credential':
              errorMessage = "Invalid Apple credentials";
              break;
            case 'operation-not-allowed':
              errorMessage = "Apple Sign-In is not enabled";
              break;
            case 'user-disabled':
              errorMessage = "This account has been disabled";
              break;
            default:
              errorMessage = error.message ?? "Apple Sign-In failed";
          }
        } else if (error is SignInWithAppleAuthorizationException) {
          errorMessage = "Apple Sign-In authorization failed";
        } else {
          // Handle other types of errors
          if (error.toString().contains("1000") || error.toString().contains("AuthorizationError")) {
            errorMessage = "Apple Sign-In is not properly configured for this app";
          } else if (error.toString().contains("not handled") || error.toString().contains("notHandled")) {
            errorMessage = "Apple Sign-In is not supported on this device or app configuration";
          } else {
            errorMessage = "Apple Sign-In failed: ${error.toString().substring(0, math.min(100, error.toString().length))}";
          }
        }

        showToast(
          errorMessage,
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
