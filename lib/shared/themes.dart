import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.lightBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightBackground,
    elevation: 0,
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: AppColors.primaryLight),
    titleTextStyle: TextStyle(
      color: AppColors.primaryLight,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: AppColors.lightBackground,
      statusBarIconBrightness: Brightness.dark,
    ),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: AppColors.accentLight,
    primary: AppColors.primaryLight,
    surface: AppColors.lightCard,
  ),
  progressIndicatorTheme:
      const ProgressIndicatorThemeData(color: AppColors.primaryLight),

  // Bottom Navigation Bar Theme with creative styling
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.lightNavBackground,
    selectedItemColor: AppColors.navIconLight,
    unselectedItemColor: AppColors.lightSecondaryText,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.lightText),
    bodyMedium: TextStyle(
      fontSize: 20,
      color: AppColors.primaryLight,
      fontWeight: FontWeight.bold,
    ),
    bodySmall: TextStyle(fontSize: 14, color: AppColors.lightSecondaryText),
    headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryLight,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryLight,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      color: AppColors.lightText,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: TextStyle(fontSize: 14, color: AppColors.lightText),
    labelSmall: TextStyle(
      fontSize: 14,
      color: AppColors.primaryLight,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(fontSize: 16, color: AppColors.lightText),
  ),
  cardColor: AppColors.lightCard,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryLight,
    foregroundColor: Colors.white,
  ),
  cardTheme: CardThemeData(
    color: AppColors.lightCard,
    elevation: 6,
    shadowColor: AppColors.primaryLight.withOpacity(0.2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  // Container theme for better visual hierarchy
  dividerColor: AppColors.lightAccent,
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryDark,
  scaffoldBackgroundColor: AppColors.darkBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    elevation: 0,
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
  colorScheme: const ColorScheme.dark().copyWith(
    secondary: AppColors.accentDark,
    primary: AppColors.primaryDark,
    surface: AppColors.darkCard,
  ),
  progressIndicatorTheme:
      const ProgressIndicatorThemeData(color: AppColors.primaryDark),

  // Bottom Navigation Bar Theme with brown background
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.darkNavBackground,
    selectedItemColor: AppColors.navIconDark,
    unselectedItemColor: AppColors.darkSecondaryText,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontSize: 16,
      color: AppColors.darkText,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(
      fontSize: 20,
      color: AppColors.primaryDark,
      fontWeight: FontWeight.bold,
    ),
    bodySmall: TextStyle(fontSize: 14, color: AppColors.darkSecondaryText),
    headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryDark,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryDark,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      color: AppColors.darkText,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: TextStyle(fontSize: 14, color: AppColors.darkText),
    labelSmall: TextStyle(
      fontSize: 14,
      color: AppColors.primaryDark,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(fontSize: 16, color: AppColors.darkText),
  ),
  cardColor: AppColors.darkCard,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkCard,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.darkCard,
    foregroundColor: Colors.white,
  ),
  cardTheme: CardThemeData(
    color: AppColors.darkCard,
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  // Container theme for better visual hierarchy in dark mode
  dividerColor: AppColors.darkAccent,
);
