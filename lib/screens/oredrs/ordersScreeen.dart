import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/screens/oredrs/cubit.dart';
import 'package:foodapp/screens/oredrs/states.dart';
import 'package:foodapp/widgets/ordercard.dart';

class Ordersscreeen extends StatefulWidget {
  const Ordersscreeen({super.key});

  @override
  State<Ordersscreeen> createState() => _OrdersscreeenState();
}

class _OrdersscreeenState extends State<Ordersscreeen> {
  @override
  void initState() {
    super.initState();
    // Refresh orders when screen is opened
    OrderCubit.get(context).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = OrderCubit.get(context);
    return BlocConsumer<OrderCubit, OrdersStates>(
      listener: (context, state) {
        if (state is OrderErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is OrderLoadingState) {
          return Center(child: CircularProgressIndicator());
        }

        // Get unique orders by ID to prevent duplicates
        final uniqueOrders = _getUniqueOrders(cubit.orders);

        if (uniqueOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 70.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 20.h),
                Text(
                  "No orders yet",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Your order history will appear here",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => cubit.fetchOrders(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Text(
                      "Your Orders",
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "    You have ${uniqueOrders.length} orders",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...uniqueOrders
                      .map((order) => OrderCard(model: order))
                      .toList(),
                  SizedBox(height: 20.h), // Add padding at the bottom
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to get unique orders by ID
  List<dynamic> _getUniqueOrders(List<dynamic> orders) {
    final uniqueOrdersMap = <String, dynamic>{};

    for (var order in orders) {
      uniqueOrdersMap[order.id] = order;
    }

    return uniqueOrdersMap.values.toList();
  }
}
