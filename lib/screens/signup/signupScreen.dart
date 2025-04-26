import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/shared/constants.dart';

class Signupscreen extends StatelessWidget {
  Signupscreen({super.key});
  final firstnamecontroller = TextEditingController();
  final lastnamecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final phonecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create an account",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),

                SizedBox(height: 90),
                // Add your signup form fields here
                Form(
                  key: formkey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 160.w,
                            child: defaultTextFormField(
                              label: "First Name",
                              prefix: Icons.circle_rounded,
                              controller: firstnamecontroller,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  return null;
                                }
                                return "required";
                              },
                              context: context,
                            ),
                          ),
                          SizedBox(
                            width: 160.w,
                            child: defaultTextFormField(
                              label: "Last Name",
                              prefix: Icons.circle_rounded,
                              controller: lastnamecontroller,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  return null;
                                }
                                return "required";
                              },
                              context: context,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      defaultTextFormField(
                        label: "Email",
                        prefix: Icons.email_outlined,
                        controller: emailcontroller,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            return null;
                          }
                          return "required";
                        },
                        context: context,
                      ),
                      SizedBox(height: 20.h),

                      defaultTextFormField(
                        label: "Phone",
                        prefix: Icons.phone_iphone_outlined,
                        controller: phonecontroller,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.length == 11) {
                              return null;
                            }
                            return "Phone number must be 11 digits";
                          }
                          return "required";
                        },
                        context: context,
                      ),
                      SizedBox(height: 20.h),

                      defaultTextFormField(
                        label: "Password",
                        prefix: Icons.lock_outline_rounded,
                        controller: passwordcontroller,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.length >= 6) {
                              return null;
                            }
                          }
                          return "required";
                        },
                        context: context,
                        isPassword: true,
                        suffix: Icons.remove_red_eye_outlined,
                        suffixPressed: () {},
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {
                        if (value == true) {
                          // Perform some action if needed
                        }
                      },
                    ),
                    Text(
                      "I agree to the terms and conditions",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                defaultbutton(
                  text: "Sign Up",
                  function: () {
                    if (formkey.currentState!.validate()) {
                      navigateAndFinish(context, Layout());
                    }
                  },
                  context: context,
                ),
                SizedBox(height: 300.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
