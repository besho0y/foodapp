import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/shared/colors.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primarylight,
  scaffoldBackgroundColor: Colors.grey[200],
  appBarTheme: AppBarTheme(
    color: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.primarylight),
    titleTextStyle: TextStyle(
      color: AppColors.primarylight,
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primarylight,
    unselectedItemColor: Colors.grey.shade600,
    type: BottomNavigationBarType.fixed,
    elevation: 10,
  ),
  textTheme: TextTheme(

    //body
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),

    bodyMedium: TextStyle(
      fontSize: 20.sp,
      color: AppColors.primarylight,
      fontWeight: FontWeight.bold,
    ),

     bodySmall: TextStyle(fontSize: 14.sp, color: Colors.grey),


    //headline
     headlineLarge: TextStyle(
      fontSize: 30.sp,
      fontWeight: FontWeight.bold,
      color: AppColors.primarylight,
    ),

    headlineSmall: TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
      color: AppColors.primarylight,
    ),
    
   

   //label
   labelLarge: TextStyle(
      fontSize: 18.sp,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),

    labelMedium: TextStyle(fontSize: 14.sp, color: Colors.black),
 
    labelSmall: TextStyle(fontSize: 14.sp, color: AppColors.primarylight,fontWeight: FontWeight.bold),


    //title
    titleMedium: TextStyle(fontSize: 16.sp, color: Colors.white),


  ),
  cardColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primarylight,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primarylight,
  ),
  cardTheme: CardTheme(color: Colors.white, elevation: 5),
);















ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primarylight,
  scaffoldBackgroundColor: Color(0xFF121212),
  appBarTheme: AppBarTheme(
    color: Color(0xFF1E1E1E),
    elevation: 1,
    iconTheme: IconThemeData(color: AppColors.primarydark),
    titleTextStyle: TextStyle(
      color: AppColors.primarydark,
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Color(0xFF121212),
      statusBarIconBrightness: Brightness.light,
    ),
  ),
  colorScheme: ColorScheme.dark().copyWith(secondary: Colors.greenAccent),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: AppColors.primarydark,
    unselectedItemColor: Colors.grey.shade600,
    type: BottomNavigationBarType.fixed,
    elevation: 10,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      fontSize: 16.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
      color: AppColors.primarydark,
    ),
    bodyMedium: TextStyle(fontSize: 14.sp, color: AppColors.primarydark),
    bodySmall: TextStyle(fontSize: 14.sp, color: Colors.grey),
    labelMedium: TextStyle(fontSize: 14.sp, color: Colors.white),
    labelLarge: TextStyle(
      fontSize: 18.sp,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: TextStyle(
      fontSize: 30.sp,
      fontWeight: FontWeight.bold,
      color: AppColors.primarydark,
    ),
    titleMedium: TextStyle(fontSize: 16.sp, color: Colors.white),
  ),
  cardColor: Color(0xFF1F1F1F),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primarydark,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primarydark,
  ),
  cardTheme: CardTheme(color: Colors.grey[900]),
);
