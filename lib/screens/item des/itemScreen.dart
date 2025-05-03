import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/shared/constants.dart';

class Itemscreen extends StatefulWidget {
  const Itemscreen({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.img,
    this.items = const [],
  });

  final String name;
  final String description;
  final double price;
  final String img;
  final dynamic items;

  @override
  State<Itemscreen> createState() => _ItemscreenState();
}

class _ItemscreenState extends State<Itemscreen> {
  int quantity = 1;
  late dynamic displayedItems;

  @override
  void initState() {
    super.initState();

    if (widget.items.length <= 3) {
      displayedItems = widget.items;
    } else {
      widget.items.shuffle();
      displayedItems = widget.items.take(3).toList();
    }
  }

  void incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  void addToCart(Layoutcubit cubit) {
    cubit.addToCart(
      name: widget.name,
      price: widget.price,
      quantity: quantity,
      img: widget.img,
    );
    Navigator.pop(context);
    Fluttertoast.showToast(
      msg: 'Added ${quantity}x ${widget.name} to cart',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = Layoutcubit.get(context);

    return Scaffold(
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 100.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 300.h,
                            width: double.infinity,
                            child: Image.network(widget.img, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 40.h,
                            left: 0,
                            child: IconButton(
                              onPressed: () {
                                backarrow(context);
                              },
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 30.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 300.h,
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  widget.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    const Spacer(),
                                    Text(
                                      "${widget.price} EGP",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Special Request!",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.blueGrey,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                if (displayedItems.isNotEmpty) ...[
                                  SizedBox(height: 20.h),
                                  Text(
                                    "You may also like",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  SizedBox(height: 10.h),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children:
                                          displayedItems.map<Widget>((item) {
                                        return Container(
                                          width: 120.w,
                                          margin: EdgeInsets.only(
                                            right: 10.w,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  10.r,
                                                ),
                                                child: Image.network(
                                                  item.img,
                                                  height: 80.h,
                                                  width: 120.w,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              SizedBox(height: 5.h),
                                              Text(
                                                item.name,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                "${item.price} EGP",
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.labelSmall,
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: IconButton(
                                                  onPressed: () {
                                                    cubit.addToCart(
                                                      name: item.name,
                                                      price: item.price,
                                                      quantity: 1,
                                                      img: item.img,
                                                    );
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          'Added ${item.name} to cart',
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 3,
                                                      backgroundColor:
                                                          Colors.green,
                                                      textColor: Colors.white,
                                                      fontSize: 14.0,
                                                    );
                                                  },
                                                  icon: Icon(
                                                    Icons.add_shopping_cart,
                                                    size: 20.sp,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10.r)],
              ),
              child: Row(
                children: [
                  Card(
                    child: TextButton(
                      onPressed: () => addToCart(cubit),
                      child: Text(
                        "Add to cart",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Card(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: decrementQuantity,
                          icon: Icon(Icons.remove, size: 30.sp),
                        ),
                        Text(
                          "$quantity",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        IconButton(
                          onPressed: incrementQuantity,
                          icon: Icon(Icons.add, size: 30.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
