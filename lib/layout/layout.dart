import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/layout/states.dart';
import 'package:foodapp/screens/checkout/checkout_screen.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/screens/profile/states.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/shared/colors.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Load user data when layout is initialized
    ProfileCubit.get(context).getuserdata();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = Layoutcubit.get(context);

    return BlocConsumer<Layoutcubit, Layoutstates>(
      listener: (context, state) {},
      builder: (context, state) {
        return BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, profileState) {},
          builder: (context, profileState) {
            var profileCubit = ProfileCubit.get(context);

            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(
                key: scaffoldKey,
                appBar: cubit.currentindex == 0
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 10.h),
                                      Text(
                                        "Hello, ${profileCubit.user.name}",
                                        style: TextStyle(fontSize: 22.sp),
                                      ),
                                      Text(
                                        "what do you want to eat today?",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
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
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  prefixIcon: const Icon(Icons.search),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.0.w,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  filled: true,
                                ),
                                onChanged: (value) {
                                  Restuarantscubit.get(context).search(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    : AppBar(
                        title: Text(cubit.titles[cubit.currentindex]),
                        automaticallyImplyLeading:
                            false, // <<< Disable back arrow
                        actions: cubit.currentindex == 3
                            ? [
                                IconButton(
                                  onPressed: () {
                                    cubit.toggletheme();
                                  },
                                  icon: Icon(
                                    Icons.brightness_6_outlined,
                                    size: 25.sp,
                                  ),
                                ),
                              ]
                            : [],
                      ),
                floatingActionButton: MediaQuery.of(context)
                            .viewInsets
                            .bottom ==
                        0
                    ? FloatingActionButton(
                        heroTag:
                            "cart_button_${DateTime.now().millisecondsSinceEpoch}",
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.r),
                              ),
                            ),
                            builder: (context) =>
                                BlocBuilder<Layoutcubit, Layoutstates>(
                              builder: (context, state) {
                                var cubit = Layoutcubit.get(context);
                                return Container(
                                  padding: EdgeInsets.all(20.w),
                                  height: 600.h,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Your Cart",
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            icon: Icon(Icons.close),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20.h),
                                      Expanded(
                                        child: cubit.cartitems.isEmpty
                                            ? Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .shopping_cart_outlined,
                                                      size: 80.sp,
                                                      color: Colors.grey,
                                                    ),
                                                    SizedBox(height: 16.h),
                                                    Text(
                                                      "Your cart is empty",
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    SizedBox(height: 8.h),
                                                    Text(
                                                      "Add items to your cart to get started",
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : ListView.builder(
                                                itemCount:
                                                    cubit.cartitems.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: 15.h),
                                                    padding:
                                                        EdgeInsets.all(10.w),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .cardColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.r),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.05),
                                                          spreadRadius: 1,
                                                          blurRadius: 5,
                                                          offset: const Offset(
                                                              0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.r),
                                                          child:
                                                              _buildCartItemImage(
                                                            cubit
                                                                .cartitems[
                                                                    index]
                                                                .img,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10.w),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                cubit
                                                                    .cartitems[
                                                                        index]
                                                                    .name,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      16.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 5.h),
                                                              Text(
                                                                "${cubit.cartitems[index].price} EGP",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            IconButton(
                                                              onPressed: () {
                                                                cubit
                                                                    .decreaseQuantity(
                                                                        index);
                                                              },
                                                              icon: Icon(
                                                                Icons.remove,
                                                                size: 24.sp,
                                                              ),
                                                            ),
                                                            Text(
                                                              "${cubit.cartitems[index].quantity}",
                                                              style: TextStyle(
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                cubit
                                                                    .increaseQuantity(
                                                                        index);
                                                              },
                                                              icon: Icon(
                                                                Icons.add,
                                                                size: 24.sp,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            cubit
                                                                .removeItemFromCart(
                                                                    index);
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors.red,
                                                            size: 24.sp,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                      ),
                                      // Order summary with checkout button
                                      if (cubit.cartitems.isNotEmpty)
                                        Column(
                                          children: [
                                            Divider(),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 10.h),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Total:',
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${cubit.calculateTotalPrice().toStringAsFixed(2)} EGP',
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 10.h),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w),
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context); // Close the cart sheet
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const CheckoutScreen(),
                                                      ),
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 12.h),
                                                  ),
                                                  child: Text(
                                                    'Proceed to Checkout',
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20.h),
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        child: Badge(
                          label: Text('${cubit.cartitems.length}'),
                          isLabelVisible: cubit.cartitems.isNotEmpty,
                          child: const Icon(Icons.shopping_cart_outlined),
                        ),
                      )
                    : null,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                body: cubit.screens[cubit.currentindex],
                bottomNavigationBar: AnimatedBottomNavigationBar(
                  icons: cubit.bottomnav,
                  activeIndex: cubit.currentindex,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkCard
                          : Colors.white,
                  activeColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.primaryDark
                      : AppColors.primaryLight,
                  gapLocation: GapLocation.center,
                  inactiveColor: Colors.grey.shade600,
                  notchSmoothness: NotchSmoothness.verySmoothEdge,
                  leftCornerRadius: 32,
                  rightCornerRadius: 32,
                  onTap: (index) {
                    cubit.changenavbar(index);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCartItemImage(String imageUrl) {
    try {
      if (imageUrl.isEmpty) {
        return Container(
          width: 80.w,
          height: 80.h,
          color: Colors.grey[300],
          child: Icon(
            Icons.fastfood,
            color: Colors.grey[600],
            size: 40.sp,
          ),
        );
      }

      if (imageUrl.startsWith('http')) {
        // Network image with error handling
        return Image.network(
          imageUrl,
          width: 80.w,
          height: 80.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading cart image: $error");
            return Container(
              width: 80.w,
              height: 80.h,
              color: Colors.grey[300],
              child: Icon(
                Icons.broken_image,
                color: Colors.grey[600],
                size: 40.sp,
              ),
            );
          },
        );
      } else if (imageUrl.startsWith('assets/')) {
        // Asset image with error handling
        return Image.asset(
          imageUrl,
          width: 80.w,
          height: 80.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print("Error loading asset image: $error");
            return Container(
              width: 80.w,
              height: 80.h,
              color: Colors.grey[300],
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey[600],
                size: 40.sp,
              ),
            );
          },
        );
      } else {
        // Default fallback when image path is invalid
        return Image.asset(
          'assets/images/items/default.jpg',
          width: 80.w,
          height: 80.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80.w,
              height: 80.h,
              color: Colors.grey[300],
              child: Icon(
                Icons.error_outline,
                color: Colors.grey[600],
                size: 40.sp,
              ),
            );
          },
        );
      }
    } catch (e) {
      print("Error in _buildCartItemImage: $e");
      return Container(
        width: 80.w,
        height: 80.h,
        color: Colors.grey[300],
        child: Icon(
          Icons.error_outline,
          color: Colors.grey[600],
          size: 40.sp,
        ),
      );
    }
  }
}
