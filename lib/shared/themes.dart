import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'colors.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.lightBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: AppColors.primaryLight),
    titleTextStyle: TextStyle(
      color: AppColors.primaryLight,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: AppColors.accentLight,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primaryLight,),

  textTheme: TextTheme(
    bodyLarge: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
    bodyMedium: const TextStyle(
      fontSize: 20,
      color: AppColors.primaryLight,
      fontWeight: FontWeight.bold,
    ),
    bodySmall: TextStyle(fontSize: 14, color: Colors.grey[600]),
    headlineLarge: const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryLight,
    ),
    headlineSmall: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryLight,
    ),
    labelLarge: const TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: const TextStyle(fontSize: 14, color: Colors.black),
    labelSmall: const TextStyle(
      fontSize: 14,
      color: AppColors.primaryLight,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: const TextStyle(fontSize: 16, color: Colors.white),
  ),
  cardColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryLight,
  ),
  cardTheme: const CardTheme(color: Colors.white, elevation: 5),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryDark,
  scaffoldBackgroundColor: AppColors.darkBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkCard,
    elevation: 1,
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: AppColors.primaryDark),
    titleTextStyle: TextStyle(
      color: AppColors.primaryDark,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: AppColors.darkBackground,
      statusBarIconBrightness: Brightness.light,
    ),
  ),
  colorScheme: const ColorScheme.dark().copyWith(secondary: AppColors.accentDark),
  progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primaryDark,),

  textTheme: TextTheme(
    bodyLarge: const TextStyle(
      fontSize: 16,
      color: Color(0xFFE0E0E0),
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: const TextStyle(fontSize: 14, color: AppColors.primaryDark),
    bodySmall: TextStyle(fontSize: 14, color: Colors.grey[600]),
    headlineLarge: const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryDark,
    ),
    headlineSmall: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryDark,
    ),
    labelLarge: const TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: const TextStyle(fontSize: 14, color: Colors.white),
    labelSmall: const TextStyle(
      fontSize: 14,
      color: AppColors.primaryDark,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: const TextStyle(fontSize: 16, color: Colors.white),
  ),
  cardColor: AppColors.darkCard,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark,
  ),
  cardTheme: CardTheme(color: Colors.grey[900], elevation: 5),
);
