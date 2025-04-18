import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.orangeAccent,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: Colors.white,
    elevation: 1,
    iconTheme: IconThemeData(color: Colors.deepOrange),
    titleTextStyle: TextStyle(
      color: Colors.deepOrange,
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
    selectedItemColor: Colors.deepOrange,
    unselectedItemColor: Colors.grey.shade600,
    type: BottomNavigationBarType.fixed,
    elevation: 10,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
    headlineSmall: TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
      color: Colors.deepOrange,
    ),
    bodyMedium: TextStyle(fontSize: 14.sp, color: Colors.deepOrange),
    bodySmall: TextStyle(fontSize: 14.sp, color: Colors.grey),
    labelMedium: TextStyle(fontSize: 14.sp, color: Colors.white),
  ),
  cardColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepOrange,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.deepOrange,
  ),
  cardTheme: CardTheme(color: Colors.white24),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.deepOrange,
  scaffoldBackgroundColor: Color(0xFF121212),
  appBarTheme: AppBarTheme(
    color: Color(0xFF1E1E1E),
    elevation: 1,
    iconTheme: IconThemeData(color: Colors.orangeAccent),
    titleTextStyle: TextStyle(
      color: Colors.orangeAccent,
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
    selectedItemColor: Colors.orangeAccent,
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
      color: Colors.orangeAccent,
    ),
    bodyMedium: TextStyle(fontSize: 18.sp, color: Colors.orangeAccent),
    bodySmall: TextStyle(fontSize: 14.sp, color: Colors.grey),
    labelMedium: TextStyle(fontSize: 14.sp, color: Colors.white),
  ),
  cardColor: Color(0xFF1F1F1F),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orangeAccent,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.orangeAccent,
  ),
  cardTheme: CardTheme(color: Colors.grey[900]),
);
