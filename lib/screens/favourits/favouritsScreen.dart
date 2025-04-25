import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/widgets/itemcard.dart';

class Favouritsscreen extends StatelessWidget {
  const Favouritsscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: SingleChildScrollView(
        child: Column(children: [itemcard(context, true)]),
      ),
    );
  }
}
