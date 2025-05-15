import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/screens/login/cubit.dart';
import 'package:foodapp/screens/login/forgotPasswordScreen.dart';
import 'package:foodapp/screens/login/states.dart';
import 'package:foodapp/screens/signup/signupScreen.dart';
import 'package:foodapp/shared/constants.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    var cubit = Logincubit.get(context);

    // Light theme colors
    const primaryColor = Color(0xFFFF5722); // Orange
    const backgroundColor = Color(0xFFFFFBF5); // Light cream
    const cardColor = Colors.white;
    const textColor = Color(0xFF333333); // Dark gray
    const secondaryTextColor = Color(0xFF666666); // Mid gray

    return BlocConsumer<Logincubit, LoginStates>(
      listener: (context, State) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 60.h),
                    // Logo or illustration
                    Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant_menu,
                          size: 60,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      S.of(context).welcome_back,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      S.of(context).sign_in_to_continue,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    // Login form in a card
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(24.w),
                      child: Form(
                        key: cubit.formkey,
                        child: Column(
                          children: [
                            // Email field
                            TextFormField(
                              controller: cubit.emailcontroller,
                              style: const TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: S.of(context).Email,
                                hintText: S.of(context).enter_email,
                                labelStyle:
                                    const TextStyle(color: secondaryTextColor),
                                prefixIcon: const Icon(Icons.email_outlined,
                                    color: primaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 16.h),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  return null;
                                }
                                return S.of(context).email_required;
                              },
                            ),
                            SizedBox(height: 16.h),
                            // Password field
                            TextFormField(
                              controller: cubit.passwordcontroller,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: S.of(context).password,
                                hintText: S.of(context).enter_password,
                                labelStyle:
                                    const TextStyle(color: secondaryTextColor),
                                prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: primaryColor),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 16.h),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  return null;
                                }
                                return S.of(context).password_required;
                              },
                            ),
                            SizedBox(height: 8.h),
                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  S.of(context).forgot_password,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            // Login button
                            ConditionalBuilder(
                              condition: state is LoginLoadingState,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                              ),
                              fallback: (context) => SizedBox(
                                width: double.infinity,
                                height: 50.h,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (cubit.formkey.currentState!
                                        .validate()) {
                                      cubit.login(
                                        email: cubit.emailcontroller.text,
                                        password: cubit.passwordcontroller.text,
                                        context: context,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    S.of(context).log_in_button,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                    // OR divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1.h,
                            color: Colors.grey[300],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            S.of(context).or,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1.h,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    // Social logins
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google button
                        GestureDetector(
                          onTap: () {
                            cubit.signinwithgoogle(context: context);
                          },
                          child: Container(
                            width: 120.w,
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/signinLogos/google.png",
                                  width: 24.w,
                                  height: 24.h,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  S.of(context).google,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 20.w),
                        // Apple button
                        GestureDetector(
                          onTap: () {
                            cubit.signinwithapple(context: context);
                          },
                          child: Container(
                            width: 120.w,
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/signinLogos/apple.png",
                                  width: 24.w,
                                  height: 24.h,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  S.of(context).apple,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.of(context).dont_have_account,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14.sp,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            navigateTo(context, const Signupscreen());
                          },
                          child: Text(
                            S.of(context).sign_up,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
