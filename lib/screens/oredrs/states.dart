abstract class OrdersStates {}

class OrdersInitialState extends OrdersStates {}

class OrderLoadingState extends OrdersStates {}

class OrderSuccessState extends OrdersStates {}

class OrderErrorState extends OrdersStates {
  final String error;
  OrderErrorState(this.error);
}
