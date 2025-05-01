import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/screens/menu/menuScreen.dart';
import 'package:foodapp/shared/constants.dart';

Widget resturantbox(context, model) => GestureDetector(
  onTap: () {
    navigateTo(context, Menuscreen(items: model.menuItems, name: model.name,img: model.img,));
    
  },
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!
                : Colors.grey[400]!,
        width: 2.w,
      ),
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(15.r),
    ),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
          child: Image.asset(
            "${model.img}",
            fit: BoxFit.cover,
            height: 85.h,
            width: double.infinity,
          ),
        ),
        SizedBox(height: 5.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.delivery_dining_outlined),
                  SizedBox(width: 5.w),
                  Text("1 day", style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              Text(
                "${model.name}",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Row(
                children: [
                  Icon(Icons.star_rate_rounded, color: Colors.amber),
                  SizedBox(width: 5.w),
                  Text(
                    "${model.rating}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
