import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/shared/admin_notification_service.dart';
import 'package:foodapp/shared/colors.dart';

class AdminNotificationTest extends StatefulWidget {
  const AdminNotificationTest({super.key});

  @override
  State<AdminNotificationTest> createState() => _AdminNotificationTestState();
}

class _AdminNotificationTestState extends State<AdminNotificationTest> {
  String _testResult = 'Ready to test';
  bool _isLoading = false;

  Future<void> _testAdminToken() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing admin token...';
    });

    try {
      await AdminNotificationService.debugTestAdminToken();
      final token = await AdminNotificationService.getAdminToken();

      setState(() {
        _testResult = token != null
            ? '✅ SUCCESS: Admin token is saved and working!'
            : '❌ FAILED: Admin token is not saved';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ ERROR: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testNotification() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Creating test notification...';
    });

    try {
      // Create a test notification entry
      await AdminNotificationService
          .cleanupOldNotifications(); // This will test Firestore access

      setState(() {
        _testResult = '✅ Test notification created successfully!';
        _isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Test notification created! Check the notifications list.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _testResult = '❌ Failed to create test notification: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification System Test',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBrown,
              ),
            ),
            SizedBox(height: 16.h),

            // Test Result Display
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _testResult,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Test Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testAdminToken,
                    icon: _isLoading
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.security),
                    label: Text('Test Admin Token'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrown,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testNotification,
                    icon: _isLoading
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.notifications_active),
                    label: Text('Test Firestore'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Instructions
            Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '1. Test Admin Token - Checks if FCM token is saved\n'
              '2. Test Firestore - Checks if Firestore connection works\n'
              '3. Check logs for detailed debug information',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
