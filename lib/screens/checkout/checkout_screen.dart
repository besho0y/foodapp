import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/models/user.dart';
import 'package:foodapp/screens/oredrs/cubit.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/screens/profile/states.dart';
import 'package:uuid/uuid.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  Address? selectedAddress;
  String paymentMethod = 'cash'; // Default payment method
  final transferReferenceController = TextEditingController();
  final instapayPhoneNumber = "01111350143"; // Store phone number for Instapay
  bool paymentVerified = false;

  // Add promocode controllers and variables
  final TextEditingController _promocodeController = TextEditingController();
  String? _appliedPromocode;
  double _promoDiscount = 0.0;
  bool _isPromoLoading = false;

  @override
  void initState() {
    super.initState();
    // Load default address if available
    _loadDefaultAddress();
  }

  @override
  void dispose() {
    transferReferenceController.dispose();
    _promocodeController.dispose();
    super.dispose();
  }

  void _loadDefaultAddress() {
    final profileCubit = ProfileCubit.get(context);
    if (profileCubit.user.addresses.isNotEmpty) {
      // Try to find default address
      final defaultAddress = profileCubit.user.addresses.firstWhere(
          (address) => address.isDefault,
          orElse: () => profileCubit.user.addresses.first);
      if (mounted) {
        setState(() {
          selectedAddress = defaultAddress;
        });
      }
    }
  }

  // Add method to validate promocode
  Future<void> _validatePromocode() async {
    final String code = _promocodeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a promocode')),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isPromoLoading = true;
      });
    }

    try {
      // Check if the code exists in Firestore
      final promoDoc = await FirebaseFirestore.instance
          .collection('promocodes')
          .doc(code)
          .get();

      // Check if this user has already used this promocode
      final profileCubit = ProfileCubit.get(context);
      final bool hasUsedPromo = profileCubit.hasUsedPromocode(code);

      if (!mounted) return; // Early return if widget is disposed

      if (!promoDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid promocode')),
        );
        if (mounted) {
          setState(() {
            _isPromoLoading = false;
            _appliedPromocode = null;
            _promoDiscount = 0.0;
          });
        }
      } else if (hasUsedPromo) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already used this promocode')),
        );
        if (mounted) {
          setState(() {
            _isPromoLoading = false;
            _appliedPromocode = null;
            _promoDiscount = 0.0;
          });
        }
      } else {
        // Promocode is valid and hasn't been used by this user
        final promoData = promoDoc.data() as Map<String, dynamic>;
        final double discount = (promoData['discount'] ?? 0).toDouble();

        if (mounted) {
          setState(() {
            _isPromoLoading = false;
            _appliedPromocode = code;
            _promoDiscount = discount;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Promocode applied! ${discount.toStringAsFixed(2)} EGP discount'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error validating promocode: $e');
      if (!mounted) return; // Early return if widget is disposed

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error checking promocode')),
      );
      if (mounted) {
        setState(() {
          _isPromoLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final layoutCubit = Layoutcubit.get(context);
    final cartItems = layoutCubit.cartitems;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).checkout),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Add resizeToAvoidBottomInset to handle keyboard properly
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Custom stepper header (only the header part)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Row(
                    children: [
                      // Step 1
                      Expanded(
                        child: Column(
                          children: [
                            // Number indicator
                            Container(
                              width: 30.r,
                              height: 30.r,
                              decoration: BoxDecoration(
                                color: _currentStep >= 0
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: _currentStep > 0
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18.sp,
                                      )
                                    : Text(
                                        "1",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 5.h),
                            // Step title
                            Text(
                              S.of(context).select_delivery_address,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: _currentStep >= 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _currentStep >= 0
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Divider line
                      Container(
                        width: 30.w,
                        height: 2.h,
                        color: _currentStep > 0
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                        margin: EdgeInsets.symmetric(horizontal: 5.w),
                      ),
                      // Step 2
                      Expanded(
                        child: Column(
                          children: [
                            // Number indicator
                            Container(
                              width: 30.r,
                              height: 30.r,
                              decoration: BoxDecoration(
                                color: _currentStep >= 1
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: _currentStep > 1
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 18.sp,
                                      )
                                    : Text(
                                        "2",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 5.h),
                            // Step title
                            Text(
                              S.of(context).select_payment_method,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: _currentStep >= 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _currentStep >= 1
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

                // Content area (in an Expanded to take available space)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: _currentStep == 0
                          ? _buildAddressStep()
                          : _buildPaymentStep(),
                    ),
                  ),
                ),

                // Divider before buttons
                Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

                // Buttons
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              if (!mounted) return;
                              setState(() {
                                _currentStep--;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(S.of(context).back,
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      if (_currentStep > 0) SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentStep == 0) {
                              if (selectedAddress == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          S.of(context).select_address_error)),
                                );
                                return;
                              }
                              if (!mounted) return;
                              setState(() {
                                _currentStep = 1;
                              });
                            } else if (_currentStep == 1) {
                              if (paymentMethod == 'instapay') {
                                if (transferReferenceController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                      S.of(context).enter_reference_number,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    )),
                                  );
                                  return;
                                }
                              }

                              // Process the order
                              _processOrder(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(_currentStep == 1
                              ? S.of(context).place_order
                              : S.of(context).next),
                        ),
                      ),
                    ],
                  ),
                ),

                // Order Summary Section
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  // Wrap in SingleChildScrollView to handle keyboard overlap
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Order summary header with styled text
                        Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            S.of(context).order_summary,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),

                        // Items and subtotal
                        _buildSummaryRow(
                          label: '${S.of(context).items} (${cartItems.length})',
                          value:
                              '${layoutCubit.calculateSubtotal().toStringAsFixed(2)} ${S.of(context).egp}',
                        ),

                        // Delivery fee section
                        Builder(
                          builder: (context) {
                            // Calculate total delivery fees
                            double totalDeliveryFee = 0.0;
                            // Group by restaurant to avoid duplicates
                            final restaurantGroups =
                                groupItemsByRestaurant(cartItems);
                            // Add one delivery fee per restaurant
                            restaurantGroups.forEach((_, items) {
                              try {
                                double fee =
                                    double.parse(items.first.deliveryFee);
                                totalDeliveryFee += fee;
                              } catch (e) {
                                print('Error parsing fee: $e');
                              }
                            });

                            return _buildSummaryRow(
                              label: restaurantGroups.length > 1
                                  ? '${S.of(context).delivery_fee} (${restaurantGroups.length})'
                                  : S.of(context).delivery_fee,
                              value:
                                  '${totalDeliveryFee.toStringAsFixed(2)} ${S.of(context).egp}',
                            );
                          },
                        ),

                        // Show discount amount if promocode is applied
                        if (_appliedPromocode != null && _promoDiscount > 0)
                          _buildSummaryRow(
                            label: 'Discount',
                            value:
                                '-${_promoDiscount.toStringAsFixed(2)} ${S.of(context).egp}',
                            valueColor: Colors.green,
                          ),

                        // Divider before total
                        Divider(height: 16.h, thickness: 1),

                        // Total row with larger text and bold styling
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).total,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              '${layoutCubit.calculateTotalPrice(promoDiscount: _promoDiscount).toStringAsFixed(2)} ${S.of(context).egp}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _completeOrderPlacement(BuildContext context) async {
    final layoutCubit = Layoutcubit.get(context);
    final orderCubit = OrderCubit.get(context);
    final profileCubit = ProfileCubit.get(context);

    // Verify that an address is selected
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).select_address_error),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Generate a unique order ID
    final orderId = const Uuid().v4();

    // Calculate the total price (items + delivery fee) with promocode discount if applied
    final totalPrice =
        layoutCubit.calculateTotalPrice(promoDiscount: _promoDiscount);

    // Create order data
    final orderData = {
      'id': orderId,
      'userId': profileCubit.user.uid,
      'userName': profileCubit.user.name,
      'items': layoutCubit.cartitems.map((item) => item.toJson()).toList(),
      'total': totalPrice,
      'address': selectedAddress!.toJson(),
      'paymentMethod': paymentMethod,
      'paymentReference':
          paymentMethod == 'instapay' ? transferReferenceController.text : null,
      'status': 'Pending',
      'date': DateTime.now().toString(),
      // Include promocode information if a promocode was applied
      'promocode': _appliedPromocode,
      'promoDiscount': _promoDiscount > 0 ? _promoDiscount : null,
    };

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Add the order through the order cubit
      await orderCubit.addOrder(orderData);

      // If a promocode was applied, add it to the user's used promocodes
      if (_appliedPromocode != null && _promoDiscount > 0) {
        await profileCubit.addUsedPromocode(_appliedPromocode!);
      }

      // Update the user's orderIds list in memory
      if (!profileCubit.user.orderIds.contains(orderId)) {
        profileCubit.user.orderIds.add(orderId);
      }

      // Clear the cart
      layoutCubit.clearCart();

      // Reset payment verification status and promocode
      setState(() {
        paymentVerified = false;
        transferReferenceController.clear();
        _appliedPromocode = null;
        _promoDiscount = 0.0;
        _promocodeController.clear();
      });

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).order_placed),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the orders tab of the bottom navbar
      layoutCubit.changenavbar(2); // Index 2 is the Orders tab
      Navigator.pop(context);
    } catch (error) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${S.of(context).order_error}: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper widget for consistent summary rows with overflow protection
  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  // Added missing method - Group items by restaurant
  Map<String, List<CartItem>> groupItemsByRestaurant(List<CartItem> items) {
    // Group items by restaurant ID to avoid duplicate fees
    Map<String, List<CartItem>> restaurantGroups = {};

    for (var item in items) {
      if (!restaurantGroups.containsKey(item.restaurantId)) {
        restaurantGroups[item.restaurantId] = [];
      }
      restaurantGroups[item.restaurantId]!.add(item);
    }

    return restaurantGroups;
  }

  // Added missing method - Build address step UI
  Widget _buildAddressStep() {
    final profileCubit = ProfileCubit.get(context);
    final addresses = profileCubit.user.addresses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Promocode section
        Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: _appliedPromocode != null
                  ? Colors.green
                  : Colors.grey.shade300,
              width: _appliedPromocode != null ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promocode header
              Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 16.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Promocode',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Promocode input and button - Fixed to prevent overflow
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: _appliedPromocode != null
                              ? Colors.green
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: TextField(
                        controller: _promocodeController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Enter promocode',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10.w),
                          border: InputBorder.none,
                          enabled: _appliedPromocode == null,
                          hintStyle: TextStyle(fontSize: 13.sp),
                        ),
                        style: TextStyle(fontSize: 13.sp),
                        onSubmitted: (_) {
                          if (_appliedPromocode == null) {
                            _validatePromocode();
                          }
                          // Dismiss keyboard
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _isPromoLoading
                      ? Container(
                          width: 40.w,
                          height: 40.h,
                          padding: EdgeInsets.all(6.r),
                          child:
                              const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : _appliedPromocode != null
                          ? Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 40.h,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _appliedPromocode = null;
                                      _promoDiscount = 0.0;
                                      _promocodeController.clear();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Remove',
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 40.h,
                                child: ElevatedButton(
                                  onPressed: _validatePromocode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Apply',
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                ],
              ),

              // Show applied promocode message
              if (_appliedPromocode != null) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 14),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          'Code "$_appliedPromocode" applied!',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.green.shade800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Address Selection
        addresses.isEmpty
            ? Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 60.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No saved addresses found',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddAddressBottomSheet(context),
                        icon: const Icon(Icons.add_location_alt),
                        label: Text(S.of(context).add_address),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  ...addresses.map((address) {
                    final isSelected = selectedAddress == address;
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      elevation: isSelected ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedAddress = address;
                          });
                        },
                        borderRadius: BorderRadius.circular(10.r),
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Radio<Address>(
                                value: address,
                                groupValue: selectedAddress,
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    selectedAddress = value;
                                  });
                                },
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            address.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.sp,
                                              color: isSelected
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        if (address.isDefault)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 2.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            child: Text(
                                              'Default',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      address.address,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 16.h),
                  // Add new address button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddAddressBottomSheet(context),
                      icon: const Icon(
                        Icons.add_location_alt,
                        color: Colors.white,
                      ),
                      label: Text(S.of(context).add_address,
                          style: const TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        SizedBox(height: 16.h),
      ],
    );
  }

  // Added missing method - Build payment step UI
  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).select_payment_method,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 16.h),

        // Cash on delivery payment method
        _buildPaymentMethodCard(
          title: S.of(context).cash_on_delivery,
          subtitle: S.of(context).cash_on_delivery_subtitle,
          icon: Icons.payments_outlined,
          value: 'cash',
        ),
        SizedBox(height: 12.h),

        // Credit card payment method
        _buildPaymentMethodCard(
          title: S.of(context).credit_card,
          subtitle: S.of(context).credit_card_subtitle,
          icon: Icons.credit_card,
          value: 'card',
        ),
        SizedBox(height: 12.h),

        // InstaPay payment method
        _buildPaymentMethodCard(
          title: S.of(context).instapay,
          subtitle: S.of(context).instapay_subtitle,
          icon: Icons.mobile_friendly,
          value: 'instapay',
        ),

        // Display transfer information if InstaPay is selected
        if (paymentMethod == 'instapay') _buildInstapayInfo(),
      ],
    );
  }

  // Added missing method - Build payment method card
  Widget _buildPaymentMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    bool isSelected = paymentMethod == value;

    return Card(
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            paymentMethod = value;
          });
        },
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: paymentMethod,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value ?? 'cash';
                  });
                },
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade700,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color:
                            isSelected ? Theme.of(context).primaryColor : null,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Added missing method - Build Instapay information section
  Widget _buildInstapayInfo() {
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade700,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  S.of(context).instapay_details,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Instapay steps with nice formatting
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInstapayStep(
                    step: '1', text: S.of(context).instapay_step1),
                _buildInstapayStep(
                  step: '2',
                  text: "${S.of(context).instapay_step2} ",
                  highlight: instapayPhoneNumber,
                ),
                _buildInstapayStep(
                  step: '3',
                  text: "${S.of(context).instapay_step3} ",
                  highlight:
                      "${(Layoutcubit.get(context).calculateTotalPrice(promoDiscount: _promoDiscount)).toStringAsFixed(2)} ${S.of(context).egp}",
                ),
                _buildInstapayStep(
                  step: '4',
                  text: S.of(context).instapay_step4,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Copy phone number button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: instapayPhoneNumber));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).copy_phone_number),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: Text(S.of(context).copy_phone_number),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: BorderSide(color: Colors.blue.shade700),
                foregroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Reference input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: paymentVerified ? Colors.green : Colors.grey.shade300,
                width: paymentVerified ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: transferReferenceController,
              decoration: InputDecoration(
                labelText: S.of(context).transfer_reference,
                hintText: S.of(context).transfer_reference_hint,
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.numbers),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                labelStyle: TextStyle(
                  color: paymentVerified ? Colors.green : null,
                ),
              ),
              keyboardType: TextInputType.text,
            ),
          ),

          SizedBox(height: 16.h),

          // Verify payment button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _verifyPayment(context);
              },
              icon: const Icon(Icons.check_circle),
              label: Text(S.of(context).verify_payment),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    paymentVerified ? Colors.green : Colors.blue.shade700,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),

          // Payment verified message
          if (paymentVerified) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      S.of(context).payment_verified,
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Added missing method - Build Instapay step
  Widget _buildInstapayStep({
    required String step,
    required String text,
    String? highlight,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.r,
            height: 24.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: highlight == null
                ? Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  )
                : RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.sp,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: text),
                        TextSpan(
                          text: highlight,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }

  // Added missing method - Show Add Address Bottom Sheet
  void _showAddAddressBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final addressController = TextEditingController();
    bool isDefault = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20.w,
          right: 20.w,
          top: 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).add_address,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: S.of(context).AddressTitle,
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: S.of(context).FullAddress,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 12.h),
            StatefulBuilder(
              builder: (context, setState) => CheckboxListTile(
                title: Text(S.of(context).Setdefaultaddress),
                value: isDefault,
                onChanged: (value) {
                  setState(() {
                    isDefault = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty ||
                      addressController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context).Pleasefill)),
                    );
                    return;
                  }

                  final address = Address(
                    title: titleController.text.trim(),
                    address: addressController.text.trim(),
                    isDefault: isDefault,
                  );

                  ProfileCubit.get(context).addAddress(address);

                  // Also select this address for the current order
                  setState(() {
                    selectedAddress = address;
                  });

                  Navigator.pop(context);
                },
                child: Text(S.of(context).SaveAddress),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // Added missing method - Verify Payment
  void _verifyPayment(BuildContext context) {
    if (transferReferenceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).enter_reference_number)),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.h),
              Text(S.of(context).verifying_payment),
            ],
          ),
        );
      },
    );

    // Simulate payment verification with a delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close the loading dialog

      // For demo purposes, consider all payments valid if reference number is provided
      setState(() {
        paymentVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).payment_verified),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  // Added missing method - Process Order
  void _processOrder(BuildContext context) async {
    final layoutCubit = Layoutcubit.get(context);
    final orderCubit = OrderCubit.get(context);
    final profileCubit = ProfileCubit.get(context);

    // Verify that an address is selected
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).select_address_error),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // For InstaPay payment, verify that reference has been entered and verified
    if (paymentMethod == 'instapay' && !paymentVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).payment_verification_failed),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Complete the order placement
    await _completeOrderPlacement(context);
  }
}
