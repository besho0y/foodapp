import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/screens/menu/states.dart';

class Menucubit extends Cubit<MenuStates> {
  Menucubit() : super(MenuInitState());
  static Menucubit get(context) => BlocProvider.of(context);
  List<Item> menuitems = [
    Item(id: "1", name: "burger", description: "best burger", price: 210,img: "assets/images/items/burger.png"),
    Item(id: "2", name: "pizza", description: "best pizza", price: 210,img: "assets/images/items/pizza.png"),
    Item(id: "3", name: "sushi", description: "best sushi", price: 210,img: "assets/images/items/sushi.png"),
    Item(id: "4", name: "pasta", description: "best pasta", price: 210,img: "assets/images/items/pasta.png"),
    Item(id: "5", name: "rice", description: "best rice", price: 210,img: "assets/images/items/rice.png"),
  ];
}
