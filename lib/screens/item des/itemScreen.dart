import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/shared/optimized_image.dart';
import 'package:url_launcher/url_launcher.dart';

class Itemscreen extends StatefulWidget {
  const Itemscreen({
    super.key,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    required this.img,
    this.items = const [],
    this.category = '',
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantNameAr,
    required this.deliveryFee,
  });

  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final String img;
  final dynamic items;
  final String category;
  final String restaurantId;
  final String restaurantName;
  final String restaurantNameAr;
  final String deliveryFee;

  @override
  State<Itemscreen> createState() => _ItemscreenState();
}

class _ItemscreenState extends State<Itemscreen> {
  int quantity = 1;
  late dynamic displayedItems;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRelatedItems();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadRelatedItems() {
    // Get items of the same category if possible
    if (widget.items.isNotEmpty && widget.category.isNotEmpty) {
      final sameCategory = widget.items.where((item) {
        // Skip the current item
        if (item.name == widget.name) return false;

        // Match by category
        return item.category.toLowerCase() == widget.category.toLowerCase();
      }).toList();

      if (sameCategory.length >= 3) {
        // If we have enough items in the same category
        displayedItems = sameCategory.take(3).toList();
      } else {
        // If not enough in the same category, add other items to reach 3
        var otherItems = widget.items
            .where((item) =>
                item.name != widget.name &&
                item.category.toLowerCase() != widget.category.toLowerCase())
            .toList();

        // Combine same category with others
        displayedItems = [...sameCategory];

        // Add other items until we have 3 or run out of items
        if (otherItems.isNotEmpty) {
          otherItems.shuffle();
          int itemsNeeded = (3 - displayedItems.length).toInt();
          displayedItems.addAll(otherItems.take(itemsNeeded));
        }
      }
    } else {
      // Fallback to random selection if no category matching is possible
      var availableItems =
          widget.items.where((item) => item.name != widget.name).toList();

      if (availableItems.isNotEmpty) {
        availableItems.shuffle();
        displayedItems = availableItems.take(3).toList();
      } else {
        displayedItems = [];
      }
    }
  }

  void incrementQuantity() {
    if (!mounted) return;
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 1 && mounted) {
      setState(() {
        quantity--;
      });
    }
  }

  void addToCart(Layoutcubit cubit) {
    // Debug: Print restaurant ID being passed to cart
    print(
        "🛒 ITEM SCREEN: Adding to cart with restaurant ID: '${widget.restaurantId}'");
    print("🛒 ITEM SCREEN: Restaurant name: '${widget.restaurantName}'");
    print("🛒 ITEM SCREEN: Delivery fee: '${widget.deliveryFee}'");

    // Add item to cart with comment
    cubit.addToCart(
      context: context,
      name: widget.name,
      nameAr: widget.nameAr,
      price: widget.price,
      quantity: quantity,
      img: widget.img,
      comment: _commentController.text.trim(),
      restaurantId: widget.restaurantId,
      restaurantName: widget.restaurantName,
      restaurantNameAr: widget.restaurantNameAr,
      deliveryFee: widget.deliveryFee,
    );

    Navigator.pop(context);

    final isRTL = Directionality.of(context) == TextDirection.rtl;
    showToast(
      'Added ${quantity}x ${isRTL ? widget.nameAr : widget.name} to cart',
      context: context,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      textStyle: const TextStyle(color: Colors.white, fontSize: 14.0),
      position: StyledToastPosition.bottom,
    );
  }

  // Add WhatsApp functionality
  Future<void> _openWhatsApp() async {
    const phoneNumber = '+201557301515';
    const whatsappUrl = 'https://wa.me/$phoneNumber';

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        if (mounted) {
          showToast(
            "Could not launch WhatsApp",
            context: context,
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
            textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
            position: StyledToastPosition.bottom,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showToast(
          "Error opening WhatsApp: ${e.toString()}",
          context: context,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
          position: StyledToastPosition.bottom,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = Layoutcubit.get(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    final double scale = isTablet ? 0.75 : 1.0;
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
                            child: ItemImageWidget(
                              imageUrl: widget.img,
                              width: double.infinity,
                              height: 300.h,
                            ),
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
                                size: 30.sp * scale,
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
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRTL ? widget.nameAr : widget.name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  isRTL
                                      ? widget.descriptionAr
                                      : widget.description,
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

                                // Comment TextField (replaces Special Request button)
                                TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText:
                                        S.of(context).special_request_hint,
                                    labelText: S.of(context).special_request,
                                    prefixIcon: const Icon(Icons.comment),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        width: 2.0,
                                      ),
                                    ),
                                    labelStyle: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    hintStyle: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                  cursorColor: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  maxLines: 2,
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
                                                child: ItemImageWidget(
                                                  imageUrl: item.img,
                                                  width: 120.w,
                                                  height: 80.h,
                                                ),
                                              ),
                                              SizedBox(height: 5.h),
                                              Text(
                                                isRTL ? item.nameAr : item.name,
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
                                                      context: context,
                                                      name: item.name,
                                                      nameAr: item.nameAr,
                                                      price: item.price,
                                                      quantity: 1,
                                                      img: item.img,
                                                      restaurantId:
                                                          widget.restaurantId,
                                                      restaurantName:
                                                          widget.restaurantName,
                                                      restaurantNameAr: widget
                                                          .restaurantNameAr,
                                                      deliveryFee:
                                                          widget.deliveryFee,
                                                    );
                                                    final isRTL =
                                                        Directionality.of(
                                                                context) ==
                                                            TextDirection.rtl;
                                                    showToast(
                                                      'Added ${isRTL ? item.nameAr : item.name} to cart',
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
                                                  icon: const Icon(
                                                    Icons.add_circle,
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
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10.r)
                  ],
                ),
                child: Row(
                  children: [
                    Card(
                      child: TextButton(
                        onPressed: () => addToCart(cubit),
                        child: Text(
                          S.of(context).add_to_cart,
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
          ),
        ],
      ),
    );
  }
}
