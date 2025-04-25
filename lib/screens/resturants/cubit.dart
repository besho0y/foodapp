import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:foodapp/screens/resturants/states.dart';

class Restuarantscubit extends Cubit<ResturantsStates> {
  Restuarantscubit() : super(ResturantsInitialState());
  static Restuarantscubit get(context) => BlocProvider.of(context);
  List<String> banners = [
    "assets/images/banners/banner1.png",
    "assets/images/banners/banner2.png",
    "assets/images/banners/banner3.png",
  ];
}
