import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/screens/menu/menuScreen.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/screens/resturants/states.dart';
import 'package:foodapp/shared/colors.dart';
import 'package:foodapp/shared/constants.dart';

class Resturantscreen extends StatelessWidget {
  const Resturantscreen({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = Restuarantscubit.get(context);
    return BlocConsumer<Restuarantscubit, ResturantsStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 5.h),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CarouselSlider.builder(
                  itemCount: cubit.banners.length,
                  itemBuilder:
                      (
                        BuildContext context,
                        int itemindex,
                        int pageviewindex,
                      ) => Image.asset(cubit.banners[itemindex]),
                  options: CarouselOptions(
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    enlargeCenterPage: true,
                    height: 150.h,
                    aspectRatio: 1,
                    autoPlay: true,
                    autoPlayCurve: Curves.fastOutSlowIn,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          
                        },
                        child: Container(
                          height: 35.h,
                          margin: EdgeInsets.symmetric(horizontal: 5.w),
                          decoration: BoxDecoration(
                            color: AppColors.primarylight,
                            borderRadius: BorderRadius.circular(25.r),
                            border: Border.all(
                              color: Colors.grey[500]!,
                              width: 1.w,
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Category $index",
                                style: Theme.of(
                                  context,
                                ).textTheme.labelMedium!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 10.w),

                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 5.w,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(11, (_) => resturantbox(context)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget resturantbox(context) => GestureDetector(
    onTap: () {
      navigateTo(context, Menuscreen());
    },
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[500]!, width: 2.w),
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            child: Image.asset(
              "assets/images/store.jpg",
              fit: BoxFit.cover,
              height: 80.h,
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
                  "Home Kitchen",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Row(
                  children: [
                    Icon(Icons.star_rate_rounded, color: Colors.amber),
                    SizedBox(width: 5.w),
                    Text("4.5", style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
