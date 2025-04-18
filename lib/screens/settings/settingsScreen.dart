import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/shared/constants.dart';

class Settingsscreen extends StatelessWidget {
  const Settingsscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 5.w),
                Text("Profile", style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          mydivider(context),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: Row(
              children: [
                Icon(Icons.shopping_cart_outlined),
                SizedBox(width: 5.w),
                Text("Cart", style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          mydivider(context),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: Row(
              children: [
                Icon(Icons.logout),
                SizedBox(width: 5.w),
                Text("Logout", style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
