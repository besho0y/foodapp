import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/screens/login/cubit.dart';
import 'package:foodapp/screens/login/states.dart';
import 'package:foodapp/screens/signup/signupScreen.dart';
import 'package:foodapp/shared/constants.dart';

class Loginscreen extends StatelessWidget {
  Loginscreen({super.key});
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    var cubit = Logincubit.get(context);
    return BlocConsumer<Logincubit,LoginStates>(
      listener: (context, State) {},
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height.h,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Log In",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Text(
                        "Welcome Back",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: 90.h),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            defaultTextFormField(
                              context: context,
                              label: "Email",
                              prefix: Icons.email_outlined,
                              controller: emailcontroller,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  return null;
                                }
                                return "Please enter your email";
                              },
                            ),
                            SizedBox(height: 20.h),
                            defaultTextFormField(
                              context: context,
                              label: "Password",
                              prefix: Icons.lock_outline_rounded,
                              controller: passwordcontroller,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  return null;
                                }
                                return "Please enter your password";
                              },
                              isPassword: true,
                              suffix: Icons.remove_red_eye_outlined,
                              suffixPressed: () {},
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Forgot Password?",
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                     ConditionalBuilder(condition: state is LoginLoadingState, builder: (context)=>const Center(child: CircularProgressIndicator(),), fallback: (context)=>
                      defaultbutton(
                        context: context,
                        text: "LOGIN",
                        function: () {
                          if (formKey.currentState!.validate()) {
                            cubit.login(
                                email: emailcontroller.text,
                                password: passwordcontroller.text,context: context);
                              
                          }
                        },
                      ),
                     ),
                      Row(
                        children: [
                          Text(
                            "Don't hava an account?",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextButton(
                            onPressed: () {
                              navigateTo(context, Signupscreen());
                            },
                            child: Text(
                              "Sign UP",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 200.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
