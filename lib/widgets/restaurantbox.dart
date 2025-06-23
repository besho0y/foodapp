import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/models/resturant.dart';
import 'package:foodapp/screens/menu/menuScreen.dart';
import 'package:foodapp/shared/constants.dart';

class RestaurantBox extends StatelessWidget {
  final Restuarants restaurant;

  const RestaurantBox({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

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
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(13)),
              child: _buildRestaurantImage(restaurant.img),
            ),
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining_outlined),
                      SizedBox(width: 5.w),
                      Text(restaurant.deliveryTime,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Text(
                    isRTL ? restaurant.nameAr : restaurant.name,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rate_rounded, color: Colors.amber),
                      SizedBox(width: 5.w),
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

  Widget _buildRestaurantImage(String imageUrl) {
    try {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          height: 85.h,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading network image: $error");
            return Image.asset(
              'assets/images/light.PNG',
              fit: BoxFit.cover,
              height: 85.h,
              width: double.infinity,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        );
      } else if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          height: 85.h,
          width: double.infinity,
        );
      } else {
        return Image.asset(
          'assets/images/light.PNG',
          fit: BoxFit.cover,
          height: 85.h,
          width: double.infinity,
        );
      }
    } catch (e) {
      print("Error handling image: $e");
      return Image.asset(
        'assets/images/light.PNG',
        fit: BoxFit.cover,
        height: 85.h,
        width: double.infinity,
      );
    }
  }
}
