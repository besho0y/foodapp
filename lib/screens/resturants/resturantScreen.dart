import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
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
      listener: (context, state) {
        if (state is RestuarantsErrorState) {
          print("Error loading restaurants: ${state.error}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${state.error}")),
          );
        } else if (state is RestuarantsGetDataSuccessState) {
          print("Restaurants loaded successfully: ${cubit.restaurants.length}");
        }
      },
      builder: (context, state) {
        final cats = cubit.categories(context);

        return Padding(
          padding: EdgeInsets.all(12.0.w),
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(Duration(milliseconds: 500));
              cubit.getRestuarants();
            },
            color: Colors.deepOrange,
            child: CustomScrollView(
              slivers: [
                // Banner
                SliverToBoxAdapter(
                  child: CarouselSlider.builder(
                    itemCount: cubit.banners.length,
                    itemBuilder: (context, index, realIdx) => ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        cubit.banners[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    options: CarouselOptions(
                      height: 160.h,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                      autoPlayCurve: Curves.easeInOut,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                // Categories
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cats.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemBuilder: (context, index) {
                        var category = cats[index];
                        return GestureDetector(
                          onTap: () {
                            cubit.filterRestaurants(category["name"]);
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 60.h,
                                width: 60.w,
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.darkCard
                                      : Colors.orange.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  category["img"],
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                category["name"],
                                style: Theme.of(context).textTheme.labelMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                // Restaurant Grid
                if (state is RestuarantsLoadingState)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.deepOrange,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            S.of(context).loadingres,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (cubit.restaurants.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "No restaurants found",
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return resturantbox(context, cubit.restaurants[index]);
                      },
                      childCount: cubit.restaurants.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.h,
                      crossAxisSpacing: 10.w,
                      childAspectRatio: 0.8,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
