import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/screens/about_us/about_us_screen.dart';
import 'package:foodapp/screens/admin%20panel/adminpanelscreen.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/screens/profile/profileScreen.dart';
import 'package:foodapp/screens/settingdetailsscreen/settingdetails.dart';
import 'package:foodapp/screens/terms/terms_screen.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/shared/firebase_messaging_service.dart';
import 'package:foodapp/shared/local_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class Settingsscreen extends StatelessWidget {
  const Settingsscreen({super.key});

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    // Show confirmation dialog
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(S.of(context).logout_title),
            content: Text(S.of(context).logout_confirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 74, 26, 15),
                  foregroundColor: Colors.white,
                ),
                child: Text(S.of(context).logout),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm && context.mounted) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        print('Current user before sign out: ${currentUser?.email}');

        // Clear cart items from local storage
        await LocalStorageService.clearCartItems();

        // Clear cart items from cubit
        Layoutcubit.get(context).clearCart();

        // Clear favorites from cubit
        try {
          Favouritecubit.get(context).clearFavorites();
        } catch (e) {
          print("Error clearing favorites on logout: $e");
        }

        await FirebaseAuth.instance.signOut();

        final userAfterSignOut = FirebaseAuth.instance.currentUser;
        print('User after sign out: $userAfterSignOut');

        if (context.mounted) {
          print('Navigating to home screen after logout');

          // Get the Layout from the widget tree
          const layoutWidget = Layout();

          // Navigate to Layout with reset navigation
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => layoutWidget),
            (route) => false,
          );

          // Access the Layoutcubit to ensure we're on the first tab (index 0)
          if (context.mounted) {
            Future.delayed(const Duration(milliseconds: 100), () {
              final layoutCubit = Layoutcubit.get(context);
              layoutCubit.changenavbar(0); // Change to the first tab
            });
          }
        }
      } catch (error) {
        print('Sign out error: $error');
        if (context.mounted) {
          showToast(
            "Failed to sign out: ${error.toString()}",
            context: context,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
            textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
            position: StyledToastPosition.bottom,
          );
        }
      }
    }
  }

  Future<void> _openWhatsAppWithContext(BuildContext context) async {
    const phoneNumber = '+201274939902';
    const whatsappUrl = 'https://wa.me/$phoneNumber';

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        showToast(
          "Could not launch WhatsApp",
          context: context,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
          textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
          position: StyledToastPosition.bottom,
        );
      }
    } catch (e) {
      showToast(
        "Error opening WhatsApp: ${e.toString()}",
        context: context,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
        textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
        position: StyledToastPosition.bottom,
      );
    }
  }

  // Check if user is an admin
  Future<bool> _isUserAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // You can implement your admin check logic here
      // For example, checking if the user's email is in an admin list
      // or checking a specific field in the user's document in Firestore

      // For demonstration purposes, let's make a simple check
      // This should be replaced with your actual admin verification logic
      return user.email == 'admin@example.com';
    }
    return false;
  }

  // Show FCM Token Dialog for testing Firebase messaging
  void _showFCMTokenDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      String? token = await FirebaseMessagingService.getCurrentToken();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.notifications_active),
                SizedBox(width: 8),
                Text('FCM Token'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Firebase Cloud Messaging Token:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SelectableText(
                      token ?? 'No token available',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Use this token to send test notifications from Firebase Console or your server.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (token != null) {
                    Clipboard.setData(ClipboardData(text: token));
                    showToast(
                      'FCM Token copied to clipboard!',
                      context: context,
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 16.0),
                      position: StyledToastPosition.bottom,
                    );
                  }
                },
                child: const Text('Copy Token'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      showToast(
        'Error getting FCM token: ${e.toString()}',
        context: context,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
        position: StyledToastPosition.bottom,
      );
    }
  }

  // Show FCM Debug Dialog
  void _showFCMDebugDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      String? token = await FirebaseMessagingService.getCurrentToken();

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.bug_report, color: Colors.orange),
                SizedBox(width: 8),
                Text('FCM Debug Info'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDebugItem('🔑 FCM Token Status',
                      token != null ? 'Generated' : 'Missing'),
                  const SizedBox(height: 8),
                  _buildDebugItem(
                      '📱 Token Length', token?.length.toString() ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildDebugItem('🔔 Permissions', 'Check in system settings'),
                  const SizedBox(height: 8),
                  _buildDebugItem('📊 App State', 'Foreground'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📝 Troubleshooting Steps:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('1. Check if FCM token is generated'),
                        const Text('2. Verify notification permissions'),
                        const Text('3. Test with Firebase Console'),
                        const Text('4. Check device internet connection'),
                        const Text('5. Ensure correct Firebase project'),
                        const Text(
                            '6. System handles notifications automatically'),
                        const SizedBox(height: 8),
                        if (token != null) ...[
                          const Text('✅ Token generated successfully!',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text(
                              'Copy token below and test in Firebase Console'),
                        ] else ...[
                          const Text('❌ Token generation failed!',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text(
                              'Check app permissions and Firebase setup'),
                        ],
                      ],
                    ),
                  ),
                  if (token != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🔑 FCM Token:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 4),
                          SelectableText(
                            token,
                            style: const TextStyle(
                                fontSize: 10, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (token != null)
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: token));
                    showToast(
                      'FCM Token copied! Test in Firebase Console',
                      context: context,
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.green,
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 16.0),
                      position: StyledToastPosition.bottom,
                    );
                  },
                  child: const Text('Copy Token'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      showToast(
        'Error getting FCM debug info: ${e.toString()}',
        context: context,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        textStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
        position: StyledToastPosition.bottom,
      );
    }
  }

  Widget _buildDebugItem(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          flex: 1,
          child: Text(value,
              style: const TextStyle(fontSize: 12), textAlign: TextAlign.end),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),

          // Show Profile option only if logged in
          if (isLoggedIn)
            GestureDetector(
              onTap: () => navigateTo(context, const Profilescreen()),
              child: Card(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      SizedBox(width: 5.w),
                      Text(
                        S.of(context).profile,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          GestureDetector(
            onTap: () => navigateTo(context, const Settingdetails()),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                child: Row(
                  children: [
                    const Icon(Icons.settings),
                    SizedBox(width: 5.w),
                    Text(
                      S.of(context).settings,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contact us is always shown
          GestureDetector(
            onTap: () => _openWhatsAppWithContext(context),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                child: Row(
                  children: [
                    const Icon(Icons.call),
                    SizedBox(width: 5.w),
                    Text(
                      S.of(context).contact_us,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // About Us
          GestureDetector(
            onTap: () => navigateTo(context, const AboutUsScreen()),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline),
                    SizedBox(width: 5.w),
                    Text(
                      S.of(context).about_us,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Terms & Conditions
          GestureDetector(
            onTap: () => navigateTo(context, const TermsScreen()),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined),
                    SizedBox(width: 5.w),
                    Text(
                      S.of(context).terms_and_conditions,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Admin panel option
          if (isLoggedIn)
            FutureBuilder<bool>(
              future: _isUserAdmin(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return GestureDetector(
                    onTap: () => navigateTo(context, const AdminPanelScreen()),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.h, horizontal: 5.w),
                        child: Row(
                          children: [
                            const Icon(Icons.admin_panel_settings),
                            SizedBox(width: 5.w),
                            Text(
                              S.of(context).admin_panel,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

          // Firebase Messaging Debug option
          GestureDetector(
            onTap: () => _showFCMDebugDialog(context),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                child: Row(
                  children: [
                    const Icon(Icons.bug_report, color: Colors.orange),
                    SizedBox(width: 5.w),
                    Text(
                      'Debug Firebase Messaging',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Show Login or Logout based on authentication state
          GestureDetector(
            onTap: isLoggedIn
                ? () => _showLogoutConfirmation(context)
                : () => navigateTo(context, const Loginscreen()),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                child: Row(
                  children: [
                    Icon(isLoggedIn ? Icons.logout : Icons.login),
                    SizedBox(width: 5.w),
                    Text(
                      isLoggedIn ? S.of(context).logout : S.of(context).login,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
