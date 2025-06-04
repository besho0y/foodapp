import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_paymob/flutter_paymob.dart';

class PayMobService {
  // Initialize the PayMob service
  static void initialize() {
    try {
      print("🔧 Initializing PayMob...");

      FlutterPaymob.instance.initialize(
        // TODO: IMPORTANT - Before going live:
        // 1. Replace this test API key with your production API key from PayMob dashboard
        // 2. The production API key will start with "ZXlKaGJHY..." but will be different from this test key
        apiKey:
            "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBME5ETTROQ3dpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS4xb0oyWGdtNWx1ZDN1clVRTEVSbUtCLUdWSVdsaFB4bm5qTVFtSk91NWdMRHkxM1VoMTNZanF3Nzh5QnJueHB4eGd5bEJMZ2JmVUUxUFFuYUgxMXRuQQ==",

        // TODO: Replace with your production card integration ID
        integrationID: 5090038,

        // TODO: Replace with your production iFrame ID
        iFrameID: 922286,

        // Note: This is set to 0 since we don't use wallet payments.
        // The package requires this parameter but we only process card payments.
        walletIntegrationId: 0,
      );
      print("✅ PayMob initialized successfully");
    } catch (e) {
      print("❌ Error initializing PayMob: $e");
    }
  }

  // Process payment with card
  static Future<Map<String, dynamic>> processCardPayment({
    required BuildContext context,
    required double amount,
    String? currency,
  }) async {
    print("💳 === Starting PayMob Card Payment ===");

    // Validate inputs with null safety
    final safeCurrency = currency ?? "EGP";

    // Validate amount
    if (amount <= 0) {
      print("❌ Invalid amount: $amount");
      return _createErrorResponse("Invalid payment amount: $amount");
    }

    print("💰 Amount: $amount $safeCurrency");

    // Initialize result with safe defaults
    Map<String, dynamic> paymentResult =
        _createErrorResponse("Payment not started");

    try {
      print("🚀 Calling PayMob payment interface...");

      // Use timeout to prevent hanging
      await Future.any([
        FlutterPaymob.instance.payWithCard(
          context: context,
          currency: safeCurrency,
          amount: amount,
          onPayment: (response) =>
              _handlePaymentResponse(response, paymentResult),
        ),
        Future.delayed(
            const Duration(minutes: 5),
            () => throw TimeoutException(
                "Payment timeout", const Duration(minutes: 5))),
      ]);

      print("✅ PayMob payment interface completed");
    } on TimeoutException catch (e) {
      print("⏰ PayMob payment timeout: $e");
      return _createErrorResponse("Payment timeout - please try again");
    } catch (e) {
      print("❌ PayMob payment error: ${e.runtimeType} - $e");
      return _createErrorResponse("Payment failed: ${_safeStringify(e)}");
    }

    print(
        "📋 Final payment result: ${paymentResult['success']} - ${paymentResult['message']}");
    return paymentResult;
  }

  // Safely handle PayMob response with maximum null protection
  static void _handlePaymentResponse(
      dynamic response, Map<String, dynamic> resultContainer) {
    print("📨 === PayMob Response Handler ===");

    try {
      // Check if response exists
      if (response == null) {
        print("❌ Response is completely null");
        _updateResult(
            resultContainer, false, "No payment response received", null, null);
        return;
      }

      print("📊 Response type: ${response.runtimeType}");

      // Safely extract response properties
      final responseData = _extractResponseData(response);

      print("📋 Extracted data: $responseData");

      // Determine payment success
      final isSuccessful = _determinePaymentSuccess(responseData);

      // Create final result
      final message = isSuccessful
          ? "Payment completed successfully"
          : (responseData['message'] ?? "Payment was not completed");

      _updateResult(resultContainer, isSuccessful, message,
          responseData['transactionID'], responseData['responseCode']);

      print("✅ Payment response processed successfully");
    } catch (e) {
      print("❌ Error processing payment response: ${e.runtimeType} - $e");
      _updateResult(resultContainer, false,
          "Error processing payment: ${_safeStringify(e)}", null, null);
    }
  }

