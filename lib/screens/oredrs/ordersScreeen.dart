import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/screens/oredrs/cubit.dart';
import 'package:foodapp/screens/oredrs/states.dart';

import 'package:foodapp/widgets/ordercard.dart';

class Ordersscreeen extends StatelessWidget {
  const Ordersscreeen({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = OrderCubit.get(context);
    return BlocConsumer<OrderCubit, OrdersStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              children: [
                SizedBox(height: 5.h),
                // OrderCard(context,cubit.orders[0]),
                OrderCard(model: cubit.orders[0]),
                OrderCard(model: cubit.orders[0])
              ],
            ),
          ),
        );
      },
    );
  }
}
