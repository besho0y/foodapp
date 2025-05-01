// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/favourits/states.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/widgets/itemcard.dart';

class Menuscreen extends StatefulWidget {
  Menuscreen({
    super.key,
    required this.items,
    required this.name,
    required this.img,
  });

  final List<Item> items;
  final String? name;
  final String img;

  @override
  State<Menuscreen> createState() => _MenuscreenState();
}

class _MenuscreenState extends State<Menuscreen> {
  final List<String> categories = ["For you", "Burger", "Pizza", "Sushi"];
  String selectedCategory = "For you";

  List<Item> get filteredItems {
    if (selectedCategory == "For you") {
      return widget.items;
    }
    return widget.items
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Favouritecubit, FavouriteState>(
      listener: (context, state) {},
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                // 🟧 Image and Restaurant Title
                Stack(
                  children: [
                    SizedBox(
                      height: 180.h,
                      width: double.infinity,
                      child: Image.asset(widget.img, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 10.h,
                      left: 10.w,
                      child: IconButton(
                        onPressed: () {
                          backarrow(context);
                          FocusScope.of(context).unfocus();
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 28.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10.h,
                      left: 16.w,
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        padding: EdgeInsets.all(8.w),
                        child: Text(
                          widget.name ?? "",
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 🟧 Delivery Info Bar
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      SizedBox(width: 4.w),
                      Text("1-day"),
                      dot(),
                      Text("20 egp", style: TextStyle(color: Colors.green)),
                      dot(),
                      const Icon(Icons.delivery_dining, size: 24),
                    ],
                  ),
                ),

                // 🟧 Category Tabs
                SizedBox(
                  height: 50.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == selectedCategory;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                          child: Chip(
                            label: Text(category),
                            backgroundColor:
                                isSelected
                                    ? Colors.green
                                    : Theme.of(
                                      context,
                                    ).chipTheme.backgroundColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                            elevation: 0,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 🟧 Items
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return itemcard(
                        context,
                        false,
                        filteredItems[index],
                        widget.items,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget dot() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 6.w),
    child: Text("•", style: TextStyle(fontSize: 18.sp)),
  );
}
