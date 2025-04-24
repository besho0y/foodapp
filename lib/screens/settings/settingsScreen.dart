import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/shared/colors.dart';

class Settingsscreen extends StatelessWidget {
  const Settingsscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
              child: Row(
                children: [
                  Icon(Icons.person, color: AppColors.primarylight),
                  SizedBox(width: 5.w),
                  Text(
                    "Profile",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColors.primarylight,
                  ),
                  SizedBox(width: 5.w),
                  Text("Cart", style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
              child: Row(
                children: [
                  Icon(Icons.logout, color: AppColors.primarylight),
                  SizedBox(width: 5.w),
                  Text("Logout", style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
