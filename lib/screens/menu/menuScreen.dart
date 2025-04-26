// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/models/item.dart';
import 'package:foodapp/screens/favourits/cubit.dart';
import 'package:foodapp/screens/favourits/states.dart';

import 'package:foodapp/shared/colors.dart';
import 'package:foodapp/shared/constants.dart';
import 'package:foodapp/widgets/itemcard.dart';

class Menuscreen extends StatelessWidget {
  const Menuscreen({super.key, required this.items,required this.name});
  final List<Item> items;
  final String? name;
  @override
  Widget build(BuildContext context) {

    return BlocConsumer<Favouritecubit, FavouriteState>(
      listener: (context, state) {
       
      },
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(double.infinity.w, 120.h),
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15.r),
                      ),
                      child: Image.asset(
                        "assets/images/banners/banner2.png",
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10.h,
                    left: 0,
                    child: IconButton(
                      onPressed: () {
                        backarrow(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.primarylight,
                        size: 30.sp,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -8.h,
                    right: -1.w,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[500]!, width: 2),
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.r),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 8.h,
                          left: 8.w,
                          right: 8.w,
                        ),
                        child: Text(
                          "${name}",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.h),
              child: Column(
                children: [
                  SizedBox(height: 5.h),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return itemcard(context, false, items[index]);
                      },
                      itemCount: items.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
