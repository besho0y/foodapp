import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/screens/signup/cubit.dart';
import 'package:foodapp/screens/signup/states.dart';
import 'package:foodapp/screens/terms/terms_screen.dart';
import 'package:foodapp/shared/constants.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final namecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final phonecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final confirmpasswordcontroller = TextEditingController();
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var cubit = Signupcubit.get(context);

    // Light theme colors - same as login screen
    const primaryColor = Color.fromARGB(255, 74, 26, 15); // Brown
    const backgroundColor = Color(0xFFFFFBF5); // Light cream
    const cardColor = Colors.white;
    const textColor = Color(0xFF333333); // Dark gray
    const secondaryTextColor = Color(0xFF666666); // Mid gray

    return BlocProvider(
      create: (context) => Signupcubit(),
      child: BlocConsumer<Signupcubit, SignupStates>(
        listener: (context, state) {
          if (state is CreateUserSuccessState) {
            navigateAndFinish(context, const Layout());
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Column(
                    children: [
                      // Logo or illustration
                      Center(
                        child: Image.asset(
                          "assets/logo/logo.png", // Correct logo path
                          width: 150.w,
                          height: 150.h,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to food icon if logo doesn't exist
                            return Icon(
                              Icons.restaurant_menu,
                              size: 50.sp,
                              color: primaryColor,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        S.of(context).create_account,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        S.of(context).sign_up_to_get_started,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: secondaryTextColor,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Social login options
                      Text(
                        S.of(context).sign_up_with,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16.h),
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
                          Container(
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
                        ],
                      ),
                      SizedBox(height: 20.h),

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
                      SizedBox(height: 20.h),

                      // Signup form
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
                        padding: EdgeInsets.all(20.w),
                        child: Form(
                          key: formkey,
                          child: Column(
                            children: [
                              // Name field
                              TextFormField(
                                controller: namecontroller,
                                style: const TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  labelText: S.of(context).Name,
                                  hintText: S.of(context).enter_full_name,
                                  labelStyle: const TextStyle(
                                      color: secondaryTextColor),
                                  prefixIcon: const Icon(Icons.person,
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
                                  return S.of(context).name_required;
                                },
                              ),
                              SizedBox(height: 16.h),

                              // Email field
                              TextFormField(
                                controller: emailcontroller,
                                style: const TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  labelText: S.of(context).Email,
                                  hintText: S.of(context).enter_email,
                                  labelStyle: const TextStyle(
                                      color: secondaryTextColor),
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

                              // Phone field
                              TextFormField(
                                controller: phonecontroller,
                                style: const TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  labelText: S.of(context).Phone,
                                  hintText: S.of(context).enter_phone,
                                  labelStyle: const TextStyle(
                                      color: secondaryTextColor),
                                  prefixIcon: const Icon(
                                      Icons.phone_iphone_outlined,
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
                                    if (value.length == 11) {
                                      return null;
                                    }
                                    return S.of(context).phone_length_error;
                                  }
                                  return S.of(context).phone_required;
                                },
                              ),
                              SizedBox(height: 16.h),

                              // Password field
                              TextFormField(
                                controller: passwordcontroller,
                                obscureText: !_isPasswordVisible,
                                style: const TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  labelText: S.of(context).password,
                                  hintText: S.of(context).create_password,
                                  labelStyle: const TextStyle(
                                      color: secondaryTextColor),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
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
                                    if (value.length >= 6) {
                                      return null;
                                    }
                                    return S.of(context).password_length_error;
                                  }
                                  return S.of(context).password_required;
                                },
                              ),
                              SizedBox(height: 16.h),

                              // Confirm Password field
                              TextFormField(
                                controller: confirmpasswordcontroller,
                                obscureText: !_isConfirmPasswordVisible,
                                style: const TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  labelText: S.of(context).confirm_password,
                                  hintText: S.of(context).confirm_password,
                                  labelStyle: const TextStyle(
                                      color: secondaryTextColor),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
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
                                    if (value == passwordcontroller.text) {
                                      return null;
                                    }
                                    return S.of(context).passwords_not_match;
                                  }
                                  return S
                                      .of(context)
                                      .password_confirm_required;
                                },
                              ),
                              SizedBox(height: 16.h),

                              // Terms and conditions
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: Checkbox(
                                      value: false,
                                      onChanged: (value) {},
                                      activeColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        navigateTo(context, const TermsScreen());
                                      },
                                      child: Text(
                                        S.of(context).terms_and_conditions,
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 14.sp,
                                          decoration: TextDecoration.underline,
                                          decorationColor: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),

                              // Sign up button
                              SizedBox(
                                width: double.infinity,
                                height: 50.h,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (formkey.currentState!.validate()) {
                                      cubit.userRegister(
                                        email: emailcontroller.text,
                                        password: passwordcontroller.text,
                                        phone: phonecontroller.text,
                                        name: namecontroller.text,
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
                                    S.of(context).sign_up_button,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            S.of(context).already_have_account,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 14.sp,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Explicitly navigate to login screen
                              navigateAndFinish(context, const Loginscreen());
                            },
                            child: Text(
                              S.of(context).log_in,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
