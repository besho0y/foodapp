import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/models/resturant.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/favourits/states.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/shared/auth_helper.dart';
import 'package:foodapp/shared/colors.dart';
import 'package:foodapp/widgets/itemcard.dart';

class FavouritsScreen extends StatefulWidget {
  const FavouritsScreen({super.key});

  @override
  State<FavouritsScreen> createState() => _FavouritsScreenState();
}

class _FavouritsScreenState extends State<FavouritsScreen> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Enhanced initialization for better direct navigation handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthHelper.isUserLoggedIn() && !_hasInitialized) {
        final cubit = Favouritecubit.get(context);

        print("🔄 Favorites screen opened");
        print("📝 Favorites cubit has ${cubit.favourites.length} favorites");

        // Always try to load favorites when screen opens
        // The cubit will handle whether to use cached data or reload
        cubit.loadFavourites().then((_) {
          print("✅ Favorites loading completed on screen open");
        }).catchError((error) {
          print("❌ Error loading favorites on screen open: $error");
          // Show error message and reload option
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Error loading favorites. Tap reload to try again.'),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Reload',
                  onPressed: () => cubit.reloadFavorites(),
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        });

        _hasInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    if (!AuthHelper.isUserLoggedIn()) {
      return ThemeBasedBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 100.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Please login to view your favorites',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () =>
                      AuthHelper.requireAuthenticationForFavorites(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 74, 26, 15),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocConsumer<Favouritecubit, FavouriteState>(
      listener: (context, state) {
        // Handle any side effects here if needed
        if (state is FavouriteErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        var cubit = Favouritecubit.get(context);

        if (state is FavouriteLoadingState) {
          return const ThemeBasedBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (cubit.favourites.isEmpty) {
          return ThemeBasedBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 100.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      S.of(context).no_favorites,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Start adding items to your favorites to see them here!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    // Enhanced reload button for better UX
                    ElevatedButton.icon(
                      onPressed: () async {
                        print("🔄 Manual reload favorites triggered");
                        await cubit.reloadFavorites();
                      },
                      icon: Icon(
                        Icons.refresh,
                        size: 18.sp,
                      ),
                      label: const Text('Reload Favorites'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 12.h),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ThemeBasedBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: RefreshIndicator(
              onRefresh: () async {
                await cubit.loadFavourites();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: cubit.favourites.length,
                itemBuilder: (context, index) {
                  // Get restaurant information from Restuarantscubit for proper location-based calculation
                  final restaurantCubit = Restuarantscubit.get(context);
                  final favoriteItem = cubit.favourites[index];

                  // Find the restaurant that contains this item
                  Restuarants? restaurant;
                  try {
                    restaurant = restaurantCubit.restaurants.firstWhere(
                      (r) =>
                          r.menuItems.any((item) => item.id == favoriteItem.id),
                    );
                  } catch (e) {
                    print(
                        "Restaurant not found for favorite item ${favoriteItem.id}");
                    restaurant = null;
                  }

                  return itemcard(
                    context,
                    true,
                    favoriteItem,
                    restaurant != null ? [restaurant] : null,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
