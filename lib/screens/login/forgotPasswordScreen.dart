import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testFirebaseAuthConfiguration();
  }

  // Test Firebase Auth configuration
  Future<void> _testFirebaseAuthConfiguration() async {
    try {
      print('🔧 === TESTING FIREBASE AUTH CONFIGURATION ===');

      // Test 1: Check if Firebase Auth instance is available
      final auth = FirebaseAuth.instance;
      print('✅ Firebase Auth instance: ${auth.app.name}');

      // Test 2: Check current user state
      final currentUser = auth.currentUser;
      print('👤 Current user: ${currentUser?.uid ?? 'No user signed in'}');

      // Test 3: Check if we can access Firebase Auth methods
      print('🔧 Testing Firebase Auth methods...');

      // Test 4: Try to get auth state changes stream (this will fail if Firebase isn't configured)
      final authStateStream = auth.authStateChanges();
      print('📡 Auth state stream available: ${authStateStream != null}');

      // Test 5: Check app configuration
      print('🔧 App configuration:');
      print('  App name: ${auth.app.name}');
      print('  Project ID: ${auth.app.options.projectId}');
      print(
          '  Auth domain: ${auth.app.options.authDomain ?? 'Not configured'}');

      // Test 6: Check if authDomain is properly configured
      final authDomain = auth.app.options.authDomain;
      if (authDomain == null || authDomain.isEmpty) {
        print(
            '⚠️ WARNING: Auth domain is not configured - this might cause password reset issues');
      }

      print('✅ === FIREBASE AUTH CONFIGURATION TEST COMPLETED ===');
    } catch (e) {
      print('❌ === FIREBASE AUTH CONFIGURATION TEST FAILED ===');
      print('❌ Error: ${e.runtimeType} - $e');
      print('❌ This might be causing the password reset issue');

      // Show configuration error to user if in debug mode
      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          _showConfigurationWarning();
        });
      }
    }
  }

  // Show configuration warning to user
  void _showConfigurationWarning() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final bool isTablet = MediaQuery.of(context).size.width >= 600;
        final double scale = isTablet ? 0.75 : 1.0;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Color(0xFF8D4E3C)),
              SizedBox(width: 8 * scale),
              Text('Configuration Issue'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'There might be a Firebase configuration issue that could affect password reset emails.',
                style: TextStyle(fontSize: 14 * scale),
              ),
              SizedBox(height: 12 * scale),
              Text(
                'If you continue to have issues:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '• Check your spam/junk folder\n'
                '• Verify your email address is correct\n'
                '• Contact support if the problem persists',
                style: TextStyle(fontSize: 12 * scale),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Enhanced email validation
  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    // Remove whitespace
    email = email.trim();

    // Check for basic email format
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // Check for common email domains (optional validation)
    if (email.length < 5) {
      return 'Email is too short';
    }

    return null;
  }

  Future<void> _resetPassword() async {
    print('🔄 === FORGOT PASSWORD: Starting reset process ===');

    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    final email = _emailController.text.trim();
    print('📧 Email to reset: $email');

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Sending password reset email...');

      // Add timeout to prevent hanging
      await Future.any([
        FirebaseAuth.instance.sendPasswordResetEmail(email: email),
        Future.delayed(const Duration(seconds: 30),
            () => throw Exception('Request timeout - please try again')),
      ]);

      print('✅ Password reset email sent successfully');

      if (mounted) {
        _showSuccessMessage(
            'Password reset email sent! Please check your inbox and spam folder.');

        // Wait a bit before navigating back
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Exception: ${e.code} - ${e.message}');

      String message = 'An error occurred while sending the reset email';
      switch (e.code) {
        case 'user-not-found':
          message =
              'No account found with this email address. Please check your email or sign up for a new account.';
          break;
        case 'invalid-email':
          message =
              'The email address is not valid. Please enter a correct email address.';
          break;
        case 'too-many-requests':
          message =
              'Too many password reset requests. Please wait a few minutes before trying again.';
          break;
        case 'user-disabled':
          message =
              'This account has been disabled. Please contact support for assistance.';
          break;
        case 'operation-not-allowed':
          message =
              'Password reset is not enabled for this app. Please contact support.';
          break;
        case 'weak-password':
          message =
              'The password is too weak. Please choose a stronger password.';
          break;
        default:
          message =
              e.message ?? 'An unexpected error occurred. Please try again.';
      }

      if (mounted) {
        _showErrorMessage(message);
      }
    } catch (e) {
      print('❌ General Exception: ${e.runtimeType} - $e');

      String message = 'An unexpected error occurred';
      if (e.toString().contains('timeout')) {
        message =
            'The request timed out. Please check your internet connection and try again.';
      } else if (e.toString().contains('network')) {
        message =
            'Network error. Please check your internet connection and try again.';
      } else {
        message = 'Failed to send reset email. Please try again later.';
      }

      if (mounted) {
        _showErrorMessage(message);
      }
    } finally {
      print('🔄 Reset process completed');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    final double scale = isTablet ? 0.75 : 1.0;
    showToast(
      message,
      context: context,
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.green,
      textStyle: TextStyle(color: Colors.white, fontSize: 16.0 * scale),
      position: StyledToastPosition.top,
    );
  }

  void _showErrorMessage(String message) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    final double scale = isTablet ? 0.75 : 1.0;
    showToast(
      message,
      context: context,
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.red,
      textStyle: TextStyle(color: Colors.white, fontSize: 16.0 * scale),
      position: StyledToastPosition.top,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF8D4E3C); // Brown
    const backgroundColor = Color(0xFFFFFBF5); // Light cream
    const cardColor = Colors.white;
    const textColor = Color(0xFF333333); // Dark gray
    const secondaryTextColor = Color(0xFF666666); // Mid gray
    final bool isTablet = MediaQuery.of(context).size.width >= 600;
    final double scale = isTablet ? 0.75 : 1.0;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h * scale),

              // Header section with icon
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r * scale),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r * scale),
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      color: primaryColor,
                      size: 32.sp * scale,
                    ),
                  ),
                  SizedBox(width: 16.w * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 24.sp * scale,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 4.h * scale),
                        Text(
                          'No worries, we\'ll help you reset it',
                          style: TextStyle(
                            fontSize: 14.sp * scale,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h * scale),

              Text(
                'Enter your email address and we\'ll send you a secure link to reset your password.',
                style: TextStyle(
                  fontSize: 16.sp * scale,
                  color: secondaryTextColor,
                  height: 1.5 * scale,
                ),
              ),

              SizedBox(height: 40.h * scale),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20.r * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(24.w * scale),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _resetPassword(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16 * scale,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter your email',
                          labelStyle:
                              const TextStyle(color: secondaryTextColor),
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r * scale),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r * scale),
                            borderSide:
                                const BorderSide(color: primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16.h * scale,
                            horizontal: 12.w * scale,
                          ),
                        ),
                        validator: _validateEmail,
                      ),
                      SizedBox(height: 24.h * scale),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h * scale,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            disabledBackgroundColor: Colors.grey[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r * scale),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20.w * scale,
                                      height: 20.h * scale,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12.w * scale),
                                    Text(
                                      'Sending...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Send Reset Email',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 10.sp : 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h * scale),

              // Help section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r * scale),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12.r * scale),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue[600], size: 20.sp * scale),
                        SizedBox(width: 8.w),
                        Text(
                          'Important Notes',
                          style: TextStyle(
                            fontSize: 14.sp * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h * scale),
                    Text(
                      '• Check your spam/junk folder if you don\'t see the email\n'
                      '• The reset link will expire in 1 hour\n'
                      '• Make sure you entered the correct email address\n'
                      '• If you continue having issues, contact support',
                      style: TextStyle(
                        fontSize: 12.sp * scale,
                        color: Colors.blue[700],
                        height: 1.4 * scale,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h * scale),
            ],
          ),
        ),
      ),
    );
  }
}
