import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/models/resturant.dart';
import 'package:foodapp/screens/menu/menuScreen.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/shared/optimized_image.dart';

class RestaurantBox extends StatelessWidget {
  final Restuarants restaurant;

  const RestaurantBox({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return GestureDetector(
      onTap: () {
        navigateTo(
          context,
          Menuscreen(
            items: restaurant.menuItems,
            name: isRTL ? restaurant.nameAr : restaurant.name,
            img: restaurant.img,
            deliveryprice: restaurant.deliveryFee,
            deliverytime: restaurant.deliveryTime,
            restaurantId: restaurant.id,
            outOfAreaFee: restaurant.outOfAreaFee,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!
                : Colors.grey[400]!,
            width: 2.w,
          ),
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              child: RestaurantImageWidget(
                imageUrl: restaurant.img,
                height: isTablet ? 90.h : 80.h,
                width: double.infinity,
              ),
            ),
            SizedBox(height: isTablet ? 5.h : 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 4.w : 5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.delivery_dining_outlined,
                          size: isTablet ? 14.sp : null),
                      SizedBox(width: isTablet ? 4.w : 5.w),
                      Text(restaurant.deliveryTime,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Text(
                    isRTL ? restaurant.nameAr : restaurant.name,
                    style: Theme.of(context).textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(Icons.star_rate_rounded,
                          color: Colors.amber, size: isTablet ? 14.sp : null),
                      SizedBox(width: isTablet ? 4.w : 5.w),
                      Text(
                        restaurant.rating > 0
                            ? restaurant.rating.toStringAsFixed(1)
                            : S.of(context).no_ratings,
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
  }
}
