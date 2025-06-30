import 'package:flutter/material.dart';

// TODO: まだ未完成、未使用
ThemeData customThemeData() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal.shade600,
      foregroundColor: Colors.white.withValues(alpha: 0.9),
      centerTitle: true,
    ),

    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.black.withValues(alpha: 0.8)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.6),
      iconColor: Colors.white,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black.withValues(alpha: 0.6),
          width: 1.0,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black.withValues(alpha: 0.6),
          width: 2.0,
        ),
      ),
    ),

    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white.withValues(alpha: 0.9),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionHandleColor: Colors.teal.shade300,
      selectionColor: Colors.teal.shade100,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        foregroundColor: Colors.black,
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),

    iconTheme: IconThemeData(
      color: Colors.white.withValues(alpha: 0.9),
      size: 30,
    ),
  );
}

BoxDecoration backGroundBoxDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.teal.shade200, Colors.teal.shade600],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );
}

InputDecoration customInputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.black.withValues(alpha: 0.8)),
    icon: Icon(icon, color: Colors.white, size: 30),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.6),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.black.withValues(alpha: 0.6),
        width: 1.0,
      ),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.black.withValues(alpha: 0.6),
        width: 2.0,
      ),
    ),
  );
}

TextStyle customColoredLargeBoldTextStyle() {
  return TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: Colors.white.withValues(alpha: 0.9),
  );
}

TextStyle customColoredNormalTextStyle() {
  return TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 14,
    color: Colors.white.withValues(alpha: 0.9),
  );
}
