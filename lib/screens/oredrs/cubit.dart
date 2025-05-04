import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapp/models/order.dart' as app_models;
import 'package:foodapp/screens/oredrs/states.dart';

class OrderCubit extends Cubit<OrdersStates> {
  OrderCubit() : super(OrdersInitialState()) {
    fetchOrders();
  }

  static OrderCubit get(context) => BlocProvider.of(context);

  List<app_models.Order> orders = [];

  Future<void> fetchOrders() async {
    emit(OrderLoadingState());

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(OrderErrorState('User not authenticated'));
        return;
      }

      // Fetch orders from the global orders collection where userId matches current user
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('date', descending: true)
          .get();

      // Parse the orders
      orders = snapshot.docs.map((doc) {
        final data = doc.data();
        return app_models.Order.fromJson(data);
      }).toList();

      emit(OrderSuccessState());
    } catch (error) {
      print('Error fetching orders: $error');
      emit(OrderErrorState(error.toString()));
    }
  }

  Future<void> addOrder(Map<String, dynamic> orderData) async {
    emit(OrderLoadingState());

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(OrderErrorState('User not authenticated'));
        return;
      }

      // Check if order already exists to prevent duplicates
      final orderId = orderData['id'];
      final existingOrderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      if (existingOrderDoc.exists) {
        print(
            'Order with ID $orderId already exists, skipping duplicate creation');
        emit(OrderSuccessState());
        return;
      }

      // Add order to the global orders collection
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(orderData);

      // Also keep a reference in the user's orders list
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'orderIds': FieldValue.arrayUnion([orderId])
      });

      // Create an Order object from the data and add to the local list
      final newOrder = app_models.Order.fromJson(orderData);

      // Check if order is already in the local list to prevent duplicates
      final existingOrderIndex =
          orders.indexWhere((order) => order.id == orderId);
      if (existingOrderIndex >= 0) {
        // Replace existing order with updated one
        orders[existingOrderIndex] = newOrder;
      } else {
        // Add new order to the beginning of the list
        orders.insert(0, newOrder);
      }

      emit(OrderSuccessState());
    } catch (error) {
      print('Error adding order: $error');
      emit(OrderErrorState(error.toString()));
    }
  }

  // Method to update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    emit(OrderLoadingState());

    try {
      // Update the order in Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});

      // Update the order in local list
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex >= 0) {
        orders[orderIndex].status = newStatus;
      }

      emit(OrderSuccessState());
    } catch (error) {
      print('Error updating order status: $error');
      emit(OrderErrorState(error.toString()));
    }
  }

  // Method to fetch all orders (for admin panel)
  Future<List<app_models.Order>> fetchAllOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => app_models.Order.fromJson(doc.data()))
          .toList();
    } catch (error) {
      print('Error fetching all orders: $error');
      throw error;
    }
  }
}
