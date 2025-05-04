import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/shared/constants.dart';

class Itemscreen extends StatefulWidget {
  const Itemscreen({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.img,
    this.items = const [],
  });

  final String name;
  final String description;
  final double price;
  final String img;
  final dynamic items;

  @override
  State<Itemscreen> createState() => _ItemscreenState();
}

class _ItemscreenState extends State<Itemscreen> {
  int quantity = 1;
  late dynamic displayedItems;

  @override
  void initState() {
    super.initState();

    if (widget.items.length <= 3) {
      displayedItems = widget.items;
    } else {
      widget.items.shuffle();
      displayedItems = widget.items.take(3).toList();
    }
  }

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  void addToCart(Layoutcubit cubit) {
    cubit.addToCart(
      name: widget.name,
      price: widget.price,
      quantity: quantity,
      img: widget.img,
    );
    Navigator.pop(context);
    showToast(
      'Added ${quantity}x ${widget.name} to cart',
      context: context,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      textStyle: const TextStyle(color: Colors.white, fontSize: 14.0),
      position: StyledToastPosition.bottom,
    );
  }

  // Helper method to get the right image widget
  Widget _getImageWidget(String? imageUrl) {
    try {
      // Handle null or empty image URL
      if (imageUrl == null || imageUrl.isEmpty) {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              Icons.no_food,
              size: 50.sp,
              color: Colors.grey[600],
            ),
          ),
        );
      }

      if (imageUrl.startsWith('http')) {
        // Network image with error handling
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading item image: $error");
            // Use a placeholder container instead of missing asset image
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 50.sp,
                  color: Colors.grey[600],
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
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
          errorBuilder: (context, error, stackTrace) {
            print("Error loading asset image: $error");
            return Container(
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 50.sp,
                  color: Colors.grey[600],
                ),
              ),
            );
          },
        );
      } else {
        // Default fallback for any other case
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              Icons.restaurant,
              size: 50.sp,
              color: Colors.grey[600],
            ),
          ),
        );
      }
    } catch (e) {
      print("Error handling item image: $e");
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Icon(
            Icons.restaurant,
            size: 50.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }
  }

  // Helper method for related item images
  Widget _getRelatedItemImage(String? imageUrl) {
    try {
      // Handle null or empty image URL
      if (imageUrl == null || imageUrl.isEmpty) {
        return Container(
          height: 80.h,
          width: 120.w,
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              Icons.no_food,
              size: 30.sp,
              color: Colors.grey[600],
            ),
          ),
        );
      }

      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          height: 80.h,
          width: 120.w,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading related item image: $error");
            return Container(
              height: 80.h,
              width: 120.w,
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 30.sp,
                  color: Colors.grey[600],
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 80.h,
              width: 120.w,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
          },
        );
      } else if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          height: 80.h,
          width: 120.w,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading asset image: $error");
            return Container(
              height: 80.h,
              width: 120.w,
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 30.sp,
                  color: Colors.grey[600],
                ),
              ),
            );
          },
        );
      } else {
        return Container(
          height: 80.h,
          width: 120.w,
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              Icons.restaurant,
              size: 30.sp,
              color: Colors.grey[600],
            ),
          ),
        );
      }
    } catch (e) {
      print("Error handling related item image: $e");
      return Container(
        height: 80.h,
        width: 120.w,
        color: Colors.grey[300],
        child: Center(
          child: Icon(
            Icons.restaurant,
            size: 30.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = Layoutcubit.get(context);

    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 100.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 300.h,
                            width: double.infinity,
                            child: _getImageWidget(widget.img),
                          ),
                          Positioned(
                            top: 40.h,
                            left: 0,
                            child: IconButton(
                              onPressed: () {
                                backarrow(context);
                              },
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 30.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 300.h,
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  widget.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    const Spacer(),
                                    Text(
                                      "${widget.price} EGP",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Special Request!",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.blueGrey,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                if (displayedItems.isNotEmpty) ...[
                                  SizedBox(height: 20.h),
                                  Text(
                                    "You may also like",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  SizedBox(height: 10.h),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children:
                                          displayedItems.map<Widget>((item) {
                                        return Container(
                                          width: 120.w,
                                          margin: EdgeInsets.only(
                                            right: 10.w,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10.r,
                                                ),
                                                child: _getRelatedItemImage(
                                                    item.img),
                                              ),
                                              SizedBox(height: 5.h),
                                              Text(
                                                item.name,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                "${item.price} EGP",
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.labelSmall,
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: IconButton(
                                                  onPressed: () {
                                                    cubit.addToCart(
                                                      name: item.name,
                                                      price: item.price,
                                                      quantity: 1,
                                                      img: item.img,
                                                    );
                                                    showToast(
                                                      'Added ${item.name} to cart',
                                                      context: context,
                                                      duration: const Duration(
                                                          seconds: 3),
                                                      backgroundColor:
                                                          Colors.green,
                                                      textStyle:
                                                          const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14.0),
                                                      position:
                                                          StyledToastPosition
                                                              .bottom,
                                                    );
                                                  },
                                                  icon: Icon(
                                                    Icons.add_shopping_cart,
                                                    size: 20.sp,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10.r)],
              ),
              child: Row(
                children: [
                  Card(
                    child: TextButton(
                      onPressed: () => addToCart(cubit),
                      child: Text(
                        "Add to cart",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Card(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: decrementQuantity,
                          icon: Icon(Icons.remove, size: 30.sp),
                        ),
                        Text(
                          "$quantity",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        IconButton(
                          onPressed: incrementQuantity,
                          icon: Icon(Icons.add, size: 30.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
