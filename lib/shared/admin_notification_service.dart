import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class AdminNotificationService {
  static final AdminNotificationService _instance =
      AdminNotificationService._internal();
  factory AdminNotificationService() => _instance;
  AdminNotificationService._internal();

  // Admin user ID (same as in your firestore.rules)
  static const String adminUserId = "yzPSwbiWTgXywHPVyBXhjfZGjR42";

  // Firebase instances
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Stream subscription for order listener
  StreamSubscription<QuerySnapshot>? _orderListener;

  // Track initialization state
  bool _isInitialized = false;

  /// Manual test function for debugging
  static Future<void> debugTestAdminToken() async {
    print('🔔 === MANUAL ADMIN TOKEN TEST ===');
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      print('👤 Current user: ${currentUser?.uid ?? 'null'}');

      if (currentUser != null && currentUser.uid == adminUserId) {
        final instance = AdminNotificationService._instance;
        print('🔔 Manually saving admin token...');
        await instance._saveAdminToken();

        print('🔔 Manually checking if token exists...');
        final token = await getAdminToken();
        print(
            '🔔 Manual check result: ${token != null ? 'TOKEN EXISTS' : 'NO TOKEN'}');

        if (token != null) {
          print('✅ Manual test: Admin token is working correctly');
        } else {
          print('❌ Manual test: Admin token is NOT working');
        }
      } else {
        print('❌ Manual test: Current user is not admin');
      }
    } catch (e) {
      print('❌ Manual test error: $e');
    }
    print('🔔 === MANUAL TEST END ===');
  }

  /// Initialize the admin notification service
  /// This should be called when the app starts
  static Future<void> initialize() async {
    print('🔔 === INITIALIZING ADMIN NOTIFICATION SERVICE ===');
    print('🔔 Build Mode: ${kDebugMode ? 'DEBUG' : 'RELEASE'}');

    try {
      final instance = AdminNotificationService._instance;

      // Check if current user is admin
      final currentUser = FirebaseAuth.instance.currentUser;
      print('👤 Current user: ${currentUser?.uid ?? 'null'}');

      if (currentUser != null && currentUser.uid == adminUserId) {
        print('🔑 Current user is admin - saving FCM token');
        await instance._saveAdminToken();

        // Also debug check if token was saved
        await Future.delayed(Duration(seconds: 2));
        final savedToken = await getAdminToken();
        print(
            '✅ Admin token saved successfully: ${savedToken != null ? 'YES' : 'NO'}');
        if (savedToken != null) {
          print('🔑 Token preview: ${savedToken.substring(0, 20)}...');
        } else {
          print(
              '❌ WARNING: Admin token was not saved! Notifications will not work!');
          print('🔔 Attempting manual retry...');
          await debugTestAdminToken();
        }
      } else {
        print('👤 Current user is not admin');

        // Add listener for when user logs in as admin
        FirebaseAuth.instance.authStateChanges().listen((user) async {
          if (user != null && user.uid == adminUserId) {
            print('🔔 Admin user just logged in, saving token...');
            await instance._saveAdminToken();
          }
        });
      }

      // Always start listening for new orders (to send notifications to admin)
      await instance._startOrderListener();

      instance._isInitialized = true;
      print('✅ Admin notification service initialized successfully');
    } catch (e, stackTrace) {
      print('❌ Error initializing admin notification service: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Save admin FCM token to Firestore
  Future<void> _saveAdminToken() async {
    try {
      print('🔔 === ADMIN TOKEN SAVE PROCESS START ===');
      print('🔔 Platform: ${defaultTargetPlatform.toString()}');
      print('🔔 Is Web: $kIsWeb');
      print('🔔 Getting FCM token...');

      final token = await _messaging.getToken();
      print('🔔 FCM token received: ${token != null ? 'YES' : 'NO'}');

      if (token != null) {
        print('🔔 Token length: ${token.length}');
        print(
            '🔔 Token preview: ${token.substring(0, math.min(30, token.length))}...');
        print('🔔 Saving admin token to Firestore...');
        print('🔔 Admin User ID: $adminUserId');

        // Try to save with more detailed error handling
        await _firestore.collection('admin_tokens').doc(adminUserId).set({
          'token': token,
          'userId': adminUserId,
          'updatedAt': FieldValue.serverTimestamp(),
          'deviceInfo': {
            'platform': defaultTargetPlatform.toString(),
            'isWeb': kIsWeb,
            'buildMode': kDebugMode ? 'debug' : 'release',
          },
          'tokenLength': token.length,
          'timestamp': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

        print('✅ Admin FCM token saved successfully');
        print('🔔 === ADMIN TOKEN SAVE PROCESS COMPLETE ===');

        // Verify the save by reading it back
        await Future.delayed(Duration(seconds: 1));
        final doc =
            await _firestore.collection('admin_tokens').doc(adminUserId).get();
        if (doc.exists) {
          final data = doc.data();
          print('✅ VERIFICATION: Token found in Firestore');
          print(
              '🔔 Stored token preview: ${data?['token']?.substring(0, 30)}...');
          print('🔔 Build mode: ${data?['deviceInfo']?['buildMode']}');
        } else {
          print('❌ VERIFICATION FAILED: Token not found in Firestore');
        }
      } else {
        print('❌ No FCM token received - this is the problem!');
        print('❌ Trying to get token again...');

        // Try again with explicit permission request
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        final retryToken = await _messaging.getToken();
        print('🔔 Retry token: ${retryToken != null ? 'YES' : 'NO'}');

        if (retryToken != null) {
          print('✅ Got token on retry, saving...');
          await _firestore.collection('admin_tokens').doc(adminUserId).set({
            'token': retryToken,
            'userId': adminUserId,
            'updatedAt': FieldValue.serverTimestamp(),
            'deviceInfo': {
              'platform': defaultTargetPlatform.toString(),
              'isWeb': kIsWeb,
              'buildMode': kDebugMode ? 'debug' : 'release',
            },
            'retryAttempt': true,
            'timestamp': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
          print('✅ Admin FCM token saved on retry');
        }
      }
      print('🔔 === ADMIN TOKEN SAVE PROCESS END ===');
    } catch (e, stackTrace) {
      print('❌ === ADMIN TOKEN SAVE ERROR ===');
      print('❌ Error saving admin token: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ === END ERROR ===');
      rethrow;
    }
  }

  /// Get admin FCM token from Firestore
  static Future<String?> getAdminToken() async {
    try {
      print('🔔 Getting admin token from Firestore...');
      final doc =
          await _firestore.collection('admin_tokens').doc(adminUserId).get();
      if (doc.exists && doc.data() != null) {
        final token = doc.data()!['token'] as String?;
        print('✅ Admin token retrieved: ${token != null ? 'YES' : 'NO'}');
        return token;
      } else {
        print('❌ No admin token document found');
        return null;
      }
    } catch (e) {
      print('❌ Error getting admin token: $e');
      return null;
    }
  }

  /// Start listening for new orders
  Future<void> _startOrderListener() async {
    print('🔔 Starting order listener for admin notifications...');

    try {
      // Listen to the orders collection for new documents
      _orderListener = _firestore
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .limit(1) // Only get the latest order
          .snapshots()
          .listen(
        _handleOrderUpdate,
        onError: (error) {
          print('❌ Error in order listener: $error');
        },
      );

      print('✅ Order listener started successfully');
    } catch (e) {
      print('❌ Error starting order listener: $e');
    }
  }

  /// Handle order updates (new orders)
  Future<void> _handleOrderUpdate(QuerySnapshot snapshot) async {
    try {
      print('📊 Order update received - ${snapshot.docs.length} documents');

      // Skip if no documents
      if (snapshot.docs.isEmpty) {
        print('📊 No orders found in snapshot');
        return;
      }

      // Get the latest order
      final latestOrderDoc = snapshot.docs.first;
      final orderData = latestOrderDoc.data() as Map<String, dynamic>;

      print('📊 Latest order ID: ${latestOrderDoc.id}');
      print('📊 Order data keys: ${orderData.keys.join(', ')}');

      // Check if this is a new order (created within last 30 seconds)
      final timestamp = orderData['timestamp'] as Timestamp?;
      if (timestamp != null) {
        final orderTime = timestamp.toDate();
        final now = DateTime.now();
        final difference = now.difference(orderTime).inSeconds;

        print('📊 Order age: $difference seconds');

        // Only send notification for very recent orders (within 30 seconds)
        if (difference <= 30) {
          print('🔔 New order detected: ${latestOrderDoc.id}');
          await _sendAdminNotification(orderData);
        } else {
          print('📊 Order is older than 30 seconds, skipping notification');
        }
      } else {
        print('📊 No timestamp in order data');
      }
    } catch (e) {
      print('❌ Error handling order update: $e');
    }
  }

  /// Send notification to admin about new order
  Future<void> _sendAdminNotification(Map<String, dynamic> orderData) async {
    try {
      final orderId = orderData['id'] ?? 'Unknown';
      final userName = orderData['userName'] ?? 'Unknown Customer';
      final total = orderData['total'] ?? 0.0;
      final itemCount = (orderData['items'] as List?)?.length ?? 0;

      print('🔔 Preparing notification for order: $orderId');
      print('🔔 Customer: $userName, Items: $itemCount, Total: $total');

      // Prepare notification data
      final notificationData = {
        'title': 'New Order Received! 🎉',
        'body':
            'Order from $userName - $itemCount items - \$${total.toStringAsFixed(2)}',
        'orderId': orderId,
        'type': 'new_order',
        'timestamp': DateTime.now().toIso8601String(),
        'customerName': userName,
        'orderTotal': total,
        'itemCount': itemCount,
      };

      print('🔔 Sending admin notification for order: $orderId');

      // Store the notification in Firestore (this will trigger the Cloud Function)
      await _firestore.collection('admin_notifications').add({
        ...notificationData,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      print('✅ Admin notification stored successfully');

      // You can also trigger a local notification here if the admin is currently using the app
      await _showLocalNotificationIfAdminActive(notificationData);
    } catch (e) {
      print('❌ Error sending admin notification: $e');
    }
  }

  /// Show local notification if admin is currently active
  Future<void> _showLocalNotificationIfAdminActive(
      Map<String, dynamic> notificationData) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == adminUserId) {
        // Admin is currently logged in, show local notification
        print('🔔 Admin is active - showing local notification');

        // You could implement local notification here
        // For now, we'll just print the notification
        print('📱 LOCAL NOTIFICATION: ${notificationData['title']}');
        print('📱 MESSAGE: ${notificationData['body']}');
      }
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  /// Stop the order listener
  static Future<void> stopOrderListener() async {
    final instance = AdminNotificationService._instance;
    if (instance._orderListener != null) {
      print('⏹️ Stopping order listener...');
      await instance._orderListener?.cancel();
      instance._orderListener = null;
      print('✅ Order listener stopped');
    }
  }

  /// Update admin token when it changes
  static Future<void> updateAdminToken() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == adminUserId) {
        print('🔔 Updating admin token...');
        final instance = AdminNotificationService._instance;
        await instance._saveAdminToken();
      }
    } catch (e) {
      print('❌ Error updating admin token: $e');
    }
  }

  /// Get all admin notifications
  static Future<List<Map<String, dynamic>>> getAdminNotifications(
      {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('admin_notifications')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('❌ Error getting admin notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('admin_notifications')
          .doc(notificationId)
          .update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Get unread notification count
  static Future<int> getUnreadNotificationCount() async {
    try {
      final snapshot = await _firestore
          .collection('admin_notifications')
          .where('read', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting unread notification count: $e');
      return 0;
    }
  }

  /// Clean up old notifications (older than 30 days)
  static Future<void> cleanupOldNotifications() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final snapshot = await _firestore
          .collection('admin_notifications')
          .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Cleaned up ${snapshot.docs.length} old notifications');
    } catch (e) {
      print('❌ Error cleaning up old notifications: $e');
    }
  }
}
