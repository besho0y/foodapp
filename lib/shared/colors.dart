import 'package:flutter/material.dart';

class AppColors {
  // Primary brown color
  static const Color primaryBrown = Color.fromARGB(255, 74, 26, 15);

  // Light Theme Colors
  static const Color primaryLight =
      Color.fromARGB(255, 74, 26, 15); // Brown for text/icons
  static const Color accentLight = Color(0xFF6D4037); // Darker brown accent

  // Dark Theme Colors - Updated to use white text and brown backgrounds
  static const Color primaryDark =
      Color(0xFFFFFFFF); // White for text/icons in dark mode
  static const Color accentDark =
      Color(0xFFE0E0E0); // Light gray accent for dark mode

  // Background Colors
  static const Color lightBackground =
      Color(0xFFFFFFFF); // Pure white for light mode
  static const Color darkBackground =
      Color(0xFF000000); // Pure black for dark mode

  // Card and Container Colors - Updated to use brown in dark mode
  static const Color lightCard =
      Color(0xFFFAFAFA); // Very light gray for light mode cards
  static const Color lightContainer =
      Color(0xFFF5F5F5); // Light gray for containers
  static const Color darkCard =
      Color.fromARGB(255, 74, 26, 15); // Brown for dark mode cards
  static const Color darkContainer = Color.fromARGB(
      255, 95, 35, 20); // Slightly lighter brown for dark containers

  // Navigation Colors - Updated to use brown in dark mode
  static const Color lightNavBackground =
      Color(0xFFFFFFFF); // White nav in light mode
  static const Color darkNavBackground =
      Color.fromARGB(255, 74, 26, 15); // Brown nav in dark mode
  static const Color navIconLight =
      Color.fromARGB(255, 74, 26, 15); // Brown icons in light mode
  static const Color navIconDark =
      Color(0xFFFFFFFF); // White icons in dark mode

  // Text Colors - Updated to use white in dark mode
  static const Color lightText =
      Color.fromARGB(255, 74, 26, 15); // Brown text for light mode
  static const Color darkText = Color(0xFFFFFFFF); // White text for dark mode
  static const Color lightSecondaryText =
      Color(0xFF6D4037); // Darker brown for secondary text
  static const Color darkSecondaryText =
      Color(0xFFE0E0E0); // Light gray for secondary text in dark mode

  // Accent and Highlight Colors
  static const Color lightAccent = Color(0xFFD7CCC8); // Light brown accent
  static const Color darkAccent = Color(0xFF5D4037); // Dark brown accent
  static const Color highlight =
      Color(0xFFBCAAA4); // Medium brown for highlights
}

/// A reusable widget that provides theme-based background images
class ThemeBasedBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  final BoxFit fit;

  const ThemeBasedBackground({
    Key? key,
    required this.child,
    this.opacity = 0.3,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final imagePath =
        isDarkMode ? 'assets/images/dark.PNG' : 'assets/images/light.PNG';

    return Stack(
      children: [
        // Background image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: fit,
              opacity: opacity,
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}
