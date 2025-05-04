import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/models/user.dart' as AppUser;
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/screens/signup/states.dart';
import 'package:foodapp/shared/constants.dart';

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

      navigateAndFinish(context, Layout());
    } catch (e) {
      print("Firestore Error: $e");
      emit(CreateUserErrorState());
    }
  }
}
