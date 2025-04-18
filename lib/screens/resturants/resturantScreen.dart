import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/screens/menu/menuScreen.dart';
import 'package:foodapp/shared/constants.dart';

class Resturantscreen extends StatelessWidget {
  const Resturantscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 5.h),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 5.w,
        children: [
          resturantbox(context),
          resturantbox(context),
          resturantbox(context),
          resturantbox(context),
          resturantbox(context),
          resturantbox(context),
          resturantbox(context),
          resturantbox(context),
          resturantbox(context),
          resturantbox(context),
          resturantbox(context),
          ],
      ),
    );
  }

  Widget resturantbox(context) => GestureDetector(
    onDoubleTap: () {
      navigateTo(context, Menuscreen());
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Image(
              image: NetworkImage(
                "https://img.freepik.com/free-photo/elegant-smartphone-composition_23-2149437106.jpg?t=st=1744895966~exp=1744899566~hmac=c6e1f2eb501dd80252ce3dd685caa0b164d32111764f94e100c3089a38b1143e&w=740",
              ),
              width: double.infinity.w,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 3.0.h),
            child: Text(
              "home kitchen",
              style: TextStyle(color: Colors.black),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    ),
  );
}
