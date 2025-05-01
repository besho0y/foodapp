import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/shared/colors.dart';

class OrderCard extends StatefulWidget {
  final dynamic model; // You can replace dynamic with your model type

  const OrderCard({Key? key, required this.model}) : super(key: key);

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final model = widget.model;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 225.w,
                    child: Text(
                      "${model.address}",
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      "${model.orderDate}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Row(
                  children: [
                    Text(
                      "Order:",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "${model.orderId}",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(fontSize: 18.sp),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Row(
                  children: [
                    Text(
                      "Restaurant:",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "${model.restaurantName}",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(fontSize: 18.sp),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Row(
                  children: [
                    Text(
                      "Status:",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      model.status ? "Delivered" : "Pending",
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(fontSize: 18.sp),
                    ),
                  ],
                ),
              ),

              /// Expandable Description
              AnimatedCrossFade(
                firstChild: SizedBox.shrink(),
                secondChild: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            
                            size: 20.sp,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            "Order Details",
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      ...List.generate(
                        model.items.length,
                        (index) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                model.items[index].name,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                ),
                              ),
                              Text(
                                "${model.items[index].price.toStringAsFixed(2)} EGP",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall!.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState:
                    isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Total: ${model.totalAmount}",
                      textAlign: TextAlign.end,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      icon: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 25.sp,
                    
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
