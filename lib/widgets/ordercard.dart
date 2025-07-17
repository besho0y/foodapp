import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/screens/checkout/checkout_screen.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/shared/colors.dart';

class OrderCard extends StatefulWidget {
  final dynamic model; // Order model

  const OrderCard({super.key, required this.model});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool isExpanded = false;
  late double calculatedTotal;

  @override
  void initState() {
    super.initState();
    // Calculate the total from items
    calculatedTotal = _calculateTotal();
  }

  double _calculateTotal() {
    final model = widget.model;
    if (model.calculateTotal != null) {
      // If model has a calculateTotal method
      return model.calculateTotal();
    } else {
      // Manual calculation as a fallback
      double total = 0.0;
      for (var item in model.items) {
        double price = 0.0;
        int quantity = 1;

        if (item is Map) {
          var itemPrice = item['price'];
          if (itemPrice is int) {
            price = itemPrice.toDouble();
          } else if (itemPrice is double) {
            price = itemPrice;
          }

          quantity = item['quantity'] ?? 1;
        } else if (item.price != null) {
          price = item.price;
          quantity = item.quantity ?? 1;
        }

        total += price * quantity;
      }
      return total;
    }
  }

  // Reorder functionality
  void _reorderItems(BuildContext context) async {
    try {
      print('🔄 === STARTING REORDER ===');

      final layoutCubit = Layoutcubit.get(context);
      final profileCubit = ProfileCubit.get(context);
      final model = widget.model;

      print('📝 Reordering ${model.items.length} items');
      print('📍 Order address: ${model.address}');

      // Clear current cart
      layoutCubit.clearCart();
      print('🗑️ Cart cleared');

      // Convert order items back to CartItem format and add to cart
      for (var item in model.items) {
        try {
          String itemName = '';
          String itemNameAr = '';
          double itemPrice = 0.0;
          int quantity = 1;
          String? comment;
          String restaurantId = '';
          String restaurantName = '';
          String restaurantNameAr = '';
          String deliveryFee = '30.0'; // Default delivery fee
          String img = '';

          // Handle both Map and object formats
          if (item is Map) {
            itemName = item['name'] ?? 'Unknown item';
            itemNameAr = item['nameAr'] ?? item['namear'] ?? itemName;

            // Handle both int and double price formats
            var price = item['price'];
            if (price is int) {
              itemPrice = price.toDouble();
            } else if (price is double) {
              itemPrice = price;
            }

            quantity = item['quantity'] ?? 1;
            comment = item['comment'];
            restaurantId = item['restaurantId'] ?? '';
            restaurantName = item['restaurantName'] ?? '';
            restaurantNameAr = item['restaurantNameAr'] ?? '';
            deliveryFee = item['deliveryFee'] ?? '30.0';
            img = item['img'] ?? '';
          } else {
            // Handle object format
            itemName = item.name ?? 'Unknown item';
            itemNameAr = item.nameAr ?? itemName;
            itemPrice = item.price ?? 0.0;
            quantity = item.quantity ?? 1;
            comment = item.comment;
            restaurantId = item.restaurantId ?? '';
            restaurantName = item.restaurantName ?? '';
            restaurantNameAr = item.restaurantNameAr ?? '';
            deliveryFee = item.deliveryFee ?? '30.0';
            img = item.img ?? '';
          }

          // Ensure we have required fields
          if (itemName.isEmpty) {
            print('⚠️ Skipping item with empty name');
            continue;
          }

          // Generate unique restaurant ID if missing
          if (restaurantId.isEmpty) {
            restaurantId = 'reorder_${DateTime.now().millisecondsSinceEpoch}';
          }

          print('➕ Adding item: $itemName (x$quantity) from $restaurantName');

          // Add item to cart
          layoutCubit.addToCart(
            context: context,
            name: itemName,
            nameAr: itemNameAr,
            price: itemPrice,
            quantity: quantity,
            img: img,
            comment: comment,
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            restaurantNameAr: restaurantNameAr,
            deliveryFee: deliveryFee,
          );
        } catch (itemError) {
          print('❌ Error adding item to cart: $itemError');
          // Continue with other items
        }
      }

      print('✅ All items added to cart');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${layoutCubit.cartitems.length} items added to cart for reorder'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to checkout screen
      if (layoutCubit.cartitems.isNotEmpty) {
        print(
            '🛒 Navigating to checkout with ${layoutCubit.cartitems.length} items');

        // Navigate to checkout
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CheckoutScreen(),
          ),
        );
      } else {
        print('❌ No items were added to cart');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to add items to cart. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      print('🔄 === REORDER COMPLETED ===');
    } catch (e) {
      print('❌ Error during reorder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error reordering items. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                    width: 180.w,
                    child: Text(
                      model.address != null && model.address['address'] != null
                          ? "${model.address['address']}"
                          : "No address",
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _formatDate(model.date),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Compact reorder button at the top
                  SizedBox(
                    height: 32.h,
                    child: ElevatedButton.icon(
                      onPressed: () => _reorderItems(context),
                      icon: Icon(
                        Icons.refresh,
                        size: 14.sp,
                      ),
                      label: Text(
                        'Reorder',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.brown.shade900
                                : Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
                        elevation: 1,
                        minimumSize: Size(0, 32.h),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Row(
                  children: [
                    Text(
                      "${S.of(context).order}:",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "${model.id}"
                          .substring(0, 8), // Show first 8 chars of order ID
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(fontSize: 18.sp),
                    ),
                  ],
                ),
              ),
              // Show username if available
              if (model.userName != null && model.userName!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  child: Row(
                    children: [
                      Text(
                        "${S.of(context).customer}:",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          "${model.userName}",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge!.copyWith(fontSize: 16.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Row(
                  children: [
                    Text(
                      "${S.of(context).status}:",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      _getTranslatedStatus(context, model.status),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(
                            fontSize: 18.sp,
                            color: _getStatusColor(model.status),
                          ),
                    ),
                    SizedBox(width: 5.w),
                    Icon(
                      _getStatusIcon(model.status),
                      color: _getStatusColor(model.status),
                      size: 20.sp,
                    ),
                  ],
                ),
              ),

              /// Expandable Description
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
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
                            S.of(context).orderdetails,
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
                        (index) {
                          // Handle both the new and old model formats
                          var item = model.items[index];
                          String itemName = "";
                          double itemPrice = 0.0;
                          int quantity = 1;
                          String? comment;

                          // If item is a Map (new format)
                          if (item is Map) {
                            itemName = item['name'] ?? 'Unknown item';
                            // Handle both int and double price formats
                            var price = item['price'];
                            if (price is int) {
                              itemPrice = price.toDouble();
                            } else if (price is double) {
                              itemPrice = price;
                            } else {
                              itemPrice = 0.0;
                            }
                            quantity = item['quantity'] ?? 1;
                            comment = item['comment'];
                          }
                          // If item is an older model object
                          else if (item.name != null) {
                            itemName = item.name;
                            itemPrice = item.price;
                            quantity = item.quantity ?? 1;
                            comment = item.comment;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        Directionality.of(context) ==
                                                TextDirection.rtl
                                            ? (item is Map
                                                ? item['nameAr'] ?? item['name']
                                                : item.nameAr ?? item.name)
                                            : (item is Map
                                                ? item['name']
                                                : item.name),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge!.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.sp,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "x$quantity",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall!.copyWith(
                                              color: Colors.grey[600],
                                              fontSize: 14.sp,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Text(
                                      "${itemPrice.toStringAsFixed(2)} ${S.of(context).egp}",
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
                              // Display comment if available
                              if (comment != null && comment.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8.w, right: 8.w, bottom: 8.h),
                                  child: Row(
                                    children: [
                                      Icon(Icons.comment,
                                          size: 14.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Text(
                                          "${S.of(context).note}: $comment",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontStyle: FontStyle.italic,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey[300]
                                                    : Colors.grey[700],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Show original price and discount if available
                        if (widget.model.hasDiscount != null &&
                            widget.model.hasDiscount())
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    size: 14.sp,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "${widget.model.promocode}",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Text(
                                    "Subtotal: ${widget.model.getOriginalPrice().toStringAsFixed(2)} ${S.of(context).egp}",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    "-${widget.model.promoDiscount!.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                            ],
                          ),

                        // Always show the items subtotal
                        Text(
                          "${S.of(context).items}: ${calculatedTotal.toStringAsFixed(2)} ${S.of(context).egp}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[700],
                          ),
                        ),

                        // Show delivery fee (calculated as total - items - out of area fee)
                        Text(
                          "${S.of(context).delivery_fee}: ${(widget.model.total - calculatedTotal - (widget.model.outOfAreaFee ?? 0.0)).toStringAsFixed(2)} ${S.of(context).egp}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[700],
                          ),
                        ),

                        // Show out of area fee if available
                        if (widget.model.outOfAreaFee != null &&
                            widget.model.outOfAreaFee! > 0)
                          Text(
                            "${S.of(context).out_of_area_fee}: ${widget.model.outOfAreaFee!.toStringAsFixed(2)} ${S.of(context).egp}",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                            ),
                          ),

                        SizedBox(height: 2.h),

                        // Show payment reference for InstaPay or transaction ID for card payments
                        if (widget.model.paymentMethod == 'instapay' &&
                            widget.model.paymentReference != null &&
                            widget.model.paymentReference!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.confirmation_number,
                                  size: 14.sp,
                                  color: Colors.blue.shade700,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "Ref: ${widget.model.paymentReference}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Show transaction ID for card payments
                        if (widget.model.paymentMethod == 'card' &&
                            widget.model.transactionId != null &&
                            widget.model.transactionId!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  size: 14.sp,
                                  color: Colors.green.shade700,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "Transaction: ${widget.model.transactionId!.length > 10 ? widget.model.transactionId!.substring(0, 10) + '...' : widget.model.transactionId}",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Total price with discount applied
                        Text(
                          "${S.of(context).total}: ${widget.model.total.toStringAsFixed(2)} ${S.of(context).egp}",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
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

  Color _getStatusColor(String status) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        // Use brown for both dark and light mode for other statuses
        return isDarkMode ? AppColors.darkText : Colors.black;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  String _getTranslatedStatus(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return S.of(context).delivered;
      case 'pending':
        return S.of(context).pending;
      case 'cancelled':
        return S.of(context).cancelled;
      case 'processing':
        return S.of(context).processing;
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      case 'processing':
        return Icons.sync;
      default:
        return Icons.info;
    }
  }
}
