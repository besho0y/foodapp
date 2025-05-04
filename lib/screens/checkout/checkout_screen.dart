import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/models/user.dart';
import 'package:foodapp/screens/oredrs/cubit.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/screens/profile/states.dart';
import 'package:foodapp/shared/local_storage.dart';
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
  final cardNumberController = TextEditingController();
  final cardHolderController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();
  bool saveCardDetails = false;

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
                      if (paymentMethod == 'visa') {
                        if (cardNumberController.text.isEmpty ||
                            cardHolderController.text.isEmpty ||
                            expiryDateController.text.isEmpty ||
                            cvvController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Please fill all card details')),
                          );
                          return;
                        }

                        // Save card details if requested
                        if (saveCardDetails) {
                          _saveCardDetails();
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
          'Payment Method',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        _buildPaymentMethodTile(
          title: 'Cash on Delivery',
          subtitle: 'Pay when you receive your order',
          icon: Icons.money,
          value: 'cash',
        ),
        SizedBox(height: 10.h),
        _buildPaymentMethodTile(
          title: 'Credit/Debit Card',
          subtitle: 'Pay now with your card',
          icon: Icons.credit_card,
          value: 'visa',
        ),
        SizedBox(height: 16.h),

        // Show card details form if card is selected
        if (paymentMethod == 'visa') ...[
          Text(
            'Card Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: cardHolderController,
            decoration: InputDecoration(
              labelText: 'Card Holder Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: expiryDateController,
                  decoration: InputDecoration(
                    labelText: 'Expiry Date (MM/YY)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 3,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          CheckboxListTile(
            title: Text('Save card for future payments'),
            value: saveCardDetails,
            onChanged: (value) {
              setState(() {
                saveCardDetails = value ?? false;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],

        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildPaymentMethodTile({
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

  void _saveCardDetails() {
    // Save card details to local storage
    final cardDetails = {
      'cardNumber': cardNumberController.text,
      'cardHolder': cardHolderController.text,
      'expiryDate': expiryDateController.text,
      // Don't save CVV for security reasons
    };

    LocalStorageService.savePaymentMethod(cardDetails);
  }

  void _processOrder(BuildContext context) async {
    final layoutCubit = Layoutcubit.get(context);
    final orderCubit = OrderCubit.get(context);
    final profileCubit = ProfileCubit.get(context);

    // First check if we have items in the cart
    if (layoutCubit.cartitems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your cart is empty!'),
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
