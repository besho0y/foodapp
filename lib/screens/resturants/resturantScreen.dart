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
    onTap: () {
      navigateTo(context, Menuscreen());
    },
    child: Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 120.h,
            width: 130.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: Image.asset("assets/images/burger.png", fit: BoxFit.cover),
          ),
          Text(
            "home kitchen",
            style: Theme.of(context).textTheme.labelLarge,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    ),
  );
}
