import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:foodapp/shared/admin_notification_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static BuildContext? _context;

  // Set context for showing toasts
  static void setContext(BuildContext context) {
    _context = context;
  }

  // Initialize Firebase messaging service
  static Future<void> initialize() async {
    print('🔔 === INITIALIZING FIREBASE MESSAGING ===');

    try {
      // Step 1: Request notification permissions
      print('🔔 Step 1: Requesting permissions...');
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('🔐 Permission status: ${settings.authorizationStatus}');

      // Step 2: Get and print FCM token
      print('🔔 Step 2: Getting FCM token...');
      String? token = await _firebaseMessaging.getToken();
      print('🔑 FCM Token: ${token ?? "Failed to get token"}');

      // Step 2.5: Create notification channel for Android
      await _createNotificationChannel();

      // Step 3: Set up message handlers
      print('🔔 Step 3: Setting up message handlers...');
      _setupMessageHandlers();

      // Step 4: Listen for token refresh and update admin token if needed
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed: $newToken');
        // Update admin token if current user is admin
        AdminNotificationService.updateAdminToken();
      });

      print('✅ Firebase Messaging initialized successfully');
      print('🔔 === FIREBASE MESSAGING READY ===');
    } catch (e, stackTrace) {
      print('❌ Error initializing Firebase Messaging: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow; // Re-throw to let main.dart handle it
    }
  }

  // Create notification channel for Android
  static Future<void> _createNotificationChannel() async {
    try {
      print('🔔 Creating notification channel for Android...');
      // This would typically require platform-specific code
      // For now, we'll rely on the AndroidManifest.xml configuration
      print('✅ Notification channel configuration ready');
    } catch (e) {
      print('❌ Error creating notification channel: $e');
    }
  }

  // Setup message handlers
  static void _setupMessageHandlers() {
    print('🎯 Setting up message handlers...');

    try {
      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification taps when app is terminated
      _handleAppTerminatedNotification();

      print('✅ Message handlers set up');
    } catch (e) {
      print('❌ Error setting up message handlers: $e');
    }
  }

  // Handle messages when app is in foreground
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('🔔 === FOREGROUND MESSAGE RECEIVED ===');
    print('📱 Message ID: ${message.messageId}');
    print('📝 Title: ${message.notification?.title ?? 'No title'}');
    print('📝 Body: ${message.notification?.body ?? 'No body'}');
    print('📊 Data: ${message.data}');
    print('⏰ Sent time: ${message.sentTime}');
    print('🏷️ From: ${message.from}');
    print('📱 App in FOREGROUND - System will show notification');
    print(
        'ℹ️  NOTE: Foreground notifications may not show popup - this is normal Android behavior');
    print(
        'ℹ️  To see notification popup: minimize app and send another message');
    print('✅ Foreground message handling complete');

    // Show a visual toast notification
    if (_context != null) {
      showToast(
        message.notification?.title ?? 'New message received',
        context: _context!,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        textStyle: const TextStyle(color: Colors.white),
      );
    }
  }

  // Handle notification tap (when app is in background)
  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('👆 User tapped notification (background): ${message.messageId}');
    print('📝 Title: ${message.notification?.title}');
    print('📝 Body: ${message.notification?.body}');
    print('📊 Data: ${message.data}');

    // Since you only want to open the app, we don't need to navigate anywhere
    // The app will automatically come to foreground when notification is tapped
  }

  // Handle notification when app is terminated
  static Future<void> _handleAppTerminatedNotification() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print(
          '👆 User opened app from terminated state via notification: ${initialMessage.messageId}');
      print('📝 Title: ${initialMessage.notification?.title}');
      print('📝 Body: ${initialMessage.notification?.body}');
      print('📊 Data: ${initialMessage.data}');

      // Since you only want to open the app, we don't need to navigate anywhere
      // The app will automatically start when notification is tapped
    }
  }

  // Get current FCM token (for external use)
  static Future<String?> getCurrentToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('❌ Error getting current FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic $topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  // Delete token (for logout)
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      print('✅ FCM token deleted');
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }
}
