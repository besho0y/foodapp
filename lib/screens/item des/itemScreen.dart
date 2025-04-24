import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/shared/colors.dart';
import 'package:foodapp/shared/constants.dart';

class Itemscreen extends StatelessWidget {
  const Itemscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 100.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 300.h,
                            width: double.infinity,
                            child: Image.asset(
                              "assets/images/burger.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 40.h,
                            left: 0,
                            child: IconButton(
                              onPressed: () {
                                backarrow(context);
                              },
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.primarylight,
                                size: 30.sp,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Card takes remaining space
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 300.h,
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Dish Name",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "Survived not only five centuries, but also the leap into electronic typesetting...",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(height: 20.h),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Special Request!",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.blueGrey,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Fixed bottom row
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10.r)],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Add to cart",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  Spacer(),
                  Card(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.remove,
                            color: AppColors.primarylight,
                            size: 30.sp,
                          ),
                        ),
                        Text(
                          "1",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.add,
                            color: AppColors.primarylight,
                            size: 30.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
