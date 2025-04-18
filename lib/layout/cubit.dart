import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/layout/states.dart';
import 'package:foodapp/screens/oredrs/ordersScreeen.dart';
import 'package:foodapp/screens/resturants/resturantScreen.dart';
import 'package:foodapp/screens/settings/settingsScreen.dart';

class Layoutcubit extends Cubit<Layoutstates> {
  Layoutcubit() : super(LayoutInitState());
  static Layoutcubit get(context) => BlocProvider.of(context);
  int currentindex = 0;
  List<BottomNavigationBarItem> bottomnav = [
    BottomNavigationBarItem(
      icon: Icon(Icons.store_mall_directory_rounded),
      label: "Restaurans",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.list_alt_outlined),
      label: "Orders",
    ),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
  ];

  List<Widget> screens = [Resturantscreen(), Ordersscreeen(), Settingsscreen()];

  List<String> titles = [
"Restaurants",
"Orders",
"Settings"
  ];

  void changenavbar(index) {
    currentindex = index;
    emit(LayoutChangeNavBar());
  }
}
