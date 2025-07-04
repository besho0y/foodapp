import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/models/category.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/favourits/states.dart';
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

    return MultiBlocListener(
      listeners: [
        BlocListener<Restuarantscubit, ResturantsStates>(
          listener: (context, state) {
            if (state is RestuarantsErrorState) {
              print("Error: ${state.error}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: ${state.error}"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<Favouritecubit, FavouriteState>(
          listener: (context, state) {
            // Sync favorite status when favorites are loaded or changed
            if (state is FavouriteLoadedState ||
                state is FavouriteAddState ||
                state is FavouriteRemoveState) {
              final favCubit = Favouritecubit.get(context);
              final restCubit = Restuarantscubit.get(context);

              // Update favorite status for all restaurant items
              for (var restaurant in restCubit.restaurants) {
                favCubit.updateItemsFavoriteStatus(restaurant.menuItems);
              }
            }
          },
        ),
      ],
      child: BlocBuilder<Restuarantscubit, ResturantsStates>(
        builder: (context, state) {
          return ThemeBasedBackground(
            child: Scaffold(
              backgroundColor: Colors
                  .transparent, // Make scaffold transparent to show background
              body: RefreshIndicator(
                onRefresh: () async {
                  await cubit.refreshAllData();
                },
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primaryDark
                    : AppColors.primaryLight,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard
                    : AppColors.lightBackground,
                strokeWidth: 3.0,
                displacement: 40.0,
                child: CustomScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content doesn't fill screen
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
                                    child: Image.network(
                                      banner.imageUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade300,
                                          child: const Center(
                                            child: Icon(Icons.error,
                                                color: Colors.grey),
                                          ),
                                        );
                                      },
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
                                      width: 65.w,
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.darkCard
                                              : AppColors.primaryBrown,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? const Color.fromARGB(
                                                      255, 159, 156, 156)
                                                  : Colors.black12,
                                              blurRadius: 2,
                                              offset: const Offset(3, 1),
                                            )
                                          ]),
                                      child: _buildCategoryImage(category.img),
                                    ),
                                    SizedBox(height: 6.h),
                                    Flexible(
                                      child: Text(
                                        cubit.getCategoryName(
                                            category, isArabic),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                        textAlign: TextAlign.center,
                                      ),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryImage(String imageUrl) {
    try {
      print("Building category image for URL: $imageUrl");

      if (imageUrl.isEmpty) {
        // Empty URL - use default icon
        return Icon(
          Icons.category,
          size: 35.sp,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.orange
              : Colors.white,
        );
      }

      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        // Network image from Firebase Storage
        return ClipOval(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: 50.w,
            height: 50.h,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.orange
                        : Colors.white,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print("Error loading network category image '$imageUrl': $error");
              // Fallback to asset image or icon
              return _getFallbackCategoryImage(imageUrl);
            },
          ),
        );
      } else if (imageUrl.startsWith('assets/')) {
        // Asset image
        return ClipOval(
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            width: 48.w,
            height: 48.h,
            errorBuilder: (context, error, stackTrace) {
              print("Error loading asset category image '$imageUrl': $error");
              // Fallback to default icon
              return Icon(
                Icons.category,
                size: 30.sp,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.orange
                    : Colors.white,
              );
            },
          ),
        );
      } else {
        // Unknown format - try as asset first, then fallback
        return ClipOval(
          child: Image.asset(
            imageUrl.startsWith('assets/')
                ? imageUrl
                : 'assets/images/categories/$imageUrl',
            fit: BoxFit.cover,
            width: 48.w,
            height: 48.h,
            errorBuilder: (context, error, stackTrace) {
              print("Error loading category image '$imageUrl': $error");
              return _getFallbackCategoryImage(imageUrl);
            },
          ),
        );
      }
    } catch (e) {
      print("Exception in _buildCategoryImage for '$imageUrl': $e");
      return _getFallbackCategoryImage(imageUrl);
    }
  }

  Widget _getFallbackCategoryImage(String originalUrl) {
    // Try to determine appropriate fallback based on the original URL or use generic icon
    try {
      // Extract category name from URL to find appropriate asset
      final String categoryName = _extractCategoryNameFromUrl(originalUrl);
      final String assetPath = 'assets/images/categories/$categoryName.png';

      return ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: 48.w,
          height: 48.h,
          errorBuilder: (context, error, stackTrace) {
            // Final fallback - generic category icon
            return Icon(
              Icons.restaurant_menu,
              size: 30.sp,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.orange
                  : Colors.white,
            );
          },
        ),
      );
    } catch (e) {
      // Ultimate fallback
      return Icon(
        Icons.category,
        size: 30.sp,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.orange
            : Colors.white,
      );
    }
  }

  String _extractCategoryNameFromUrl(String url) {
    try {
      if (url.contains('/')) {
        final parts = url.split('/');
        final fileName = parts.last;
        // Remove file extension
        return fileName.split('.').first.toLowerCase();
      }
      return url.toLowerCase();
    } catch (e) {
      return 'default';
    }
  }
}
