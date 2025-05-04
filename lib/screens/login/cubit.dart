import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/screens/login/states.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/shared/constants.dart';

class Logincubit extends Cubit<LoginStates> {
  Logincubit() : super(LoginInitialState());
  static Logincubit get(context) => BlocProvider.of(context);

  void login(
      {required String email,
      required String password,
      required BuildContext context}) {
    emit(LoginLoadingState());
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      emit(LoginSuccessState());

      // Load user data before navigation
      ProfileCubit profileCubit = ProfileCubit.get(context);
      profileCubit.getuserdata();

      navigateAndFinish(context, Layout());
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
}
