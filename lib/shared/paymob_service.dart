import 'package:flutter/material.dart';
import 'package:flutter_paymob/flutter_paymob.dart';

class PayMobService {
  // Initialize the PayMob service
  static void initialize() {
    FlutterPaymob.instance.initialize(
      // TODO: IMPORTANT - Before going live:
      // 1. Replace this test API key with your production API key from PayMob dashboard
      // 2. The production API key will start with "ZXlKaGJHY..." but will be different from this test key
      apiKey:
          "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBME5ETTROQ3dpYm1GdFpTSTZJbWx1YVhScFlXd2lmUS4xb0oyWGdtNWx1ZDN1clVRTEVSbUtCLUdWSVdsaFB4bm5qTVFtSk91NWdMRHkxM1VoMTNZanF3Nzh5QnJueHB4eGd5bEJMZ2JmVUUxUFFuYUgxMXRuQQ==",

      // TODO: Replace with your production card integration ID
      integrationID: 5084698,

      // TODO: Replace with your production iFrame ID
      iFrameID: 919925,

      // Note: This is a dummy value since we don't use wallet payments.
      // The package requires this parameter but we only process card payments.
      walletIntegrationId: 0,
    );
  }

  // Process payment with card
  static Future<Map<String, dynamic>> processCardPayment({
    required BuildContext context,
    required double amount,
    String currency = "EGP",
  }) async {
    try {
      late Map<String, dynamic> resultResponse = {
        'success': false,
        'message': ''
      };

      await FlutterPaymob.instance.payWithCard(
        context: context,
        currency: currency,
        amount: amount,
        onPayment: (response) {
          // Debug print to see the full response
          print("PayMob Response: ${response.toString()}");
          print("Success: ${response.success}");
          print("Message: ${response.message}");
          print("Transaction ID: ${response.transactionID}");
          print("Response Code: ${response.responseCode}");

          // Check for declined or failed transaction first
          if (response.responseCode?.toUpperCase() == 'DECLINED' ||
              response.responseCode?.toUpperCase() == 'FAILED' ||
              response.message?.toUpperCase().contains('DECLINED') == true ||
              response.message?.toUpperCase().contains('FAILED') == true) {
            resultResponse = {
              'success': false,
              'message':
                  'Transaction declined: ${response.message ?? 'Card payment was not approved'}',
              'transactionID': response.transactionID,
              'responseCode': response.responseCode,
            };
            return;
          }

          // Only consider successful if we have explicit success indicators
          bool isSuccessful = (response.responseCode == '0' ||
                  response.responseCode?.toUpperCase() == 'APPROVED') &&
              response.transactionID != null;

          // Update the result with the response data
          resultResponse = {
            'success': isSuccessful,
            'message': isSuccessful
                ? 'Payment successful'
                : (response.message ?? 'Payment verification failed'),
            'transactionID': response.transactionID,
            'responseCode': response.responseCode,
          };

          print("Final Result Response: $resultResponse");
        },
      );

      return resultResponse;
    } catch (e) {
      print("Card payment error: $e");
      return {
        'success': false,
        'message': "Payment failed: ${e.toString()}",
      };
    }
  }

  // Process payment with wallet
  static Future<Map<String, dynamic>> processWalletPayment({
    required BuildContext context,
    required double amount,
    required String phoneNumber,
    String currency = "EGP",
  }) async {
    try {
      late Map<String, dynamic> resultResponse = {
        'success': false,
        'message': ''
      };

      await FlutterPaymob.instance.payWithWallet(
        context: context,
        currency: currency,
        amount: amount,
        number: phoneNumber,
        onPayment: (response) {
          // Debug print to see the full response
          print("PayMob Wallet Response: ${response.toString()}");
          print("Success: ${response.success}");
          print("Message: ${response.message}");
          print("Transaction ID: ${response.transactionID}");
          print("Response Code: ${response.responseCode}");

          // Check for declined or failed transaction first
          if (response.responseCode?.toUpperCase() == 'DECLINED' ||
              response.responseCode?.toUpperCase() == 'FAILED' ||
              response.message?.toUpperCase().contains('DECLINED') == true ||
              response.message?.toUpperCase().contains('FAILED') == true) {
            resultResponse = {
              'success': false,
              'message':
                  'Transaction declined: ${response.message ?? 'Payment was not approved'}',
              'transactionID': response.transactionID,
              'responseCode': response.responseCode,
            };
            return;
          }

          // Only consider successful if we have explicit success indicators
          bool isSuccessful = (response.responseCode == '0' ||
                  response.responseCode?.toUpperCase() == 'APPROVED') &&
              response.transactionID != null;

          // Update the result with the response data
          resultResponse = {
            'success': isSuccessful,
            'message': isSuccessful
                ? 'Payment successful'
                : (response.message ?? 'Payment verification failed'),
            'transactionID': response.transactionID,
            'responseCode': response.responseCode,
          };

          print("Final Wallet Result Response: $resultResponse");
        },
      );

      return resultResponse;
    } catch (e) {
      print("Wallet payment error: $e");
      return {
        'success': false,
        'message': "Payment failed: ${e.toString()}",
      };
    }
  }
}
