import 'package:flutter/material.dart';

class AppPalette {
  AppPalette._privateConstructor();
  static final AppPalette _instance = AppPalette._privateConstructor();
  factory AppPalette() => _instance;

  static const Color greenColor = Color(0xFF58CC02);
  static const Color blackColor = Color(0xFF4B4B4B);
  static const Color skyColor = Color(0xFF1CB0F6);
  static const Color greyColor = Color(0xFFE5E5E5);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color yellowColor = Color(0xFFFFC800);
  static const Color darkGreyColor = Color(0xFF777777);
  static const Color pinkColor = Color(0xFFCE82FF);
  static const Color dartGreen = Color(0xFF58A700);
}
