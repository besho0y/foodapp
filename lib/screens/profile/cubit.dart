import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/user.dart';
import 'package:foodapp/screens/profile/states.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());
  static ProfileCubit get(context) => BlocProvider.of(context);
  late User user = User(
      name: "Loading...",
      phone: "0000000000",
      email: "loading@example.com",
      uid: "temp_uid");

  void getuserdata() async {
    emit(ProfileLoading());
    FirebaseFirestore.instance
        .collection("users")
        .doc(auth.FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      user = User.fromJson(value.data()!);
      emit(ProfileLoaded(user));
    }).catchError((error) {
      print("error: ${error}");
      emit(ProfileError());
    });
  }
}
