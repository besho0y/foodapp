import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/layout/states.dart';

class Layout extends StatelessWidget {
  const Layout({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = Layoutcubit.get(context);
    return BlocConsumer<Layoutcubit, Layoutstates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar:
              cubit.currentindex == 0
                  ? PreferredSize(
                    preferredSize: Size(double.infinity.w, 120.h),
                    child: AppBar(
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      toolbarHeight: double.infinity.h,
                      title: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 10.h),
                                  Text(
                                    "Hello, Ahmed",
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "what do you want to eat today?",
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              Spacer(),
                              CircleAvatar(
                                radius: 25.r,
                                backgroundColor: Colors.grey[300],
                                child: Icon(
                                  Icons.person_outline,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "Search",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.r),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : AppBar(
                    title: Text(cubit.titles[cubit.currentindex]),
                    actions:
                        cubit.currentindex == 2
                            ? [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.brightness_6_outlined,
                                  size: 25.sp,
                                ),
                              ),
                            ]
                            : [],
                  ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            shape: CircleBorder(),
            child: Icon(Icons.shopping_cart_outlined),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: cubit.screens[cubit.currentindex],

          bottomNavigationBar: AnimatedBottomNavigationBar(
            icons: cubit.bottomnav,
            activeIndex: cubit.currentindex,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.verySmoothEdge,
            leftCornerRadius: 32,
            rightCornerRadius: 32,
            onTap: (index) {
              cubit.changenavbar(index);
            },
          ),
        );
      },
    );
  }
}
