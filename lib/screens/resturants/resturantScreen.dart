import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/screens/resturants/states.dart';
import 'package:foodapp/shared/colors.dart';
import 'package:foodapp/widgets/restuarantbox.dart';

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
                    viewportFraction: 1.0,
                    reverse: false,
                    enlargeCenterPage: true,
                    height: 150.h,
                    aspectRatio: 1,
                    autoPlay: true,
                    autoPlayCurve: Curves.fastOutSlowIn,
                  ),
                ),
                SizedBox(height: 10.w),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(cubit.categories.length, (index) {
                      return GestureDetector(
                        onTap: () {
                         cubit.filterRestaurants(cubit.categories[index]["name"]);
                        },
                        child: Container(
                          width: 90.w,
                          margin: EdgeInsets.symmetric(horizontal: 6.w),
                          padding: EdgeInsets.symmetric(
                            vertical: 8.h,
                            horizontal: 8.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarylight,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 50.h,
                                width: 50.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(5.w),
                                  child: Image.asset(
                                    "${cubit.categories[index]["img"]}",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "${cubit.categories[index]["name"]}",
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.labelMedium!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
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
                  childAspectRatio: 1 / 1.1,
                  children:
                      cubit.restaurants.map((model) {
                        return resturantbox(context, model);
                      }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
