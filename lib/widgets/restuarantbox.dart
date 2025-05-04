import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/screens/menu/menuScreen.dart';
import 'package:foodapp/shared/constants.dart';

Widget resturantbox(context, model) => GestureDetector(
      onTap: () {
        navigateTo(
            context,
            Menuscreen(
              items: model.menuItems,
              name: model.name,
              img: model.img,
              deliveryprice: model.deliveryFee,
              deliverytime: model.deliveryTime,
              restaurantId: model.id,
            ));
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
              child: _buildRestaurantImage(model.img),
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
                      Text(model.deliveryTime,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Text(
                    "${model.name}",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Row(
                    children: [
                      Icon(Icons.star_rate_rounded, color: Colors.amber),
                      SizedBox(width: 5.w),
                      Text(
                        "${model.rating > 0 ? model.rating.toStringAsFixed(1) : 'No ratings'}",
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

// Helper widget to build restaurant image with error handling
Widget _buildRestaurantImage(String imageUrl) {
  try {
    if (imageUrl.startsWith('http')) {
      // Network image
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        height: 85.h,
        width: double.infinity,
        // Handle errors with network images
        errorBuilder: (context, error, stackTrace) {
          print("Error loading network image: $error");
          return Image.asset(
            'assets/images/restuarants/store.jpg',
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
      // Asset image
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        height: 85.h,
        width: double.infinity,
      );
    } else {
      // Default image
      return Image.asset(
        'assets/images/restuarants/store.jpg',
        fit: BoxFit.cover,
        height: 85.h,
        width: double.infinity,
      );
    }
  } catch (e) {
    print("Error handling image: $e");
    return Image.asset(
      'assets/images/restuarants/store.jpg',
      fit: BoxFit.cover,
      height: 85.h,
      width: double.infinity,
    );
  }
}
