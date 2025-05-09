import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/models/user.dart';
import 'package:foodapp/screens/oredrs/cubit.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/screens/profile/states.dart';
import 'package:foodapp/shared/paymob_service.dart';
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
  final instapayPhoneNumber = "01226680469"; // Store phone number for Instapay
  bool paymentVerified = false;

  @override
  void initState() {
    super.initState();
    // Load default address if available
    _loadDefaultAddress();
  }

  void _loadDefaultAddress() {
    final profileCubit = ProfileCubit.get(context);
    if (profileCubit.user.addresses.isNotEmpty) {
      // Try to find default address
      final defaultAddress = profileCubit.user.addresses.firstWhere(
          (address) => address.isDefault,
          orElse: () => profileCubit.user.addresses.first);
      setState(() {
        selectedAddress = defaultAddress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final layoutCubit = Layoutcubit.get(context);
    final cartItems = layoutCubit.cartitems;

    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  controlsBuilder: (context, details) {
                    return Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: details.onStepCancel,
                              child: Text('Back'),
                            ),
                          ),
                        if (_currentStep > 0) SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: Text(
                                _currentStep == 1 ? 'Place Order' : 'Next'),
                          ),
                        ),
                      ],
                    );
                  },
                  onStepContinue: () {
                    if (_currentStep == 0) {
                      if (selectedAddress == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select an address')),
                        );
                        return;
                      }
                      setState(() {
                        _currentStep = 1;
                      });
                    } else if (_currentStep == 1) {
                      if (paymentMethod == 'instapay') {
                        if (transferReferenceController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Please enter the transfer reference number')),
                          );
                          return;
                        }
                      }

                      // Process the order
                      _processOrder(context);
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep--;
                      });
                    }
                  },
                  steps: [
                    Step(
                      title: Text('Address'),
                      content: _buildAddressStep(),
                      isActive: _currentStep >= 0,
                    ),
                    Step(
                      title: Text('Payment'),
                      content: _buildPaymentStep(),
                      isActive: _currentStep >= 1,
                    ),
                  ],
                ),
              ),

              // Order Summary Section
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Items (${cartItems.length})'),
                        Text(
                            '${layoutCubit.calculateTotalPrice().toStringAsFixed(2)} EGP'),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Fee'),
                        Text('30.00 EGP'),
                      ],
                    ),
                    Divider(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(layoutCubit.calculateTotalPrice() + 30).toStringAsFixed(2)} EGP',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressStep() {
    final profileCubit = ProfileCubit.get(context);
    final addresses = profileCubit.user.addresses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address Selection
        addresses.isEmpty
            ? Center(
                child: Column(
                  children: [
                    Icon(Icons.location_off, size: 60, color: Colors.grey),
                    SizedBox(height: 16.h),
                    Text('No saved addresses found'),
                    SizedBox(height: 10.h),
                    ElevatedButton(
                      onPressed: () => _showAddAddressBottomSheet(context),
                      child: Text('Add New Address'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  ...addresses.map((address) {
                    final isSelected = selectedAddress == address;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedAddress = address;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Radio<Address>(
                              value: address,
                              groupValue: selectedAddress,
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
                                      Text(
                                        address.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
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
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    address.address,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddAddressBottomSheet(context),
                      icon: Icon(Icons.add),
                      label: Text('Add New Address'),
                    ),
                  ),
                ],
              ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),

        // Cash on delivery payment method
        _buildPaymentMethodCard(
          title: 'Cash on Delivery',
          subtitle: 'Pay when your order is delivered',
          icon: Icons.payments_outlined,
          value: 'cash',
        ),

        // Credit card payment method
        _buildPaymentMethodCard(
          title: 'Credit / Debit Card',
          subtitle: 'Pay now with your card',
          icon: Icons.credit_card,
          value: 'card',
        ),

        // InstaPay payment method
        _buildPaymentMethodCard(
          title: 'InstaPay',
          subtitle: 'Transfer to our InstaPay account',
          icon: Icons.mobile_friendly,
          value: 'instapay',
        ),

        // Display transfer information if InstaPay is selected
        if (paymentMethod == 'instapay') _buildInstapayInfo(),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          paymentMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: paymentMethod == value
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: paymentMethod == value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: paymentMethod,
              onChanged: (value) {
                setState(() {
                  paymentMethod = value ?? 'cash';
                });
              },
            ),
            SizedBox(width: 8.w),
            Icon(icon),
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
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstapayInfo() {
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'InstaPay Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14.sp,
              ),
              children: [
                TextSpan(text: "1. Open your Instapay app\n"),
                TextSpan(text: "2. Send payment to: "),
                TextSpan(
                  text: instapayPhoneNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                TextSpan(text: "\n3. Enter the amount: EGP "),
                TextSpan(
                  text:
                      "${(Layoutcubit.get(context).calculateTotalPrice() + 30).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                TextSpan(
                    text:
                        "\n4. Complete the transfer and enter the reference number below"),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: instapayPhoneNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Phone number copied to clipboard')),
              );
            },
            icon: Icon(Icons.copy),
            label: Text("Copy Phone Number"),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: transferReferenceController,
            decoration: InputDecoration(
              labelText: 'Transfer Reference Number',
              hintText:
                  'Enter the reference number from your Instapay transfer',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
            ),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _verifyPayment(context);
              },
              icon: Icon(Icons.check_circle),
              label: Text("Verify Payment"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (paymentVerified) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "Payment verified successfully! You can now place your order.",
                      style: TextStyle(color: Colors.green.shade800),
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
              "Add New Address",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Address Title (e.g. Home, Work)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: "Full Address",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 12.h),
            StatefulBuilder(
              builder: (context, setState) => CheckboxListTile(
                title: Text("Set as default address"),
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
                      SnackBar(content: Text("Please fill all fields")),
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
                child: Text("Save Address"),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _verifyPayment(BuildContext context) {
    if (transferReferenceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the transfer reference number')),
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
              CircularProgressIndicator(),
              SizedBox(height: 16.h),
              Text("Verifying payment..."),
            ],
          ),
        );
      },
    );

    // Simulate payment verification with a delay
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Close the loading dialog

      // For demo purposes, consider all payments valid if reference number is provided
      setState(() {
        paymentVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _processOrder(BuildContext context) async {
    final layoutCubit = Layoutcubit.get(context);
    final orderCubit = OrderCubit.get(context);
    final profileCubit = ProfileCubit.get(context);

    // Check if user has a phone number
    if (profileCubit.user.phone.isEmpty) {
      // Show phone number collection dialog
      final phoneAdded = await _showAddPhoneNumberDialog(context);
      if (!phoneAdded) {
        return; // User cancelled adding phone number
      }
    }

    // Verify that an address is selected
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // For InstaPay payment, verify that reference has been entered and verified
    if (paymentMethod == 'instapay' && !paymentVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please verify your InstaPay payment first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // If credit card payment is selected, process with PayMob
    if (paymentMethod == 'card') {
      final totalPrice =
          layoutCubit.calculateTotalPrice() + 30; // Including delivery fee

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        // Process payment with PayMob
        final paymentResult = await PayMobService.processCardPayment(
          context: context,
          amount: totalPrice,
          currency: "EGP", // Default to Egyptian Pound
        );

        // Close loading indicator
        Navigator.of(context, rootNavigator: true).pop();

        if (paymentResult['success'] == true) {
          // Payment succeeded
          setState(() {
            paymentVerified = true;
          });

          // Complete the order placement
          await _completeOrderPlacement(context);
        } else {
          // Payment failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(paymentResult['message'] ??
                  'Payment failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } catch (e) {
        // Close loading indicator
        Navigator.of(context, rootNavigator: true).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      return; // Return after handling card payment
    }

    // Only proceed with order placement for non-card payments
    await _completeOrderPlacement(context);
  }

  // Dialog to collect phone number from users who don't have one (typically Google sign-in users)
  Future<bool> _showAddPhoneNumberDialog(BuildContext context) async {
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Primary color for styling (matching login/signup screens)
    const primaryColor = Color(0xFFFF5722);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(
              "Phone Number Required",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Please add your phone number to continue with checkout.",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: phoneController,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "Enter your 11-digit phone number",
                      labelStyle: TextStyle(color: primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: primaryColor, width: 2.0),
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode ? Colors.black : Colors.grey.shade50,
                      prefixIcon: Icon(Icons.phone, color: primaryColor),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Phone number is required";
                      }
                      if (value.length != 11) {
                        return "Please enter a valid 11-digit phone number";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final profileCubit = ProfileCubit.get(context);

                    // Update the phone number in the user model and Firestore
                    await profileCubit.updateUserPhone(phoneController.text);

                    Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _completeOrderPlacement(BuildContext context) async {
    final layoutCubit = Layoutcubit.get(context);
    final orderCubit = OrderCubit.get(context);
    final profileCubit = ProfileCubit.get(context);

    // Verify that an address is selected
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Generate a unique order ID
    final orderId = Uuid().v4();

    // Calculate the total price (items + delivery fee)
    final totalPrice =
        layoutCubit.calculateTotalPrice() + 30; // Including delivery fee

    // Create order data
    final orderData = {
      'id': orderId,
      'userId': profileCubit.user.uid,
      'userName': profileCubit.user.name, // Add the user's name
      'items': layoutCubit.cartitems.map((item) => item.toJson()).toList(),
      'total': totalPrice,
      'address': selectedAddress!.toJson(),
      'paymentMethod': paymentMethod,
      'paymentReference':
          paymentMethod == 'instapay' ? transferReferenceController.text : null,
      'status': 'Pending', // Ensure status is set to Pending
      'date': DateTime.now().toString(),
    };

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Add the order through the order cubit (which will handle adding to global orders collection)
      await orderCubit.addOrder(orderData);

      // Also update the user's orderIds list in memory
      if (!profileCubit.user.orderIds.contains(orderId)) {
        profileCubit.user.orderIds.add(orderId);
      }

      // Clear the cart
      layoutCubit.clearCart();

      // Reset payment verification status
      setState(() {
        paymentVerified = false;
        transferReferenceController.clear();
      });

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully!'),
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
          content: Text('Error placing order: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
