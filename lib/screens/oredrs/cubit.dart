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
        print('Error: User not authenticated when fetching orders');
        emit(OrderErrorState('User not authenticated'));
        return;
      }

      print('Fetching orders for user: ${currentUser.uid}');

      // Fetch orders from the global orders collection where userId matches current user
      // Using 'date' field for ordering to avoid composite index requirement
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('date', descending: true)
          .get();

      print('Found ${snapshot.docs.length} orders for user ${currentUser.uid}');

      // Parse the orders with better error handling
      orders = [];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          print(
              'Processing order: ${doc.id} with data keys: ${data.keys.join(', ')}');

          // Ensure the document has required fields
          if (data['id'] == null) {
            data['id'] = doc.id; // Use document ID if 'id' field is missing
          }

          // Ensure date field exists
          if (data['date'] == null) {
            data['date'] = DateTime.now().toIso8601String();
          }

          final order = app_models.Order.fromJson(data);
          orders.add(order);
        } catch (orderError) {
          print('Error parsing order ${doc.id}: $orderError');
          // Continue processing other orders instead of failing completely
        }
      }

      print('Successfully parsed ${orders.length} orders');
      emit(OrderSuccessState());
    } catch (error) {
      print('Error fetching orders: $error');
      emit(OrderErrorState(error.toString()));
    }
  }

  Future<void> addOrder(Map<String, dynamic> orderData) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('ERROR: User not authenticated when adding order via cubit');
        emit(OrderErrorState('User not authenticated'));
        return;
      }

      final orderId = orderData['id'];
      print('CUBIT: Adding order $orderId to local list');

      // Don't try to save to Firestore here since it's already saved in checkout
      // Just update the local list

      // Create an Order object from the data and add to the local list
      try {
        final newOrder = app_models.Order.fromJson(orderData);

        // Check if order is already in the local list to prevent duplicates
        final existingOrderIndex =
            orders.indexWhere((order) => order.id == orderId);
        if (existingOrderIndex >= 0) {
          // Replace existing order with updated one
          orders[existingOrderIndex] = newOrder;
          print('CUBIT: Updated existing order in local list');
        } else {
          // Add new order to the beginning of the list
          orders.insert(0, newOrder);
          print('CUBIT: Added new order to local list');
        }

        emit(OrderSuccessState());
        print('CUBIT: Order addition completed successfully');
      } catch (orderParsingError) {
        print(
            'ERROR: Could not parse order for local list: $orderParsingError');
        emit(OrderErrorState('Error parsing order data'));
      }
    } catch (error) {
      print('ERROR: Error in addOrder cubit method: $error');
      emit(OrderErrorState(error.toString()));
    }
  }

  // Method to update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    emit(OrderLoadingState());

    try {
      print('Updating order $orderId status to $newStatus');

      // Update the order in Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the order in local list
      final orderIndex = orders.indexWhere((order) => order.id == orderId);
      if (orderIndex >= 0) {
        orders[orderIndex].status = newStatus;
        print('Updated order status in local list');
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
      print('Fetching all orders for admin panel');

      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .orderBy('date', descending: true)
          .limit(100) // Limit to prevent memory issues
          .get();

      print('Found ${snapshot.docs.length} total orders');

      final allOrders = <app_models.Order>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          if (data['id'] == null) {
            data['id'] = doc.id; // Use document ID if 'id' field is missing
          }
          // Ensure date field exists
          if (data['date'] == null) {
            data['date'] = DateTime.now().toIso8601String();
          }
          allOrders.add(app_models.Order.fromJson(data));
        } catch (orderError) {
          print('Error parsing order ${doc.id} in admin panel: $orderError');
          // Continue processing other orders
        }
      }

      print('Successfully parsed ${allOrders.length} orders for admin panel');
      return allOrders;
    } catch (error) {
      print('Error fetching all orders: $error');
      rethrow;
    }
  }

  // Method to refresh orders (useful for pull-to-refresh)
  Future<void> refreshOrders() async {
    print('Refreshing orders...');
    await fetchOrders();
  }

  // Force refresh orders from Firestore
  Future<void> forceRefreshOrders() async {
    print('CUBIT: Force refreshing orders from Firestore');
    orders.clear(); // Clear local list
    await fetchOrders(); // Fetch fresh from Firestore
  }

  // Debug method to test Firestore connectivity
  Future<void> debugTestFirestore() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      print('DEBUG: Current user: ${currentUser?.uid ?? 'null'}');

      if (currentUser == null) {
        print('DEBUG: No authenticated user');
        return;
      }

      // Test basic Firestore connectivity
      final testDoc =
          await FirebaseFirestore.instance.collection('orders').limit(1).get();

      print('DEBUG: Firestore connection successful');
      print('DEBUG: Total orders in collection: ${testDoc.docs.length}');

      // Test user-specific query
      final userOrders = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      print('DEBUG: User orders found: ${userOrders.docs.length}');

      for (var doc in userOrders.docs) {
        final data = doc.data();
        print(
            'DEBUG: Order ${doc.id} - Status: ${data['status']} - Date: ${data['date']}');
      }
    } catch (e) {
      print('DEBUG: Firestore test failed: $e');
    }
  }
}
