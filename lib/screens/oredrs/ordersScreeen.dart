import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/screens/oredrs/cubit.dart';
import 'package:foodapp/screens/oredrs/states.dart';
import 'package:foodapp/shared/auth_helper.dart';
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
    // Check if user is authenticated
    if (!AuthHelper.isUserLoggedIn()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 100.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 20.h),
            Text(
              'Please login to view your orders',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () =>
                  AuthHelper.requireAuthenticationForOrders(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

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
          return const Center(child: CircularProgressIndicator());
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
                  S.of(context).noorders,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  S.of(context).yourorderhistorywillappearhere,
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
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Text(
                      S.of(context).yourorders,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "    ${S.of(context).youhave} ${uniqueOrders.length} ${S.of(context).orders}",
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
