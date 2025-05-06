import 'package:flutter/material.dart';
import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_paytabs_bridge/flutter_paytabs_bridge.dart';

class PayTabsService {
  // PayTabs credentials - Replace with your actual credentials
  static const String _merchantId =
      "MERCHANT_ID"; // Replace with your merchant ID
  static const String _serverKey = "SERVER_KEY"; // Replace with your server key
  static const String _clientKey = "CLIENT_KEY"; // Replace with your client key

  // Process payment with PayTabs
  static Future<bool> processPayment({
    required BuildContext context,
    required double amount,
    required String customerEmail,
    required String customerName,
    required String customerPhone,
    required String address,
    required String city,
    required String countryCode,
  }) async {
    try {
      // Create billing details
      final billingDetails = BillingDetails(
        customerName,
        customerEmail,
        customerPhone,
        address,
        countryCode,
        city,
        "NA", // state
        "00000", // zip code
      );

      // Create shipping details (same as billing in this case)
      final shippingDetails = ShippingDetails(
        customerName,
        customerEmail,
        customerPhone,
        address,
        countryCode,
        city,
        "NA", // state
        "00000", // zip code
      );

      // Create PayTabs configuration
      final configuration = PaymentSdkConfigurationDetails(
        profileId: _merchantId,
        serverKey: _serverKey,
        clientKey: _clientKey,
        cartId: DateTime.now().millisecondsSinceEpoch.toString(),
        cartDescription: "Food app order payment",
        merchantName: "Food App",
        screentTitle: "Pay with Card",
        billingDetails: billingDetails,
        shippingDetails: shippingDetails,
        amount: amount,
        currencyCode: "EGP", // Change as needed for your country
        merchantCountryCode: "EG", // Change as needed for your country
        hideCardScanner: false,
        showBillingInfo: true,
      );

      // Start the payment
      var result =
          await FlutterPaytabsBridge.startCardPayment(configuration, (event) {
        // This is a callback that gets called during payment processing
        // We handle the final result below, so we don't need to do anything here
      });

      if (result["status"] == "success") {
        // Payment was successful
        return true;
      } else if (result["status"] == "error") {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? "Payment failed"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      } else if (result["status"] == "event") {
        // Handle events
        print("PayTabs Event: ${result["event"]}");
        return false;
      } else {
        // Handle cancellation or other states
        return false;
      }
    } catch (e) {
      // Handle exceptions
      print("Payment error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
