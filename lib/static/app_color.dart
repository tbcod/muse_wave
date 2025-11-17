import 'package:flutter/material.dart';

abstract class AppColor {
  static const Color mainColor = Color(0xffCBBFFF);
  static const Color grey = Color(0x88141414);

  static Color hex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
