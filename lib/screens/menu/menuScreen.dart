import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/shared/constants.dart';

class Menuscreen extends StatelessWidget {
  const Menuscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 5.h),
              itemcard(context),
              mydivider(context),
            
            ],
          ),
        ),
      ),
    );
  }

  Widget itemcard(context) => SizedBox(
    height: 120.h,
    width: double.infinity.w,
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 5.h),
                Expanded(
                  child: Text(
                    "dish name",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  height: 50.h,
                  width: 230.w,
                  child: Text(
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "1000 egp",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),

                      IconButton(
                        onPressed: () {},
                        icon: FloatingActionButton(
                          onPressed: () {},
                          shape: const CircleBorder(),
                          heroTag: "item1",
                          child: Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 75.w,
            height: double.infinity.h,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  "https://img.freepik.com/free-photo/chicken-fajita-chicken-fillet-fried-with-bell-pepper-lavash-with-bread-slices-white-plate_114579-174.jpg?t=st=1744922556~exp=1744926156~hmac=6c4a657fca722e2e154db2727df47a1db243ff2a23718e129f2da31bc74438e9&w=740",
                ),
              ),
            ),
          ),

          // Image(
          //   image: NetworkImage(
          //     "https://img.freepik.com/free-photo/chicken-fajita-chicken-fillet-fried-with-bell-pepper-lavash-with-bread-slices-white-plate_114579-174.jpg?t=st=1744922556~exp=1744926156~hmac=6c4a657fca722e2e154db2727df47a1db243ff2a23718e129f2da31bc74438e9&w=740",
          //   ),
          // ),
        ],
      ),
    ),
  );
}
