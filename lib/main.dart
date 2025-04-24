import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/layout/cubit.dart';
import 'package:foodapp/layout/layout.dart';
import 'package:foodapp/screens/item%20des/itemScreen.dart';
import 'package:foodapp/screens/login/loginScreen.dart';
import 'package:foodapp/screens/menu/menuScreen.dart';
import 'package:foodapp/screens/resturants/cubit.dart';
import 'package:foodapp/screens/signup/signupScreen.dart';
import 'package:foodapp/shared/blocObserver.dart';
import 'package:foodapp/shared/themes.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
     providers: [
      BlocProvider(
      create: ( context) => Layoutcubit(),),
      BlocProvider(
        create: (context) => (Restuarantscubit()),
       
      )
     ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        // Use builder only if you need to use library outside ScreenUtilInit context
        builder: (_, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'First Method',
            // You can use the library anywhere in the app even in theme
            theme: lightTheme,

            home:Layout(),
          );
        },
      ),
    );
  }
}
