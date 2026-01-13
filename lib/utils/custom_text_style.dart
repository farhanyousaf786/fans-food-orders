import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_colors.dart' show AppColors;

class CustomTextStyle {
  static TextStyle size30Weight600Text([Color? color]) {
    return TextStyle(
      fontSize: 30,
      fontFamily: 'SF',
      fontWeight: FontWeight.w600,
      color: color ?? AppColors().textColor,
    );
  }

  static TextStyle size27Weight600Text([Color? color]) {
    return TextStyle(
      fontSize: 27,
      fontFamily: 'SF',
      fontWeight: FontWeight.w600,
      color: color ?? AppColors().textColor,
    );
  }

  static TextStyle size25Weight600Text([Color? color]) {
    return TextStyle(
      fontSize: 25,
      fontFamily: 'SF',
      fontWeight: FontWeight.w600,
      color: color ?? AppColors().textColor,
      height: 1.5,
      letterSpacing: 0.5,
    );
  }

  static TextStyle size24Weight600Text([Color? color]) {
    return TextStyle(
      fontSize: 24,
      fontFamily: 'SF',
      fontWeight: FontWeight.w600,
      color: color ?? AppColors().textColor,
    );
  }

  static TextStyle size22Weight600Text([Color? color]) {
    return TextStyle(
      fontSize: 22,
      fontFamily: 'SF',
      fontWeight: FontWeight.w600,
      color: color ?? AppColors().textColor,
    );
  }

  static TextStyle size20Weight600Text([Color? color]) {
    return TextStyle(
      fontSize: 20,
      fontFamily: 'SF',
      fontWeight: FontWeight.w600,
      color: color ?? AppColors().textColor,
    );
  }

  static TextStyle size18Weight600Text([Color? color]) {
    return TextStyle(
      fontSize: 18,
      fontFamily: 'SF',
      fontWeight: FontWeight.w600,
      color: color ?? AppColors().textColor,
    );
  }

  static TextStyle size16Weight600Text([Color? color]) {
    return TextStyle(
      fontSize: 16,
      fontFamily: 'SF',
      fontWeight: FontWeight.w600,
      color: color ?? AppColors().textColor,
    );
  }

  static TextStyle size16Weight500Text([Color? color]) {
    return TextStyle(
      fontSize: 16,
      fontFamily: 'SF',
      fontWeight: FontWeight.w500,
      color: color ?? AppColors().textColor,
    );
  }

  static TextStyle size16Weight400Text([Color? color]) {
    return TextStyle(
      fontSize: 16,
      fontFamily: 'SF',
      fontWeight: FontWeight.w400,
      color: color ?? AppColors().textColor,
      height: 1.5,
      letterSpacing: 0.5,
    );
  }

  static TextStyle size14Weight600Text([Color? color]) {
    return TextStyle(
      fontSize: 14,
      fontFamily: 'SF',
      fontWeight: FontWeight.w600,
      color: color ?? AppColors().textColor,
    );
  }

  static TextStyle size14Weight400Text([Color? color]) {
    return TextStyle(
      fontSize: 14,
      fontFamily: 'SF',
      fontWeight: FontWeight.w400,
      color: color ?? AppColors().textColor,
    );
  }
}