  // Safely extract data from response object
  static Map<String, String?> _extractResponseData(dynamic response) {
    final data = <String, String?>{
      'success': null,
      'message': null,
      'transactionID': null,
      'responseCode': null,
    };

    try {
      // Extract success field
      try {
        final successValue = response.success;
        data['success'] = successValue?.toString();
        print("🔍 Success: ${data['success']}");
      } catch (e) {
        print("⚠️ Could not extract success: $e");
      }

      // Extract message field
      try {
        final messageValue = response.message;
        data['message'] = _safeStringify(messageValue);
        print("🔍 Message: ${data['message']}");
      } catch (e) {
        print("⚠️ Could not extract message: $e");
      }

      // Extract transaction ID
      try {
        final transactionValue = response.transactionID;
        data['transactionID'] = _safeStringify(transactionValue);
        print("🔍 Transaction ID: ${data['transactionID']}");
      } catch (e) {
        print("⚠️ Could not extract transactionID: $e");
      }

      // Extract response code
      try {
        final codeValue = response.responseCode;
        data['responseCode'] = _safeStringify(codeValue);
        print("🔍 Response Code: ${data['responseCode']}");
      } catch (e) {
        print("⚠️ Could not extract responseCode: $e");
      }
    } catch (e) {
      print("❌ Error extracting response data: $e");
    }

    return data;
  }

  // Determine if payment was successful based on multiple indicators
  static bool _determinePaymentSuccess(Map<String, String?> data) {
    try {
      // Check explicit success flag
      if (data['success'] == 'true') {
        print("✅ Payment successful by success flag");
        return true;
      }

      // Check response code for success indicators
      final responseCode = data['responseCode'];
      if (responseCode != null) {
        final codeUpper = responseCode.toUpperCase();
        if (codeUpper == '0' ||
            codeUpper == 'APPROVED' ||
            codeUpper == 'SUCCESS') {
          print("✅ Payment successful by response code: $responseCode");
          return true;
        }

        // Check for failure codes
        if (codeUpper == 'DECLINED' ||
            codeUpper == 'FAILED' ||
            codeUpper == 'ERROR') {
          print("❌ Payment failed by response code: $responseCode");
          return false;
        }
      }

      // Check message for success/failure indicators
      final message = data['message'];
      if (message != null) {
        final msgUpper = message.toUpperCase();
        if (msgUpper.contains('SUCCESS') || msgUpper.contains('APPROVED')) {
          print("✅ Payment successful by message: $message");
          return true;
        }

        if (msgUpper.contains('DECLINED') ||
            msgUpper.contains('FAILED') ||
            msgUpper.contains('ERROR')) {
          print("❌ Payment failed by message: $message");
          return false;
        }
      }

      // Check if we have a transaction ID (sometimes indicates success)
      final transactionID = data['transactionID'];
      if (transactionID != null &&
          transactionID.isNotEmpty &&
          transactionID != 'null') {
        print("✅ Payment successful due to transaction ID presence");
        return true;
      }

      print("❓ Payment success undetermined - defaulting to false");
      return false;
    } catch (e) {
      print("❌ Error determining payment success: $e");
      return false;
    }
  }

  // Safely convert any value to string
  static String _safeStringify(dynamic value) {
    if (value == null) return '';
    try {
      return value.toString();
    } catch (e) {
      return '';
    }
  }

  // Create standardized error response
  static Map<String, dynamic> _createErrorResponse(String message) {
    return {
      'success': false,
      'message': message,
      'transactionID': null,
      'responseCode': null,
    };
  }

  // Update result container safely
  static void _updateResult(
    Map<String, dynamic> container,
    bool success,
    String message,
    String? transactionID,
    String? responseCode,
  ) {
    try {
      container['success'] = success;
      container['message'] = message;
      container['transactionID'] = transactionID;
      container['responseCode'] = responseCode;

      print("📝 Result updated: $success - $message");
    } catch (e) {
      print("❌ Error updating result: $e");
    }
  }
}
