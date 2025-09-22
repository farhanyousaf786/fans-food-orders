import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppColors {
  // general colors
  static const Color bgColor = Color(0xFFEFF1F4);
  static const Color unSelectedColor = Color(0xFF484C52);
  static const Color primaryColor = Color(0xFF426FF3);
  static const Color primaryDarkColor = Color(0xFF3C67E3); // 20% darker
  static const Color primaryLightColor = Color(0xFF5A84F8); // 20% lighter
  static List<Color> primaryGradient = [
    primaryLightColor,
    primaryColor,
    primaryLightColor,
  ];
  static const Color secondaryColor = Color(0xFFFEAD1D);
  static const Color secondaryLightColor = Color(0xFFF9A84D);
  static const Color secondaryDarkColor = Color(0xFFDA6317);
  static const Color errorColor = Color(0xFFFF4B4B);
  static const Color successColor = Color(0xFF388E3C);
  static const Color likeColor = Color(0xFFFF1D1D);
  static const Color starColor = Color(0xFFFEAD1D);
  static Color starEmptyColor = grayColor.withOpacity(0.3);
  static const Color lightBorderColor = Color(0xFFF4F4F4);
  static const Color grayColor = Color(0xFF3B3B3B);
  // static const Color grayColor = Color(0xFF888787);
  static const Color grayLightColor = Color(0xFFF6F6F6);
  // for order status
  // pending,
  // preparing,
  // delivering,
  // delivered,
  // canceled;

  // for order status
  static const Color pendingColor = starColor;
  static const Color preparingColor = secondaryColor;
  static const Color deliveringColor = Colors.blue;
  static const Color deliveredColor = successColor;
  static const Color canceledColor = errorColor;

  // shimmer colors
  static const Color shimmerBaseColor = Color(0xFFE0E0E0);
  static const Color shimmerHighlightColor = Color(0xFFF5F5F5);

  // light theme colors
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightTextColor = Color(0xFF000000);
  static const Color lightCardColor = Color(0xFFFFFFFF);

  // dark theme colors
  static const Color darkBackgroundColor = Colors.black;
  static const Color darkTextColor = Colors.white;
  static const Color darkCardColor = Color(0xFF252525);

  // getters
  Color backgroundColor = Hive.box("myBox").get("isDarkMode") == false
      ? lightBackgroundColor
      : lightBackgroundColor;

  Color textColor = Hive.box("myBox").get("isDarkMode") == false
      ? lightTextColor
      : lightTextColor;

  Color cardColor = Hive.box("myBox").get("isDarkMode") == false
      ? lightCardColor
      : lightCardColor;

  Color secondaryTextColor = Hive.box("myBox").get("isDarkMode") == false
      ? Color(0xFF3F3F3F)
      : Color(0xFF3F3F3F);

  Color borderColor = Hive.box("myBox").get("isDarkMode") == false
      ? lightBorderColor
      : lightBorderColor;
}
