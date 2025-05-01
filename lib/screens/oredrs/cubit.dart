import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/models/order.dart';
import 'package:foodapp/screens/oredrs/states.dart';

class OrderCubit extends Cubit<OrdersStates> {
  OrderCubit() : super(OrdersInitialState());
  static OrderCubit get(context) => BlocProvider.of(context);
  List<Order> orders = [
    Order(
      orderId: "12",
      customerName: "ahmed",
      orderDate:  DateTime.now().toString().split(' ')[0],
      totalAmount: 123.0,
      address: "2132131",
      restaurantName: "burger",
      items: [
        Item(
          id: "1",
          name: "burger",
          price: 50.0,
          description: 'das',
          img: 'asset/images/burger.png',
          category: "Burger"
        ),
        Item(
          id: "1",
          name: "burger",
          price: 50.0,
          description: 'das',
          img: 'asset/images/burger.png',
         category: "Burger"
        ),
      ],
    ),
  ];
}
