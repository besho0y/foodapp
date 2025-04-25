import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/layout/states.dart';

import 'package:foodapp/screens/favourits/favouritsScreen.dart';
import 'package:foodapp/screens/oredrs/ordersScreeen.dart';
import 'package:foodapp/screens/resturants/resturantScreen.dart';
import 'package:foodapp/screens/settings/settingsScreen.dart';

class Layoutcubit extends Cubit<Layoutstates> {
  Layoutcubit() : super(LayoutInitState());
  static Layoutcubit get(context) => BlocProvider.of(context);
  int currentindex = 0;
  List<IconData> bottomnav = [
    Icons.home,
    Icons.favorite_outline,
    //  Icons.shopping_cart_rounded,
    Icons.list_alt_rounded,
    Icons.account_circle,
  ];

  List<Widget> screens = [
    Resturantscreen(), Favouritsscreen(),
    // Cartscreen(),
    Ordersscreeen(), Settingsscreen(),
  ];

  List<String> titles = [
    "Restaurants",
    "favourits",
    "cart",
    "Orders",
    "Settings",
  ];

  

  void changenavbar(index) {
    currentindex = index;
    emit(LayoutChangeNavBar());
  }
}
