import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/screens/item%20des/itemScreen.dart';
import 'package:foodapp/shared/colors.dart';
import 'package:foodapp/shared/constants.dart';

class Menuscreen extends StatelessWidget {
  const Menuscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(double.infinity.w, 120.h),
          child: Stack(
            children: [
              Opacity(
                opacity: 0.9,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15.r),
                  ),
                  child: Image.asset(
                    "assets/images/banner2.png",
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Positioned(
                top: 10.h,
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
              Positioned(
                bottom: -8.h,
                right: -1.w,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[500]!, width: 2),
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: 8.h,
                      left: 8.w,
                      right: 8.w,
                    ),
                    child: Text(
                      "Name of kitchen",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.h),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 5.h),
                itemcard(context, 1),
                itemcard(context, 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget itemcard(context, index) => Padding(
    padding: EdgeInsets.only(bottom: 5.h),
    child: GestureDetector(
      onTap: () {
        navigateTo(context, Itemscreen());
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 130.h,
            color: Colors.transparent,
          ),

          Positioned(
            top: 5.h,
            right: -5.w, // Adjust position as needed
            child: SizedBox(
              width: 320.w,
              height: 120.h,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 45.w),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "dish name",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),

                          SizedBox(
                            height: 40.h,
                            width: 230.w,
                            child: Text(
                              "Lorem Ipsum is simply dummy text of the printdummy text of the prinorem Ipsum is simply dummy text of the printdummy text of the printt",
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Expanded(
                            child: Text(
                              "1000 egp",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 30.h,
            left: -15, // Adjust position as needed
            child: Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/burger.png"),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
