import 'package:flutter/material.dart';

ThemeData customTheme() {
  return ThemeData();
  // TODO: 未実装
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
