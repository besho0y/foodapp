import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/layout/states.dart';
import 'package:foodapp/models/cartitem.dart';
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
    Icons.list_alt_rounded,
    Icons.account_circle_outlined,
  ];

  List<Widget> screens = [
    Resturantscreen(), Favouritsscreen(),
    // Cartscreen(),
    Ordersscreeen(), Settingsscreen(),
  ];

  List<String> titles = ["Restaurants", "favourits", "Orders", "Settings"];
  List<Cartitem> cartitems = [
    Cartitem(
      name: "burger",
      price: 120,
      id: "12",
      img: "assets/images/items/burger.png",
      quantity: 1,
    ),
  ];

  void addToCart({
    required String name,
    required double price,
    required int quantity,
    required String img,
  }) {
    cartitems.add(
      Cartitem(
        name: name,
        price: price,
        quantity: quantity,
        img: img,
        id: DateTime.now().toString(), // Generate a unique ID
      ),
    );

    emit(LayoutCartUpdatedState()); // <-- emit a new state
  }

  void changenavbar(index) {
    currentindex = index;
    emit(LayoutChangeNavBar());
  }

  void increaseQuantity(int index) {
    cartitems[index].quantity++;
    emit(UpdateCartState());
  }

  void decreaseQuantity(int index) {
    if (cartitems[index].quantity > 1) {
      cartitems[index].quantity--;
      emit(UpdateCartState());
    }
  }

  void removeItemFromCart(int index) {
    cartitems.removeAt(index);
    emit(UpdateCartState());
  }

  double calculateTotalPrice() {
    double total = 0;
    for (var item in cartitems) {
      total += item.price * item.quantity;
    }
    return total;
  }
}
