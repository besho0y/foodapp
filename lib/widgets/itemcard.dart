import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/models/resturant.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/favourits/states.dart';
import 'package:foodapp/screens/item%20des/itemScreen.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/shared/optimized_image.dart';

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

  // Debug prints
  print("Item ${model.name} - nameAr: '${model.nameAr}' - RTL: $isRTL");

  return Padding(
    padding: EdgeInsets.only(bottom: 12.h),
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
            items: restaurant?.menuItems ?? [],
            category: model.category,
            restaurantId: restaurant?.id ?? '',
            restaurantName: restaurant?.name ?? '',
            restaurantNameAr: restaurant?.nameAr ?? '',
            deliveryFee: restaurant?.deliveryFee ?? '0',
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 130.h,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // Image Section
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: ItemImageWidget(
                  imageUrl: model.img,
                  width: 100.w,
                  height: 100.h,
                ),
              ),
              SizedBox(width: 12.w),

              // Content Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top section with item name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRTL ? model.nameAr : model.name,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: isRTL ? TextAlign.right : TextAlign.left,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          isRTL ? model.descriptionAr : model.description,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.8),
                                    fontSize: 12.sp,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: isRTL ? TextAlign.right : TextAlign.left,
                        ),
                      ],
                    ),

                    // Bottom section with price and favorite
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${model.price} ${S.of(context).egp}",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                  color: Theme.of(context).primaryColor,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        BlocBuilder<Favouritecubit, FavouriteState>(
                          builder: (context, state) {
                            // Update the model's favorite status based on cubit's cache
                            model.isfavourite = cubit.isFavorite(model.id);

                            return IconButton(
                              onPressed: () {
                                cubit.toggleFavourite(model);
                              },
                              icon: Icon(
                                model.isfavourite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: model.isfavourite
                                    ? Colors.red
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                size: 22.sp,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minWidth: 35.w,
                                minHeight: 35.h,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
