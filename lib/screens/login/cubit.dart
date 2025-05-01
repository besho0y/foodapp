import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/screens/login/states.dart';
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

      Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }
}
