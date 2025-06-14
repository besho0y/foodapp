import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/layout/states.dart';
import 'package:foodapp/models/user.dart';
import 'package:foodapp/screens/admin%20panel/cubit.dart';
import 'package:foodapp/screens/admin%20panel/states.dart';
import 'package:foodapp/screens/checkout/checkout_screen.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/screens/profile/cubit.dart';
import 'package:foodapp/screens/profile/states.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/screens/resturants/states.dart';
import 'package:foodapp/shared/colors.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hasInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Try to load user data if available, but don't require it
    _initializeUserData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Separate method to initialize user data only once
  void _initializeUserData() {
    if (FirebaseAuth.instance.currentUser != null && !_isDisposed) {
      ProfileCubit.get(context).getuserdata();
    }
  }

  @override
  Widget build(BuildContext context) {
    var cubit = Layoutcubit.get(context);

    return BlocConsumer<Layoutcubit, Layoutstates>(
      listener: (context, state) {},
      builder: (context, state) {
        return BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, profileState) {
            // Check if user data loaded successfully and component is still mounted
            if (profileState is ProfileLoaded && !_hasInitialized && mounted) {
              // Only set admin status once to prevent refresh loop
              cubit.checkAndSetAdminStatus(profileState.user.uid);
              _hasInitialized = true;
            }
          },
          builder: (context, profileState) {
            var profileCubit = ProfileCubit.get(context);
            bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: WillPopScope(
                onWillPop: () async {
                  // Show confirmation dialog
                  bool shouldExit = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(S.of(context).confirm_exit),
                          content: Text(S.of(context).confirm_exit_message),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                S.of(context).cancel,
                                style: TextStyle(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(S.of(context).yes),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  return shouldExit;
                },
                child: Scaffold(
                  key: scaffoldKey,
                  appBar: cubit.currentindex == 0
                      ? PreferredSize(
                          preferredSize: Size(
                            double.infinity,
                            Directionality.of(context) == TextDirection.rtl
                                ? 175.h
                                : 160.h,
                          ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 10.h),
                                        Text(
                                          isLoggedIn &&
                                                  profileState is ProfileLoaded
                                              ? "${S.of(context).hello}, ${profileCubit.user.name}"
                                              : "${S.of(context).hello}, ${S.of(context).user}",
                                          style: TextStyle(fontSize: 22.sp),
                                        ),
                                        Text(
                                          S
                                              .of(context)
                                              .what_do_you_want_to_eat_today,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                TextFormField(
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    hintText: S.of(context).Search,
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
                                SizedBox(height: 8.h),
                                // Location Selection Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _showLocationSelectionDialog(context),
                                    icon: const Icon(Icons.location_on),
                                    label: BlocBuilder<Restuarantscubit,
                                        ResturantsStates>(
                                      builder: (context, state) {
                                        final restCubit =
                                            Restuarantscubit.get(context);
                                        final isRTL =
                                            Directionality.of(context) ==
                                                TextDirection.rtl;
                                        return Text(
                                          isRTL
                                              ? 'الموقع: ${restCubit.selectedArea}'
                                              : 'Location: ${restCubit.selectedArea}',
                                          style: TextStyle(fontSize: 14.sp),
                                        );
                                      },
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.darkCard
                                              : AppColors.lightBackground,
                                      foregroundColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12.h, horizontal: 16.w),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.h,
                                )
                              ],
                            ),
                          ),
                        )
                      : AppBar(
                          title:
                              Text(cubit.titles(context)[cubit.currentindex]),
                          automaticallyImplyLeading:
                              false, // <<< Disable back arrow
                        ),
                  floatingActionButton:
                      // Hide the cart button for admin user
                      cubit.isAdminUser
                          ? null
                          : (MediaQuery.of(context).viewInsets.bottom == 0
                              ? FloatingActionButton(
                                  heroTag:
                                      "cart_button_${DateTime.now().millisecondsSinceEpoch}",
                                  onPressed: () async {
                                    // Check if user is logged in before showing cart
                                    if (!isLoggedIn) {
                                      _showLoginRequiredDialog(
                                          context, "access your cart");
                                      return;
                                    }

                                    FocusScope.of(context).unfocus();
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor:
                                          Theme.of(context).cardColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25.r),
                                        ),
                                      ),
                                      builder: (context) => BlocBuilder<
                                          Layoutcubit, Layoutstates>(
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      S.of(context).cart,
                                                      style: TextStyle(
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      icon: const Icon(
                                                          Icons.close),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20.h),
                                                Expanded(
                                                  child: cubit.cartitems.isEmpty
                                                      ? Center(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .shopping_cart_outlined,
                                                                size: 80.sp,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                              SizedBox(
                                                                  height: 16.h),
                                                              Text(
                                                                S
                                                                    .of(context)
                                                                    .cart_empty,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      18.sp,
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 8.h),
                                                              Text(
                                                                S
                                                                    .of(context)
                                                                    .cart_items_count(
                                                                        0),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : ListView.builder(
                                                          itemCount: cubit
                                                              .cartitems.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          15.h),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          10.w),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .cardColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.r),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.05),
                                                                    spreadRadius:
                                                                        1,
                                                                    blurRadius:
                                                                        5,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            3),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.r),
                                                                    child:
                                                                        _buildCartItemImage(
                                                                      cubit
                                                                          .cartitems[
                                                                              index]
                                                                          .img,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10.w),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Builder(builder:
                                                                            (context) {
                                                                          final isRTL =
                                                                              Directionality.of(context) == TextDirection.rtl;
                                                                          final item =
                                                                              cubit.cartitems[index];
                                                                          print(
                                                                              'Cart Item Debug:');
                                                                          print(
                                                                              'isRTL: $isRTL');
                                                                          print(
                                                                              'name: ${item.name}');
                                                                          print(
                                                                              'nameAr: ${item.nameAr}');
                                                                          return Text(
                                                                            isRTL
                                                                                ? item.nameAr
                                                                                : item.name,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 16.sp,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          );
                                                                        }),
                                                                        SizedBox(
                                                                            height:
                                                                                5.h),
                                                                        Text(
                                                                          "${cubit.cartitems[index].price} ${Directionality.of(context) == TextDirection.rtl ? 'جنيه' : 'EGP'}",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                14.sp,
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          cubit.decreaseQuantity(
                                                                              index);
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .remove,
                                                                          size:
                                                                              24.sp,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        "${cubit.cartitems[index].quantity}",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16.sp,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          cubit.increaseQuantity(
                                                                              index);
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .add,
                                                                          size:
                                                                              24.sp,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      cubit.removeItemFromCart(
                                                                          index);
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .delete_outline,
                                                                      color: Colors
                                                                          .red,
                                                                      size:
                                                                          24.sp,
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
                                                      const Divider(),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    16.w,
                                                                vertical: 10.h),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  S
                                                                      .of(context)
                                                                      .items,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16.sp,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${cubit.calculateSubtotal().toStringAsFixed(2)} ${S.of(context).egp}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16.sp,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 8.h),
                                                            // Calculate total delivery fees
                                                            Builder(
                                                              builder:
                                                                  (context) {
                                                                // Calculate total delivery fees
                                                                double
                                                                    totalDeliveryFee =
                                                                    0.0;

                                                                // Group by restaurant to avoid duplicates
                                                                final restaurantGroups =
                                                                    groupItemsByRestaurant(
                                                                        cubit
                                                                            .cartitems);

                                                                // Add one delivery fee per restaurant
                                                                restaurantGroups
                                                                    .forEach((_,
                                                                        items) {
                                                                  try {
                                                                    double fee =
                                                                        double.parse(items
                                                                            .first
                                                                            .deliveryFee);
                                                                    totalDeliveryFee +=
                                                                        fee;
                                                                  } catch (e) {
                                                                    print(
                                                                        'Error parsing fee: $e');
                                                                  }
                                                                });

                                                                // Show single row with total delivery fees
                                                                return Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          bottom:
                                                                              8.h),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        restaurantGroups.length >
                                                                                1
                                                                            ? '${S.of(context).delivery_fee} (${restaurantGroups.length})'
                                                                            : S.of(context).delivery_fee,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14.sp,
                                                                          color:
                                                                              Colors.grey[600],
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        '${totalDeliveryFee.toStringAsFixed(2)} ${S.of(context).egp}',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              14.sp,
                                                                          color:
                                                                              Colors.grey[600],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            Divider(
                                                                height: 16.h),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  S
                                                                      .of(context)
                                                                      .total_amount,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${cubit.calculateTotalPrice().toStringAsFixed(2)} ${S.of(context).egp}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 10.h),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    16.w),
                                                        child: SizedBox(
                                                          width:
                                                              double.infinity,
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
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          12.h),
                                                            ),
                                                            child: Text(
                                                              S
                                                                  .of(context)
                                                                  .checkout,
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
                                    child: const Icon(
                                        Icons.shopping_cart_outlined),
                                  ),
                                )
                              : null),
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
              ),
            );
          },
        );
      },
    );
  }

  // Dialog to prompt login
  void _showLoginRequiredDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).login_required),
        content: Text(S.of(context).login_to_continue),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Loginscreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(S.of(context).log_in),
          ),
        ],
      ),
    );
  }

  Map<String, List<CartItem>> groupItemsByRestaurant(List<CartItem> items) {
    // Group items by restaurant ID to avoid duplicate fees
    Map<String, List<CartItem>> restaurantGroups = {};

    for (var item in items) {
      if (!restaurantGroups.containsKey(item.restaurantId)) {
        restaurantGroups[item.restaurantId] = [];
      }
      restaurantGroups[item.restaurantId]!.add(item);
    }

    // Print debug info
    print("\nGrouping cart items by restaurant:");
    restaurantGroups.forEach((restaurantId, restaurantItems) {
      print(
          "- ${restaurantItems.first.restaurantName}: ${restaurantItems.length} items");
    });

    return restaurantGroups;
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

  // Location Selection Dialog
  void _showLocationSelectionDialog(BuildContext context) {
    String? selectedCityId;
    String? selectedAreaId;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(S.of(context).select_location),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // City Dropdown
                BlocBuilder<AdminPanelCubit, AdminPanelStates>(
                  builder: (context, state) {
                    final adminCubit = AdminPanelCubit.get(context);

                    // Load cities if not already loaded
                    if (adminCubit.cities.isEmpty) {
                      adminCubit.fetchCities();
                    }

                    return DropdownButtonFormField<String>(
                      value: selectedCityId,
                      decoration: InputDecoration(
                        labelText: S.of(context).select_city,
                        labelStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        hintStyle: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            width: 2.0,
                          ),
                        ),
                      ),
                      items: adminCubit.cities.map((city) {
                        final isRTL =
                            Directionality.of(context) == TextDirection.rtl;
                        return DropdownMenuItem<String>(
                          value: city.id,
                          child: Text(
                            isRTL ? city.nameAr : city.name,
                            style: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCityId = value;
                          selectedAreaId = null; // Reset area when city changes
                        });
                        if (value != null) {
                          adminCubit.fetchAreas(value);
                        }
                      },
                    );
                  },
                ),

                SizedBox(height: 16.h),

                // Area Dropdown
                if (selectedCityId != null)
                  BlocBuilder<AdminPanelCubit, AdminPanelStates>(
                    builder: (context, state) {
                      final adminCubit = AdminPanelCubit.get(context);

                      if (state is LoadingAreasState) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (adminCubit.areas.isEmpty) {
                        return const Text('No areas found for selected city');
                      }

                      return DropdownButtonFormField<String>(
                        value: selectedAreaId,
                        decoration: InputDecoration(
                          labelText: S.of(context).select_area,
                          labelStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                          hintStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black54,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              width: 2.0,
                            ),
                          ),
                        ),
                        items: adminCubit.areas.map((area) {
                          final isRTL =
                              Directionality.of(context) == TextDirection.rtl;
                          return DropdownMenuItem<String>(
                            value: area.id,
                            child: Text(
                              isRTL ? area.nameAr : area.name,
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedAreaId = value;
                          });
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                S.of(context).cancel,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: selectedAreaId != null
                  ? () {
                      // Find the selected area name
                      final adminCubit = AdminPanelCubit.get(context);
                      final selectedArea = adminCubit.areas.firstWhere(
                        (area) => area.id == selectedAreaId,
                        orElse: () => adminCubit.areas.first,
                      );

                      // Debug: Print area information
                      print(
                          "Selected area: ${selectedArea.name} (ID: ${selectedArea.id})");

                      // Update the restaurant cubit with the selected area
                      final restCubit = Restuarantscubit.get(context);
                      print(
                          "Current restaurants before filtering: ${restCubit.restaurants.length}");

                      restCubit.updateSelectedArea(selectedArea.name);

                      print(
                          "Restaurants after filtering: ${restCubit.restaurants.length}");

                      Navigator.pop(dialogContext);

                      // Show success message with more details
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${S.of(context).location_updated_to} ${selectedArea.name}\n${restCubit.restaurants.length} ${S.of(context).restaurants_found}'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  : null,
              child: Text(S.of(context).select_location),
            ),
          ],
        ),
      ),
    );
  }
}
