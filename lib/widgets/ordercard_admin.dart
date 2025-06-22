import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/shared/colors.dart';

class OrderCardAdmin extends StatefulWidget {
  final dynamic model; // Order model
  final Function(String, String) onStatusChange; // Callback for status change

  const OrderCardAdmin({
    Key? key,
    required this.model,
    required this.onStatusChange,
  }) : super(key: key);

  @override
  State<OrderCardAdmin> createState() => _OrderCardAdminState();
}

class _OrderCardAdminState extends State<OrderCardAdmin> {
  bool isExpanded = false;
  late double calculatedTotal;
  late String currentStatus;
  String? userPhoneNumber;
  bool isLoadingPhone = false;

  // Available status options
  final List<String> statusOptions = [
    'Pending',
    'Processing',
    'Delivered',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    calculatedTotal = _calculateTotal();
    currentStatus = widget.model.status;
    _fetchUserPhoneNumber();
  }

  Future<void> _fetchUserPhoneNumber() async {
    final model = widget.model;
    if (model.userId != null && model.userId.toString().isNotEmpty) {
      if (!mounted) return;
      setState(() {
        isLoadingPhone = true;
      });

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(model.userId)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;
          final phone =
              userData['phoneNumber'] ?? userData['phone'] ?? 'No phone';

          if (mounted) {
            setState(() {
              userPhoneNumber = phone.toString();
              isLoadingPhone = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              userPhoneNumber = 'User not found';
              isLoadingPhone = false;
            });
          }
        }
      } catch (e) {
        print('Error fetching user phone: $e');
        if (mounted) {
          setState(() {
            userPhoneNumber = 'Error loading phone';
            isLoadingPhone = false;
          });
        }
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final smallScreen = screenWidth < 360;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isTablet ? 700.w : double.infinity,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        child: Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 3.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: BorderSide(
              color: _getStatusColor(currentStatus).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(smallScreen ? 8.w : 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with order ID and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.receipt,
                                size: 14.sp, color: Colors.grey[800]),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                "ID: ${_truncateId(model.id)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: smallScreen ? 11.sp : 12.sp,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          _formatDateTimeShort(model.date),
                          style: TextStyle(
                            fontSize: smallScreen ? 11.sp : 12.sp,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Customer information section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Customer name row
                      if (model.userName != null && model.userName!.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 14.sp, color: Colors.blue[700]),
                            SizedBox(width: 4.w),
                            Text(
                              "${S.of(context).customer}: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: smallScreen ? 11.sp : 12.sp,
                                color: Colors.black87,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${model.userName}",
                                style: TextStyle(
                                  fontSize: smallScreen ? 11.sp : 12.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      if (model.userName != null && model.userName!.isNotEmpty)
                        SizedBox(height: 4.h),

                      // Phone number row
                      Row(
                        children: [
                          Icon(Icons.phone,
                              size: 14.sp, color: Colors.blue[700]),
                          SizedBox(width: 4.w),
                          Text(
                            "${S.of(context).phone}: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: smallScreen ? 11.sp : 12.sp,
                              color: Colors.black87,
                            ),
                          ),
                          Expanded(
                            child: isLoadingPhone
                                ? Row(
                                    children: [
                                      SizedBox(
                                        width: 12.sp,
                                        height: 12.sp,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.blue[400],
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        "Loading...",
                                        style: TextStyle(
                                          fontSize: smallScreen ? 11.sp : 12.sp,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                    ],
                                  )
                                : Text(
                                    userPhoneNumber ?? 'No phone number',
                                    style: TextStyle(
                                      fontSize: smallScreen ? 11.sp : 12.sp,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // User ID row
                      if (model.userId != null)
                        Row(
                          children: [
                            Icon(Icons.badge,
                                size: 14.sp, color: Colors.blue[700]),
                            SizedBox(width: 4.w),
                            Text(
                              "${S.of(context).user_id}: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: smallScreen ? 10.sp : 11.sp,
                                color: Colors.black87,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _truncateUserId(model.userId),
                                style: TextStyle(
                                  fontSize: smallScreen ? 10.sp : 11.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // Address & Payment info row
                LayoutBuilder(
                  builder: (context, constraints) {
                    return constraints.maxWidth < 400
                        ? Column(
                            children: [
                              _buildAddressBox(model, smallScreen),
                              SizedBox(height: 6.h),
                              _buildPaymentBox(model, smallScreen),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Address box
                              Expanded(
                                flex: 3,
                                child: _buildAddressBox(model, smallScreen),
                              ),
                              SizedBox(width: 6.w),
                              // Payment method box
                              Expanded(
                                flex: 2,
                                child: _buildPaymentBox(model, smallScreen),
                              ),
                            ],
                          );
                  },
                ),

                SizedBox(height: 8.h),

                // Order status dropdown
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(currentStatus).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: _getStatusColor(currentStatus),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(currentStatus),
                        color: _getStatusColor(currentStatus),
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "${S.of(context).status}:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: smallScreen ? 13.sp : 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currentStatus,
                            icon: Icon(Icons.arrow_drop_down, size: 18.sp),
                            elevation: 16,
                            style: TextStyle(
                              fontSize: smallScreen ? 13.sp : 14.sp,
                              color: _getStatusColor(currentStatus),
                              fontWeight: FontWeight.bold,
                            ),
                            isExpanded: false,
                            isDense: true,
                            onChanged: (String? newValue) {
                              if (newValue != null &&
                                  newValue != currentStatus) {
                                if (!mounted) return;
                                setState(() {
                                  currentStatus = newValue;
                                });
                                // Call the callback with orderId and new status
                                widget.onStatusChange(model.id, newValue);
                              }
                            },
                            dropdownColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.white,
                            items: statusOptions
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color:
                                        _getStatusColor(value).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getStatusIcon(value),
                                        color: _getStatusColor(value),
                                        size: 12.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        value,
                                        style: TextStyle(
                                          color: _getStatusColor(value),
                                          fontWeight: FontWeight.w600,
                                          fontSize: smallScreen ? 12.sp : 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 8.h),

                // Order items (expandable)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with expand button
                      InkWell(
                        onTap: () {
                          if (!mounted) return;
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shopping_bag,
                                size: 16.sp,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "${S.of(context).order_items} (${model.items.length})",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: smallScreen ? 13.sp : 14.sp,
                                ),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Show original price if discount available
                                  if (model.hasDiscount != null &&
                                      model.hasDiscount())
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "${model.getOriginalPrice().toStringAsFixed(2)} EGP",
                                          style: TextStyle(
                                            fontSize:
                                                smallScreen ? 11.sp : 12.sp,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          "-${model.promoDiscount!.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize:
                                                smallScreen ? 11.sp : 12.sp,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),

                                  // Payment reference for InstaPay
                                  if (model.paymentMethod == 'instapay' &&
                                      model.paymentReference != null &&
                                      model.paymentReference!.isNotEmpty)
                                    Text(
                                      "Ref: ${model.paymentReference!.length > 8 ? model.paymentReference!.substring(0, 8) + '...' : model.paymentReference}",
                                      style: TextStyle(
                                        fontSize: smallScreen ? 10.sp : 11.sp,
                                        color: Colors.blue.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),

                                  // Transaction ID for card payments
                                  if (model.paymentMethod == 'card' &&
                                      model.transactionId != null &&
                                      model.transactionId!.isNotEmpty)
                                    Text(
                                      "TX: ${model.transactionId!.length > 8 ? model.transactionId!.substring(0, 8) + '...' : model.transactionId}",
                                      style: TextStyle(
                                        fontSize: smallScreen ? 10.sp : 11.sp,
                                        color: Colors.green.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),

                                  // Final total after discount
                                  Text(
                                    "${S.of(context).total}: ${model.total.toStringAsFixed(2)} EGP",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: smallScreen ? 13.sp : 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey[700],
                                size: 18.sp,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Expandable item list
                      AnimatedCrossFade(
                        firstChild: const SizedBox(height: 0),
                        secondChild: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 250.h,
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.h),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Divider(height: 1),
                                  // Header row
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 6.h),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            S.of(context).item,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  smallScreen ? 11.sp : 12.sp,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: Text(
                                              S.of(context).qty,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    smallScreen ? 11.sp : 12.sp,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            S.of(context).item_price,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  smallScreen ? 11.sp : 12.sp,
                                              color: Colors.grey[800],
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Item rows
                                  ...List.generate(
                                    model.items.length,
                                    (index) {
                                      var item = model.items[index];
                                      String itemName = "";
                                      double itemPrice = 0.0;
                                      int quantity = 1;
                                      String? comment;

                                      if (item is Map) {
                                        itemName =
                                            item['name'] ?? 'Unknown item';
                                        var price = item['price'];
                                        if (price is int) {
                                          itemPrice = price.toDouble();
                                        } else if (price is double) {
                                          itemPrice = price;
                                        }
                                        quantity = item['quantity'] ?? 1;
                                        comment = item['comment'];
                                      } else if (item.name != null) {
                                        itemName = item.name;
                                        itemPrice = item.price;
                                        quantity = item.quantity ?? 1;
                                        comment = item.comment;
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4.h),
                                            decoration: BoxDecoration(
                                              border: index <
                                                      model.items.length - 1
                                                  ? Border(
                                                      bottom: BorderSide(
                                                        color:
                                                            Colors.grey[300]!,
                                                        width: 0.5,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    Directionality.of(
                                                                context) ==
                                                            TextDirection.rtl
                                                        ? (item is Map
                                                            ? item['nameAr'] ??
                                                                item['name']
                                                            : item.nameAr ??
                                                                item.name)
                                                        : (item is Map
                                                            ? item['name']
                                                            : item.name),
                                                    style: TextStyle(
                                                      fontSize: smallScreen
                                                          ? 11.sp
                                                          : 12.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Center(
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.w,
                                                              vertical: 1.h),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3.r),
                                                      ),
                                                      child: Text(
                                                        "x$quantity",
                                                        style: TextStyle(
                                                          fontSize: smallScreen
                                                              ? 10.sp
                                                              : 11.sp,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "${itemPrice.toStringAsFixed(2)} ${S.of(context).egp}",
                                                    style: TextStyle(
                                                      fontSize: smallScreen
                                                          ? 10.sp
                                                          : 11.sp,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Display comment if available
                                          if (comment != null &&
                                              comment.isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 8.w,
                                                  right: 8.w,
                                                  bottom: 6.h),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.comment,
                                                      size: 12.sp,
                                                      color: Colors.blue[700]),
                                                  SizedBox(width: 4.w),
                                                  Expanded(
                                                    child: Text(
                                                      comment,
                                                      style: TextStyle(
                                                        fontSize: smallScreen
                                                            ? 9.sp
                                                            : 10.sp,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        color: Colors.grey[800],
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                  SizedBox(height: 6.h),
                                  // Delivery fee and total
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          // Items subtotal
                                          Text(
                                            "${S.of(context).items}: 100.00 ${S.of(context).egp}",
                                            style: TextStyle(
                                              fontSize:
                                                  smallScreen ? 10.sp : 11.sp,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          // Delivery fee
                                          Text(
                                            "${S.of(context).delivery_fee}: 30.00 ${S.of(context).egp}",
                                            style: TextStyle(
                                              fontSize:
                                                  smallScreen ? 10.sp : 11.sp,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6.w, vertical: 3.h),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius:
                                                  BorderRadius.circular(3.r),
                                              border: Border.all(
                                                  color: Colors.green[300]!),
                                            ),
                                            child: Text(
                                              "${S.of(context).total}: 130.00 ${S.of(context).egp}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    smallScreen ? 11.sp : 12.sp,
                                                color: Colors.green[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
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

  String _truncateId(String id) {
    if (id.length > 8) {
      return "${id.substring(0, 8)}...";
    }
    return id;
  }

  String _truncateUserId(String userId) {
    if (userId.length > 16) {
      return "${userId.substring(0, 16)}...";
    }
    return userId;
  }

  Widget _buildAddressBox(dynamic model, bool smallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 14.sp, color: Colors.red),
              SizedBox(width: 3.w),
              Text(
                S.of(context).delivery_address,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: smallScreen ? 11.sp : 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          if (model.address != null) ...[
            if (model.address['title'] != null)
              Text(
                "${model.address['title']}",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: smallScreen ? 11.sp : 12.sp,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            SizedBox(height: 2.h),
            Text(
              model.address['address'] ?? 'No address',
              style: TextStyle(
                fontSize: smallScreen ? 10.sp : 11.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ] else
            Text(
              S.of(context).no_address_provided,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: smallScreen ? 10.sp : 11.sp,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentBox(dynamic model, bool smallScreen) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                model.paymentMethod?.toLowerCase() == 'cash'
                    ? Icons.money
                    : model.paymentMethod?.toLowerCase() == 'card'
                        ? Icons.credit_card
                        : model.paymentMethod?.toLowerCase() == 'instapay'
                            ? Icons.mobile_friendly
                            : Icons.payment,
                size: 14.sp,
                color: Colors.green[700],
              ),
              SizedBox(width: 3.w),
              Text(
                S.of(context).payment,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: smallScreen ? 11.sp : 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            model.paymentMethod != null
                ? model.paymentMethod!.toUpperCase()
                : "Unknown",
            style: TextStyle(
              fontSize: smallScreen ? 11.sp : 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        // Use brown for both dark and light mode for other statuses
        return isDarkMode ? AppColors.darkText : Colors.black;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.refresh;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
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

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTimeShort(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }
}
