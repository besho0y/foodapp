import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
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

class Logincubit extends Cubit<LoginStates> {
  Logincubit() : super(LoginInitialState());
  static Logincubit get(context) => BlocProvider.of(context);

  final formkey = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  void login(
      {required String email,
      required String password,
      required BuildContext context}) {
    emit(LoginLoadingState());
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
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
          default:
            errorMessage = error.message ?? "An error occurred";
        }
      }

      showToast(
        errorMessage,
        context: context,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
        textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
        position: StyledToastPosition.bottom,
      );
    });
  }

  // Check if Google Sign-In is configured properly
  Future<bool> isGoogleSignInConfigured({BuildContext? context}) async {
    try {
      // Check if Firebase project has Google Sign-In method enabled
      var methods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail("test@example.com");
      print("Available sign-in methods: $methods");

      // Check if GoogleSignIn can be initialized
      final GoogleSignIn googleSignIn = GoogleSignIn();
      bool isAvailable = await googleSignIn.isSignedIn().catchError((error) {
        print("GoogleSignIn initialization error: $error");
        return false;
      });

      return true;
    } catch (e) {
      print("Google Sign-In configuration error: $e");
      if (context != null) {
        showToast(
          "Google Sign-In is not properly configured",
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

  signinwithgoogle({BuildContext? context}) async {
    emit(LoginLoadingState());

    // First, check if Google Sign-In is configured
    if (context != null) {
      bool isConfigured = await isGoogleSignInConfigured(context: context);
      if (!isConfigured) {
        emit(LoginErrorlState());
        return;
      }
    }

    try {
      // Initialize GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // User selects account (this may fail if Google Play Services aren't configured)
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        // User canceled the sign-in process
        emit(LoginErrorlState());
        if (context != null) {
          showToast(
            "Google Sign-in was canceled",
            context: context,
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
            textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
            position: StyledToastPosition.bottom,
          );
        }
        return;
      }

      try {
        // Get authentication tokens
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        // Create Firebase credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
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
                final layoutCubit =
                    Layoutcubit.get(navigatorKey.currentContext!);
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

  Future<void> signinwithapple({BuildContext? context}) async {
    emit(LoginLoadingState());
    try {
      // Get Apple Sign In credentials
      final appleProvider = AppleAuthProvider();
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(appleProvider);

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
              final layoutCubit = Layoutcubit.get(navigatorKey.currentContext!);
              layoutCubit.changenavbar(0); // Change to the first tab
            }
          });
        }
      } else {
        throw Exception("Firebase user is null after sign-in");
      }
    } catch (error) {
      print("Apple Sign-In Error: $error");
      emit(LoginErrorlState());
      if (context != null) {
        showToast(
          "Apple Sign-In Error",
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
