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
          appBar: AppBar(
            title: Text(cubit.titles[cubit.currentindex]),
            actions:
                cubit.currentindex == 2
                    ? [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.brightness_6_outlined, size: 25.sp),
                      ),
                    ]
                    : [],
          ),
          body: cubit.screens[cubit.currentindex],
          bottomNavigationBar: BottomNavigationBar(
            items: cubit.bottomnav,
            currentIndex: cubit.currentindex,
            onTap: (index) {
              cubit.changenavbar(index);
            },
          ),
          floatingActionButton:
              cubit.currentindex == 0
                  ? FloatingActionButton(
                    onPressed: () {},
                    heroTag: "cart",
                    child: Icon(Icons.shopping_cart_outlined),
                  )
                  : null,
        );
      },
    );
  }
}
