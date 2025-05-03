import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/screens/signup/cubit.dart';
import 'package:foodapp/screens/signup/states.dart';
import 'package:foodapp/shared/constants.dart';

class Signupscreen extends StatelessWidget {
  Signupscreen({super.key});

  final namecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final phonecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var cubit = Signupcubit.get(context);
    return BlocConsumer<Signupcubit, SignupStates>(
      listener: (context, state) {
        if (state is CreateUserSuccessState) {
          navigateAndFinish(context, Layout());
        }
      },
      builder: (context, state) {
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
                          defaultTextFormField(
                            label: "Last Name",
                            prefix: Icons.circle_rounded,
                            controller: namecontroller,
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
                          cubit.userRegister(
                              email: emailcontroller.text,
                              password: passwordcontroller.text,
                              phone: phonecontroller.text,
                              name: namecontroller.text,
                              context: context,
                              );
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
      },
    );
  }
}
