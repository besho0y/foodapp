import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/layout/states.dart';
import 'package:foodapp/shared/colors.dart';

class Layout extends StatelessWidget {
  Layout({super.key});

  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var cubit = Layoutcubit.get(context);
    return BlocConsumer<Layoutcubit, Layoutstates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          key: scaffoldKey,
          appBar:
              cubit.currentindex == 0
                  ? PreferredSize(
                    preferredSize: Size(double.infinity, 120.h),
                    child: AppBar(
                      toolbarHeight: double.infinity,
                      automaticallyImplyLeading:
                          false, // <<< Disable back arrow
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
                    automaticallyImplyLeading: false, // <<< Disable back arrow
                    actions:
                        cubit.currentindex == 3
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
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(25.r),
                  ),
                ),
                builder:
                    (context) => BlocBuilder<Layoutcubit, Layoutstates>(
                      builder: (context, state) {
                        var cubit = Layoutcubit.get(context);
                        return Container(
                          padding: EdgeInsets.all(20.w),
                          height: 600.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25.r),
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  itemCount: cubit.cartitems.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10.h,
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10.r,
                                            ),
                                            child: Image.asset(
                                              cubit.cartitems[index].img,
                                              width: 80.w,
                                              height: 80.h,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(width: 15.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cubit.cartitems[index].name,
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 5.h),
                                                Text(
                                                  "${cubit.cartitems[index].price} EGP",
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                SizedBox(height: 10.h),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        cubit.decreaseQuantity(
                                                          index,
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .remove_circle_outline,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${cubit.cartitems[index].quantity}",
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        cubit.increaseQuantity(
                                                          index,
                                                        );
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              cubit.removeItemFromCart(index);
                                            },
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Total",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 5.h),
                                        Text(
                                          "${cubit.calculateTotalPrice()} EGP",
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Checkout action
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 30.w,
                                          vertical: 15.h,
                                        ),
                                        backgroundColor: Colors.deepOrange,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Checkout",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              );
            },
            shape: CircleBorder(),
            child: Icon(Icons.shopping_cart_outlined),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,

          body: cubit.screens[cubit.currentindex],

          bottomNavigationBar: AnimatedBottomNavigationBar(
            icons: cubit.bottomnav,
            activeIndex: cubit.currentindex,
            activeColor: AppColors.primarylight,

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
