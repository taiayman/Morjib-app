import 'package:flutter/material.dart';

ThemeData appTheme(bool isDarkTheme) {
  return ThemeData(
    primaryColor: Color(0xFFD97757),
    backgroundColor: isDarkTheme ? Color(0xFF2C2B28) : Color(0xFFF2F0E8),
    brightness: isDarkTheme ? Brightness.dark : Brightness.light,
    textTheme: TextTheme(
      bodyText1: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
      bodyText2: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
    ),
  );
}
