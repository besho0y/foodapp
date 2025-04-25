import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/models/resturant.dart';

import 'package:foodapp/screens/resturants/states.dart';

class Restuarantscubit extends Cubit<ResturantsStates> {
  Restuarantscubit() : super(ResturantsInitialState());
  static Restuarantscubit get(context) => BlocProvider.of(context);
  List<String> banners = [
    "assets/images/banners/banner1.png",
    "assets/images/banners/banner2.png",
    "assets/images/banners/banner3.png",
  ];
  List<Restuarants> restuarants = [
    Restuarants(name: "kitchen 1",img: "assets/images/restuarants/store.jpg",rating: 3.5,
     menuItems: [   Item(id: "1", name: "burger", description: "best burger", price: 210,img: "assets/images/items/burger.png"),
    Item(id: "2", name: "pizza", description: "best pizza", price: 210,img: "assets/images/items/pizza.png"),
    Item(id: "3", name: "sushi", description: "best sushi", price: 210,img: "assets/images/items/sushi.png"),
    Item(id: "4", name: "pasta", description: "best pasta", price: 210,img: "assets/images/items/pasta.png"),
    Item(id: "5", name: "rice", description: "best rice", price: 210,img: "assets/images/items/rice.png"),]),
    Restuarants(name: "kitchen 2",img: "assets/images/restuarants/store.jpg",rating: 4.5,
     menuItems: [   Item(id: "1", name: "burger", description: "best burger", price: 210,img: "assets/images/items/burger.png"),
    Item(id: "2", name: "pizza", description: "best pizza", price: 210,img: "assets/images/items/pizza.png"),
    Item(id: "3", name: "sushi", description: "best sushi", price: 210,img: "assets/images/items/sushi.png"),
    Item(id: "4", name: "pasta", description: "best pasta", price: 210,img: "assets/images/items/pasta.png"),
    Item(id: "5", name: "rice", description: "best rice", price: 210,img: "assets/images/items/rice.png"),]),
    Restuarants(name: "kitchen 3",img: "assets/images/restuarants/store.jpg",rating: 3.5, 
    menuItems: [   Item(id: "1", name: "burger", description: "best burger", price: 210,img: "assets/images/items/burger.png"),
    Item(id: "2", name: "pizza", description: "best pizza", price: 210,img: "assets/images/items/pizza.png"),
    Item(id: "3", name: "sushi", description: "best sushi", price: 210,img: "assets/images/items/sushi.png"),
    Item(id: "4", name: "pasta", description: "best pasta", price: 210,img: "assets/images/items/pasta.png"),
    Item(id: "5", name: "rice", description: "best rice", price: 210,img: "assets/images/items/rice.png"),]),
    Restuarants(name: "kitchen 4",img: "assets/images/restuarants/store.jpg",rating: 4.0, 
    menuItems: [   Item(id: "1", name: "burger", description: "best burger", price: 210,img: "assets/images/items/burger.png"),
    Item(id: "2", name: "pizza", description: "best pizza", price: 210,img: "assets/images/items/pizza.png"),
    Item(id: "3", name: "sushi", description: "best sushi", price: 210,img: "assets/images/items/sushi.png"),
    Item(id: "4", name: "pasta", description: "best pasta", price: 210,img: "assets/images/items/pasta.png"),
    Item(id: "5", name: "rice", description: "best rice", price: 210,img: "assets/images/items/rice.png"),]),
    Restuarants(name: "kitchen 5",img: "assets/images/restuarants/store.jpg",rating: 3.4, 
    menuItems: [   Item(id: "1", name: "burger", description: "best burger", price: 210,img: "assets/images/items/burger.png"),
    Item(id: "2", name: "pizza", description: "best pizza", price: 210,img: "assets/images/items/pizza.png"),
    Item(id: "3", name: "sushi", description: "best sushi", price: 210,img: "assets/images/items/sushi.png"),
    Item(id: "4", name: "pasta", description: "best pasta", price: 210,img: "assets/images/items/pasta.png"),
    Item(id: "5", name: "rice", description: "best rice", price: 210,img: "assets/images/items/rice.png"),]),
  ];

}
