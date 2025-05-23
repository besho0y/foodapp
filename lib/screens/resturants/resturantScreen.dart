import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/models/category.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/screens/resturants/states.dart';
import 'package:foodapp/shared/colors.dart';
import 'package:foodapp/widgets/restaurantbox.dart';

class Resturantscreen extends StatefulWidget {
  const Resturantscreen({super.key});

  @override
  State<Resturantscreen> createState() => _ResturantscreenState();
}

class _ResturantscreenState extends State<Resturantscreen> {
  @override
  void initState() {
    super.initState();
    // Data is already initialized in cubit constructor
  }

  @override
  Widget build(BuildContext context) {
    var cubit = Restuarantscubit.get(context);
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocConsumer<Restuarantscubit, ResturantsStates>(
      listener: (context, state) {
        if (state is RestuarantsErrorState) {
          print("Error: ${state.error}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${state.error}")),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              // Only refresh restaurants data
              await cubit.refreshRestaurants();
            },
            color: Colors.deepOrange,
            backgroundColor: Theme.of(context).cardColor,
            child: CustomScrollView(
              slivers: [
                // Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 150.h,
                        viewportFraction: 0.8,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                      ),
                      items: cubit.banners.map((banner) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(horizontal: 5.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Image.asset(
                                  banner,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Categories
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      height: 90.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: cubit.categories.length,
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        itemBuilder: (context, index) {
                          Category category = cubit.categories[index];
                          return GestureDetector(
                            onTap: () {
                              cubit.filterRestaurants(category);
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
                                    category.img,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  cubit.getCategoryName(category, isArabic),
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Restaurants Grid
                SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: state is RestuarantsLoadingState
                      ? const SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10.h,
                            crossAxisSpacing: 10.w,
                            childAspectRatio: 0.8,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return RestaurantBox(
                                restaurant: cubit.restaurants[index],
                              );
                            },
                            childCount: cubit.restaurants.length,
                          ),
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
