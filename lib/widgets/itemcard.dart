 import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/screens/item%20des/itemScreen.dart';
import 'package:foodapp/shared/constants.dart';

Widget itemcard(context,bool favourite) => Padding(
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
              height: 110.h,
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
                            height: 30.h,
                            width: 230.w,
                            child: Text(
                              "Lorem Ipsum is simply dummy text of the printdummy text of the prinorem Ipsum is simply dummy text of the printdummy text of the printt",
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(
                            width: 220.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "1000 egp",
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: favourite==false?Icon(Icons.favorite_border):Icon(Icons.favorite,color: Colors.red,),
                                  padding: EdgeInsets.all(-10),
                                ),
                              ],
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