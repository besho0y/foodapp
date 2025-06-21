import 'package:flutter/material.dart';

class AppColors {
  // Primary brown color
  static const Color primaryBrown = Color.fromARGB(255, 74, 26, 15);

  // Light Theme Colors
  static const Color primaryLight =
      Color.fromARGB(255, 74, 26, 15); // Brown for text/icons
  static const Color accentLight = Color(0xFF6D4037); // Darker brown accent

  // Dark Theme Colors
  static const Color primaryDark =
      Color.fromARGB(255, 74, 26, 15); // Brown for backgrounds
  static const Color accentDark = Color(0xFF8B5549); // Lighter brown accent

  // Background Colors
  static const Color lightBackground =
      Color(0xFFFFFFFF); // Pure white for light mode
  static const Color darkBackground =
      Color.fromARGB(255, 74, 26, 15); // Brown for dark mode

  // Card and Container Colors - More creative variations
  static const Color lightCard =
      Color(0xFFFAFAFA); // Very light gray for light mode cards
  static const Color lightContainer =
      Color(0xFFF5F5F5); // Light gray for containers
  static const Color darkCard =
      Color.fromARGB(240, 51, 18, 10); // Lighter brown for dark mode cards
  static const Color darkContainer =
      Color.fromARGB(255, 126, 53, 37); // Medium brown for dark containers

  // Navigation Colors
  static const Color lightNavBackground =
      Color(0xFFFFFFFF); // White nav in light mode
  static const Color darkNavBackground =
      Color(0xFFffffff); // Darker brown nav in dark mode
  static const Color navIconLight =
      Color.fromARGB(255, 74, 26, 15); // Brown icons in light mode
  static const Color navIconDark =
      Color(0xFFFFFFFF); // White icons in dark mode

  // Text Colors
  static const Color lightText =
      Color.fromARGB(255, 74, 26, 15); // Brown text for light mode
  static const Color darkText = Color(0xFFFFFFFF); // White text for dark mode
  static const Color lightSecondaryText =
      Color(0xFF6D4037); // Darker brown for secondary text
  static const Color darkSecondaryText =
      Color(0xFFF5F5F5); // Light gray for secondary text

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
