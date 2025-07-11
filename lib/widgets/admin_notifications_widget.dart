import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/shared/admin_notification_service.dart';
import 'package:foodapp/shared/colors.dart';
import 'package:intl/intl.dart';

class AdminNotificationsWidget extends StatefulWidget {
  const AdminNotificationsWidget({super.key});

  @override
  State<AdminNotificationsWidget> createState() =>
      _AdminNotificationsWidgetState();
}

class _AdminNotificationsWidgetState extends State<AdminNotificationsWidget> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        isLoading = true;
      });

      final fetchedNotifications =
          await AdminNotificationService.getAdminNotifications(limit: 20);
      final count = await AdminNotificationService.getUnreadNotificationCount();

      if (mounted) {
        setState(() {
          notifications = fetchedNotifications;
          unreadCount = count;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading admin notifications: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await AdminNotificationService.markNotificationAsRead(notificationId);
      await _loadNotifications(); // Refresh notifications
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      DateTime dateTime;
      if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else if (timestamp is Map && timestamp['_seconds'] != null) {
        dateTime =
            DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
      } else {
        return 'Unknown time';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM d, yyyy').format(dateTime);
      }
    } catch (e) {
      return 'Unknown time';
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Admin Notifications',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (unreadCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: _loadNotifications,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Notifications List
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (notifications.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 48.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isRead = notification['read'] == true;
                  final isError = notification['type'] == 'notification_error';

                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    color: isRead ? null : Colors.blue.shade50,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isError
                            ? Colors.red
                            : (isRead ? Colors.grey : AppColors.primaryBrown),
                        child: Icon(
                          isError ? Icons.error : Icons.notifications,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      title: Text(
                        notification['title'] ?? 'No title',
                        style: TextStyle(
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification['body'] ?? 'No message',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _formatTimestamp(notification['timestamp'] ??
                                notification['createdAt']),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: !isRead
                          ? IconButton(
                              icon: Icon(
                                Icons.mark_email_read,
                                color: AppColors.primaryBrown,
                                size: 20.sp,
                              ),
                              onPressed: () => _markAsRead(notification['id']),
                            )
                          : null,
                      onTap: !isRead
                          ? () => _markAsRead(notification['id'])
                          : null,
                    ),
                  );
                },
              ),

            // Clean up button
            if (notifications.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await AdminNotificationService
                            .cleanupOldNotifications();
                        _loadNotifications();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Old notifications cleaned up'),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error cleaning up notifications: $e');
                      }
                    },
                    icon: Icon(Icons.cleaning_services),
                    label: Text('Clean Up Old'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
