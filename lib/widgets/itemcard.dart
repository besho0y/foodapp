import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/models/resturant.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/item%20des/itemScreen.dart';
import 'package:foodapp/shared/constants.dart';

Widget itemcard(context, bool fromFavourites, Item model, dynamic items) {
  var cubit = Favouritecubit.get(context);
  final isRTL = Directionality.of(context) == TextDirection.rtl;

  // Get the restaurant from the items list
  Restuarants? restaurant;
  if (items is List<Restuarants>) {
    try {
      restaurant = items.firstWhere(
        (r) => r.menuItems.any((item) => item.id == model.id),
      );
    } catch (e) {
      // Restaurant not found
      restaurant = null;
    }
  }

  return Padding(
    padding: EdgeInsets.only(bottom: 5.h),
    child: GestureDetector(
      onTap: () {
        navigateTo(
          context,
          Itemscreen(
            name: model.name,
            nameAr: model.nameAr,
            description: model.description,
            descriptionAr: model.descriptionAr,
            price: model.price,
            img: model.img,
            items: items,
            category: model.category,
            restaurantId: restaurant?.id ?? '',
            restaurantName: restaurant?.name ?? '',
            restaurantNameAr: restaurant?.nameAr ?? '',
            deliveryFee: restaurant?.deliveryFee ?? '0',
          ),
        );
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
            right: isRTL ? null : -5.w,
            left: isRTL ? -5.w : null,
            child: SizedBox(
              width: 320.w,
              height: 110.h,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 45.w),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (restaurant != null) ...[
                            Text(
                              isRTL ? restaurant.nameAr : restaurant.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: 2.h),
                          ],
                          Text(
                            isRTL ? model.nameAr : model.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            isRTL ? model.descriptionAr : model.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(
                            width: 220.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${model.price} ${S.of(context).egp}",
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                IconButton(
                                  onPressed: () {
                                    cubit.toggleFavourite(model);
                                  },
                                  icon: Icon(
                                    model.isfavourite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        model.isfavourite ? Colors.red : null,
                                  ),
                                  padding: EdgeInsets.zero,
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
            top: 20.h,
            left: isRTL ? null : -13.w,
            right: isRTL ? -13.w : null,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: _getImageProvider(model.img),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Helper function to get the correct image provider
ImageProvider _getImageProvider(String imageUrl) {
  try {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    } else {
      // Default fallback image
      return const AssetImage('assets/image/category/default.jpg');
    }
  } catch (e) {
    print("Error creating image provider: $e");
    return const AssetImage('assets/images/items/default.jpg');
  }
}
