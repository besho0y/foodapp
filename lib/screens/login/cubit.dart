// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:foodapp/layout/cubit.dart' hide navigatorKey;
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/main.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/login/states.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/shared/local_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Logincubit extends Cubit<LoginStates> {
  Logincubit() : super(LoginInitialState());
  static Logincubit get(context) => BlocProvider.of(context);

  final formkey = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  void login({
    required String email,
    required String password,
    required BuildContext context,
  }) {
    emit(LoginLoadingState());
    FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((value) async {
      emit(LoginSuccessState());

      // Save user login state
      await LocalStorageService.saveUserLogin(value.user!.uid, email);

      // Load user data before navigation
      ProfileCubit profileCubit = ProfileCubit.get(context);
      profileCubit.getuserdata();

      // Initialize favorites after login
      try {
        Favouritecubit favCubit = Favouritecubit.get(context);
        await favCubit.initializeFavoriteIds();
        await favCubit.loadFavourites();
      } catch (e) {
        print("Error initializing favorites after login: $e");
      }

      // Navigate to the Layout
      navigateAndFinish(context, const Layout());

      // After navigation, ensure we're on the first tab
      Future.delayed(const Duration(milliseconds: 100), () {
        if (navigatorKey.currentContext != null) {
          final layoutCubit = Layoutcubit.get(navigatorKey.currentContext!);
          layoutCubit.changenavbar(0); // Change to the first tab
        }
      });
    }).catchError((error) {
      emit(LoginErrorlState());
      String errorMessage = "An error occurred";

      if (error is FirebaseAuthException) {
        switch (error.code) {
          case 'user-not-found':
            errorMessage = "No user found with this email";
            break;
          case 'wrong-password':
            errorMessage = "Wrong password provided";
            break;
          case 'invalid-email':
            errorMessage = "Invalid email address";
            break;
          case 'user-disabled':
            errorMessage = "This account has been disabled";
            break;
          case 'too-many-requests':
            errorMessage = "Too many failed attempts. Please try again later";
            break;
          case 'operation-not-allowed':
            errorMessage = "Email/password accounts are not enabled";
            break;
          default:
            errorMessage = error.message ?? "Authentication failed";
        }
      } else {
        // Handle other types of errors including type casting errors
        print("Auth Error Details: $error");
        if (error.toString().contains('PigeonUserDetails') || error.toString().contains('List<Object?>')) {
          errorMessage = "Authentication service temporarily unavailable. Please try again.";
        } else {
          errorMessage = "An unexpected error occurred";
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
    });
  }

  Future<void> signinwithgoogle({BuildContext? context}) async {
    emit(LoginLoadingState());

    try {
      print("Starting Google Sign-In");
      // Initialize and authenticate with Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(clientId: '167788515229-fo7rsgf1tqo7oo9q5i3buj3354l1jf97.apps.googleusercontent.com'); // Ensure previous sessions are cleared
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.authenticate();
      print("Google Sign-In successful: ${googleSignInAccount.email} (${googleSignInAccount.displayName})");

      try {
        // Get authentication tokens
        final GoogleSignInAuthentication googleSignInAuthentication = googleSignInAccount.authentication;
        print("Google Sign-In Authentication successful: ${googleSignInAuthentication.idToken}");

        // Create Firebase credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in to Firebase
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        print("Firebase Sign-In successful: ${userCredential.user?.email} (${userCredential.user?.displayName})");

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

          emit(LoginSuccessState());

          if (context != null) {
            // Load user data before navigation
            ProfileCubit profileCubit = ProfileCubit.get(context);
            profileCubit.getuserdata();

            // Initialize favorites after login
            try {
              Favouritecubit favCubit = Favouritecubit.get(context);
              await favCubit.initializeFavoriteIds();
              await favCubit.loadFavourites();
            } catch (e) {
              print("Error initializing favorites after Google sign-in: $e");
            }

            // Navigate to the Layout
            navigateAndFinish(context, const Layout());

            // After navigation, ensure we're on the first tab
            Future.delayed(const Duration(milliseconds: 100), () {
              if (navigatorKey.currentContext != null) {
                final layoutCubit = Layoutcubit.get(
                  navigatorKey.currentContext!,
                );
                layoutCubit.changenavbar(0); // Change to the first tab
              }
            });
          }
        } else {
          throw Exception("Firebase user is null after sign-in");
        }
      } catch (authError) {
        print("Firebase Authentication Error: $authError");
        emit(LoginErrorlState());
        if (context != null) {
          String errorMessage = "Google Sign-In failed";

          // Handle specific Firebase Auth errors
          if (authError.toString().contains('PigeonUserDetails') || authError.toString().contains('List<Object?>')) {
            errorMessage = "Authentication service temporarily unavailable. Please try again.";
          } else if (authError is FirebaseAuthException) {
            switch (authError.code) {
              case 'account-exists-with-different-credential':
                errorMessage = "Account exists with different sign-in method";
                break;
              case 'invalid-credential':
                errorMessage = "Invalid Google credentials";
                break;
              case 'operation-not-allowed':
                errorMessage = "Google Sign-In is not enabled";
                break;
              case 'user-disabled':
                errorMessage = "This account has been disabled";
                break;
              default:
                errorMessage = authError.message ?? "Google Sign-In failed";
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
    } catch (error) {
      print("Google Sign-In Error: $error");
      emit(LoginErrorlState());
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
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
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
    emit(LoginLoadingState());
    print("Starting Apple Sign-In");

    // Check if Apple Sign-In is available on this device
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        emit(LoginErrorlState());
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
      emit(LoginErrorlState());
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
      // To prevent replay attacks with the credential returned from Apple, we
      // include a nonce in the credential request. When signing in with
      // Firebase, the nonce in the id token returned by Apple, is expected to
      // match the sha256 hash of `rawNonce`.
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      print("Generated nonce successfully");

      // Request credential for the currently signed in Apple account.
      print("Requesting Apple Sign-In credential");
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      print("Successfully received Apple credential");
      print("Apple Sign-In Credential: ${appleCredential.familyName} ${appleCredential.givenName} ${appleCredential.email}");

      // Create an `OAuthCredential` from the credential returned by Apple.
      print("Creating OAuth credential");
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );
      print("OAuth credential created successfully");

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
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

        emit(LoginSuccessState());

        if (context != null) {
          // Load user data before navigation
          ProfileCubit profileCubit = ProfileCubit.get(context);
          profileCubit.getuserdata();

          // Initialize favorites after login
          try {
            Favouritecubit favCubit = Favouritecubit.get(context);
            await favCubit.initializeFavoriteIds();
            await favCubit.loadFavourites();
          } catch (e) {
            print("Error initializing favorites after Apple sign-in: $e");
          }

          // Navigate to the Layout
          navigateAndFinish(context, const Layout());

          // After navigation, ensure we're on the first tab
          Future.delayed(const Duration(milliseconds: 100), () {
            if (navigatorKey.currentContext != null) {
              final layoutCubit = Layoutcubit.get(navigatorKey.currentContext!);
              layoutCubit.changenavbar(0); // Change to the first tab
            }
          });
          print("Apple Sign-In successful, user: ${user.uid}");
        }
        print("Apple Sign-In successful, user: ${user.uid}");
      } else {
        print("Apple Sign-In is null after sign-in");
        showToast(
          'Unknown error occurred during Apple Sign-In',
          context: context,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
          position: StyledToastPosition.bottom,
        );
        throw Exception("Firebase user is null after sign-in");
      }
    } catch (error) {
      print("Apple Sign-In Error: $error");
      emit(LoginErrorlState());
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
          errorMessage = "Apple Sign-In failed";
        } else {
          // Handle other types of errors
          if (error.toString().contains("1000") || error.toString().contains("AuthorizationError")) {
            errorMessage = "Apple Sign-In is not properly configured for this app";
          } else if (error.toString().contains("not handled") || error.toString().contains("notHandled")) {
            errorMessage = "Apple Sign-In is not supported on this device or app configuration";
          } else {
            errorMessage = "Apple Sign-In failed: ${error.toString()}";
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

  @override
  Future<void> close() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    return super.close();
  }
}
